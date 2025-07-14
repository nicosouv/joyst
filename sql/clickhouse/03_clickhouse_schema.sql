-- ClickHouse Data Warehouse Schema for Gaming Analytics
-- Star schema optimized for game recommendation ML models

-- Drop existing tables if they exist
DROP TABLE IF EXISTS fact_gaming_sessions;
DROP TABLE IF EXISTS fact_game_purchases;
DROP TABLE IF EXISTS dim_games;
DROP TABLE IF EXISTS dim_players;
DROP TABLE IF EXISTS dim_time;
DROP TABLE IF EXISTS dim_game_categories;

-- Dimension Tables

-- Player dimension
CREATE TABLE dim_players (
    player_sk UInt64,
    steamid String,
    persona_name String,
    profile_url String,
    avatar_url String,
    account_created_date Date,
    community_visibility_state UInt8,
    profile_state UInt8,
    country_code String,
    state_code String,
    city_code String,
    is_active UInt8 DEFAULT 1,
    created_at DateTime DEFAULT now(),
    updated_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY player_sk
SETTINGS index_granularity = 8192;

-- Game dimension with enriched metadata
CREATE TABLE dim_games (
    game_sk UInt64,
    appid UInt32,
    name String,
    short_description String,
    detailed_description String,
    developer String,
    publisher String,
    release_date Date,
    price_initial Float32,
    price_current Float32,
    discount_percent UInt8,
    metacritic_score UInt8,
    positive_ratings UInt32,
    negative_ratings UInt32,
    estimated_owners String,
    peak_ccu UInt32,
    required_age UInt8,
    is_free UInt8,
    dlc_count UInt16,
    achievement_count UInt16,
    average_playtime UInt32,
    median_playtime UInt32,
    img_icon_url String,
    img_logo_url String,
    is_active UInt8 DEFAULT 1,
    created_at DateTime DEFAULT now(),
    updated_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY game_sk
SETTINGS index_granularity = 8192;

-- Game categories/genres dimension
CREATE TABLE dim_game_categories (
    category_sk UInt64,
    game_sk UInt64,
    category_type Enum8('genre' = 1, 'category' = 2, 'tag' = 3),
    category_name String,
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY (category_sk, game_sk)
SETTINGS index_granularity = 8192;

-- Time dimension for temporal analysis
CREATE TABLE dim_time (
    date_sk UInt32,
    date Date,
    year UInt16,
    quarter UInt8,
    month UInt8,
    week UInt8,
    day_of_month UInt8,
    day_of_week UInt8,
    day_of_year UInt16,
    is_weekend UInt8,
    is_holiday UInt8,
    season Enum8('Spring' = 1, 'Summer' = 2, 'Fall' = 3, 'Winter' = 4)
) ENGINE = MergeTree()
ORDER BY date_sk
SETTINGS index_granularity = 8192;

-- Fact Tables

-- Gaming sessions fact table for detailed play analysis
CREATE TABLE fact_gaming_sessions (
    session_sk UInt64,
    player_sk UInt64,
    game_sk UInt64,
    date_sk UInt32,
    session_start DateTime,
    session_end DateTime,
    session_duration_minutes UInt32,
    playtime_total_minutes UInt32,
    achievements_unlocked UInt16,
    is_first_play UInt8,
    device_type Enum8('Windows' = 1, 'Mac' = 2, 'Linux' = 3, 'SteamDeck' = 4),
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(session_start)
ORDER BY (player_sk, game_sk, session_start)
SETTINGS index_granularity = 8192;

-- Game ownership/purchase fact table
CREATE TABLE fact_game_purchases (
    purchase_sk UInt64,
    player_sk UInt64,
    game_sk UInt64,
    purchase_date_sk UInt32,
    purchase_datetime DateTime,
    purchase_price Float32,
    discount_percent UInt8,
    purchase_method Enum8('Store' = 1, 'Gift' = 2, 'Key' = 3, 'Free' = 4),
    refunded UInt8 DEFAULT 0,
    refund_date DateTime NULL,
    total_playtime_minutes UInt32 DEFAULT 0,
    last_played DateTime NULL,
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(purchase_datetime)
ORDER BY (player_sk, game_sk, purchase_datetime)
SETTINGS index_granularity = 8192;

-- Materialized Views for ML Features

-- Player gaming patterns aggregated by month
CREATE MATERIALIZED VIEW mv_player_monthly_stats
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(month_date)
ORDER BY (player_sk, month_date)
AS SELECT
    player_sk,
    toStartOfMonth(session_start) as month_date,
    count() as sessions_count,
    sum(session_duration_minutes) as total_playtime_minutes,
    avg(session_duration_minutes) as avg_session_duration,
    uniq(game_sk) as unique_games_played,
    sum(achievements_unlocked) as total_achievements,
    countIf(is_first_play = 1) as new_games_tried
FROM fact_gaming_sessions
GROUP BY player_sk, month_date;

-- Game popularity metrics
CREATE MATERIALIZED VIEW mv_game_popularity_stats
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(month_date)
ORDER BY (game_sk, month_date)
AS SELECT
    game_sk,
    toStartOfMonth(session_start) as month_date,
    uniq(player_sk) as unique_players,
    count() as total_sessions,
    sum(session_duration_minutes) as total_playtime_minutes,
    avg(session_duration_minutes) as avg_session_duration,
    sum(achievements_unlocked) as total_achievements_earned
FROM fact_gaming_sessions
GROUP BY game_sk, month_date;

-- Player game preferences for recommendation engine
CREATE MATERIALIZED VIEW mv_player_game_preferences
ENGINE = ReplacingMergeTree()
ORDER BY (player_sk, game_sk)
AS SELECT
    player_sk,
    game_sk,
    count() as total_sessions,
    sum(session_duration_minutes) as total_playtime_minutes,
    max(session_start) as last_played,
    avg(session_duration_minutes) as avg_session_duration,
    sum(achievements_unlocked) as total_achievements,
    countIf(session_duration_minutes > 60) as long_sessions_count,
    total_playtime_minutes / (dateDiff('day', min(session_start), max(session_start)) + 1) as daily_avg_playtime
FROM fact_gaming_sessions
GROUP BY player_sk, game_sk;

-- Indexes for faster ML feature extraction
-- Player behavior index
CREATE TABLE player_behavior_features (
    player_sk UInt64,
    feature_date Date,
    avg_daily_playtime Float32,
    preferred_genres Array(String),
    avg_session_duration Float32,
    games_per_month Float32,
    achievement_rate Float32,
    weekend_vs_weekday_ratio Float32,
    genre_diversity_score Float32,
    price_sensitivity_score Float32
) ENGINE = ReplacingMergeTree()
ORDER BY (player_sk, feature_date)
SETTINGS index_granularity = 8192;

-- Game similarity features for collaborative filtering
CREATE TABLE game_similarity_features (
    game_sk_1 UInt64,
    game_sk_2 UInt64,
    similarity_score Float32,
    common_players UInt32,
    genre_overlap_score Float32,
    playtime_correlation Float32,
    calculated_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree()
ORDER BY (game_sk_1, game_sk_2)
SETTINGS index_granularity = 8192;