-- Steam Data Model for JOYST Platform
-- Creates tables to store Steam account data extracted via API

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS steam_recently_played CASCADE;
DROP TABLE IF EXISTS steam_owned_games CASCADE;
DROP TABLE IF EXISTS steam_players CASCADE;
DROP TABLE IF EXISTS steam_games CASCADE;

-- Players table - stores Steam user profile information
CREATE TABLE steam_players (
    id SERIAL PRIMARY KEY,
    steamid VARCHAR(20) UNIQUE NOT NULL,
    personaname VARCHAR(255),
    profileurl TEXT,
    avatar TEXT,
    personastate INTEGER,
    communityvisibilitystate INTEGER,
    profilestate INTEGER,
    lastlogoff TIMESTAMP,
    timecreated TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Games catalog - stores information about Steam games
CREATE TABLE steam_games (
    id SERIAL PRIMARY KEY,
    appid INTEGER UNIQUE NOT NULL,
    name VARCHAR(500) NOT NULL,
    img_icon_url VARCHAR(255),
    img_logo_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Owned games - stores games owned by players with playtime stats
CREATE TABLE steam_owned_games (
    id SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES steam_players(id) ON DELETE CASCADE,
    game_id INTEGER REFERENCES steam_games(id) ON DELETE CASCADE,
    appid INTEGER NOT NULL,
    playtime_forever INTEGER DEFAULT 0, -- Total playtime in minutes
    playtime_2weeks INTEGER DEFAULT 0,  -- Playtime in last 2 weeks in minutes
    last_played TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(player_id, appid)
);

-- Recently played games - stores recent gaming activity
CREATE TABLE steam_recently_played (
    id SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES steam_players(id) ON DELETE CASCADE,
    game_id INTEGER REFERENCES steam_games(id) ON DELETE CASCADE,
    appid INTEGER NOT NULL,
    playtime_forever INTEGER DEFAULT 0,
    playtime_2weeks INTEGER DEFAULT 0,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_steam_players_steamid ON steam_players(steamid);
CREATE INDEX idx_steam_games_appid ON steam_games(appid);
CREATE INDEX idx_owned_games_player_id ON steam_owned_games(player_id);
CREATE INDEX idx_owned_games_appid ON steam_owned_games(appid);
CREATE INDEX idx_recently_played_player_id ON steam_recently_played(player_id);
CREATE INDEX idx_recently_played_recorded_at ON steam_recently_played(recorded_at);

-- Views for common queries
CREATE OR REPLACE VIEW player_game_stats AS
SELECT 
    p.steamid,
    p.personaname,
    g.name as game_name,
    og.playtime_forever,
    og.playtime_2weeks,
    og.last_played,
    ROUND(og.playtime_forever / 60.0, 2) as hours_played_total,
    ROUND(og.playtime_2weeks / 60.0, 2) as hours_played_recent
FROM steam_players p
JOIN steam_owned_games og ON p.id = og.player_id
JOIN steam_games g ON og.game_id = g.id
ORDER BY og.playtime_forever DESC;

CREATE OR REPLACE VIEW top_games_by_playtime AS
SELECT 
    g.name,
    g.appid,
    COUNT(og.player_id) as total_players,
    AVG(og.playtime_forever) as avg_playtime_minutes,
    ROUND(AVG(og.playtime_forever) / 60.0, 2) as avg_playtime_hours,
    MAX(og.playtime_forever) as max_playtime_minutes,
    ROUND(MAX(og.playtime_forever) / 60.0, 2) as max_playtime_hours
FROM steam_games g
JOIN steam_owned_games og ON g.id = og.game_id
GROUP BY g.id, g.name, g.appid
HAVING COUNT(og.player_id) > 0
ORDER BY avg_playtime_minutes DESC;

-- Functions for data processing
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to automatically update timestamps
CREATE TRIGGER update_steam_players_timestamp
    BEFORE UPDATE ON steam_players
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_steam_games_timestamp
    BEFORE UPDATE ON steam_games
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_steam_owned_games_timestamp
    BEFORE UPDATE ON steam_owned_games
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

-- Insert or update functions for upsert operations
CREATE OR REPLACE FUNCTION upsert_steam_player(
    p_steamid VARCHAR(20),
    p_personaname VARCHAR(255),
    p_profileurl TEXT,
    p_avatar TEXT,
    p_personastate INTEGER,
    p_communityvisibilitystate INTEGER,
    p_profilestate INTEGER,
    p_lastlogoff TIMESTAMP,
    p_timecreated TIMESTAMP
) RETURNS INTEGER AS $$
DECLARE
    player_id INTEGER;
BEGIN
    INSERT INTO steam_players (
        steamid, personaname, profileurl, avatar, personastate,
        communityvisibilitystate, profilestate, lastlogoff, timecreated
    ) VALUES (
        p_steamid, p_personaname, p_profileurl, p_avatar, p_personastate,
        p_communityvisibilitystate, p_profilestate, p_lastlogoff, p_timecreated
    )
    ON CONFLICT (steamid) DO UPDATE SET
        personaname = EXCLUDED.personaname,
        profileurl = EXCLUDED.profileurl,
        avatar = EXCLUDED.avatar,
        personastate = EXCLUDED.personastate,
        communityvisibilitystate = EXCLUDED.communityvisibilitystate,
        profilestate = EXCLUDED.profilestate,
        lastlogoff = EXCLUDED.lastlogoff,
        timecreated = EXCLUDED.timecreated,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO player_id;
    
    RETURN player_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION upsert_steam_game(
    p_appid INTEGER,
    p_name VARCHAR(500),
    p_img_icon_url VARCHAR(255),
    p_img_logo_url VARCHAR(255)
) RETURNS INTEGER AS $$
DECLARE
    game_id INTEGER;
BEGIN
    INSERT INTO steam_games (appid, name, img_icon_url, img_logo_url)
    VALUES (p_appid, p_name, p_img_icon_url, p_img_logo_url)
    ON CONFLICT (appid) DO UPDATE SET
        name = EXCLUDED.name,
        img_icon_url = EXCLUDED.img_icon_url,
        img_logo_url = EXCLUDED.img_logo_url,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO game_id;
    
    RETURN game_id;
END;
$$ LANGUAGE plpgsql;