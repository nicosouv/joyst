-- ClickHouse Data Warehouse Seed Data
-- Sample data optimized for ML model training and game recommendations

-- Populate Time Dimension (2023-2024 data)
INSERT INTO dim_time
SELECT
    toUInt32(toYYYYMMDD(date)) as date_sk,
    date,
    toYear(date) as year,
    toQuarter(date) as quarter,
    toMonth(date) as month,
    toWeek(date) as week,
    toDayOfMonth(date) as day_of_month,
    toDayOfWeek(date) as day_of_week,
    toDayOfYear(date) as day_of_year,
    if(toDayOfWeek(date) IN (6, 7), 1, 0) as is_weekend,
    0 as is_holiday,
    case
        when toMonth(date) IN (3, 4, 5) then 'Spring'
        when toMonth(date) IN (6, 7, 8) then 'Summer'
        when toMonth(date) IN (9, 10, 11) then 'Fall'
        else 'Winter'
    end as season
FROM numbers(365 * 2)
WHERE addDays(toDate('2023-01-01'), number) <= today();

-- Populate Player Dimension
INSERT INTO dim_players VALUES
(1, '76561197960287930', 'GamerPro2024', 'https://steamcommunity.com/profiles/76561197960287930', 'avatar1.jpg', '2010-03-15', 3, 1, 'US', 'CA', 'SF', 1, now(), now()),
(2, '76561197960287931', 'CasualPlayer', 'https://steamcommunity.com/profiles/76561197960287931', 'avatar2.jpg', '2015-07-20', 3, 1, 'GB', '', 'LDN', 1, now(), now()),
(3, '76561197960287932', 'SpeedRunner99', 'https://steamcommunity.com/profiles/76561197960287932', 'avatar3.jpg', '2012-12-01', 3, 1, 'DE', '', 'BER', 1, now(), now()),
(4, '76561197960287933', 'RPGLover', 'https://steamcommunity.com/profiles/76561197960287933', 'avatar4.jpg', '2018-05-10', 3, 1, 'FR', '', 'PAR', 1, now(), now()),
(5, '76561197960287934', 'IndieGamer', 'https://steamcommunity.com/profiles/76561197960287934', 'avatar5.jpg', '2020-01-15', 3, 1, 'CA', 'ON', 'TOR', 1, now(), now());

-- Populate Game Dimension with rich metadata
INSERT INTO dim_games VALUES
-- Action/FPS Games
(1, 730, 'Counter-Strike 2', 'Competitive FPS', 'The premier competitive FPS experience', 'Valve', 'Valve', '2023-09-27', 0, 0, 0, 83, 1200000, 50000, '50-100 million', 1500000, 0, 0, 25, 167, 850, 420, 'cs2_icon.jpg', 'cs2_logo.jpg', 1, now(), now()),
(2, 570, 'Dota 2', 'MOBA Strategy', 'The ultimate MOBA experience', 'Valve', 'Valve', '2013-07-09', 0, 0, 0, 90, 800000, 30000, '100+ million', 1200000, 0, 0, 15, 200, 1200, 800, 'dota2_icon.jpg', 'dota2_logo.jpg', 1, now(), now()),
(3, 1172470, 'Apex Legends', 'Battle Royale FPS', 'Fast-paced battle royale', 'Respawn Entertainment', 'Electronic Arts', '2020-11-04', 0, 0, 0, 88, 950000, 45000, '100+ million', 300000, 0, 0, 8, 50, 450, 280, 'apex_icon.jpg', 'apex_logo.jpg', 1, now(), now()),

-- RPG Games  
(4, 1086940, 'Baldurs Gate 3', 'Turn-based RPG', 'Epic fantasy RPG adventure', 'Larian Studios', 'Larian Studios', '2023-08-03', 59.99, 59.99, 0, 96, 500000, 8000, '5-10 million', 875000, 0, 0, 12, 100, 6000, 4800, 'bg3_icon.jpg', 'bg3_logo.jpg', 1, now(), now()),
(5, 1245620, 'ELDEN RING', 'Action RPG', 'Open world dark fantasy', 'FromSoftware', 'Bandai Namco', '2022-02-25', 59.99, 49.99, 17, 96, 450000, 15000, '10-20 million', 953000, 0, 0, 5, 42, 3600, 2400, 'elden_icon.jpg', 'elden_logo.jpg', 1, now(), now()),
(6, 381210, 'Dead by Daylight', 'Survival Horror', 'Asymmetric multiplayer horror', 'Behaviour Interactive', 'Behaviour Interactive', '2016-06-14', 19.99, 19.99, 0, 79, 280000, 120000, '50+ million', 105000, 0, 0, 25, 150, 900, 450, 'dbd_icon.jpg', 'dbd_logo.jpg', 1, now(), now()),

-- Indie/Casual Games
(7, 413150, 'Stardew Valley', 'Farming Simulation', 'Relaxing farming and life sim', 'ConcernedApe', 'ConcernedApe', '2016-02-26', 14.99, 14.99, 0, 94, 180000, 3000, '10-20 million', 50000, 0, 0, 15, 40, 5000, 3600, 'stardew_icon.jpg', 'stardew_logo.jpg', 1, now(), now()),
(8, 646570, 'Slay the Spire', 'Deck-building Roguelike', 'Strategic card-based dungeon crawler', 'MegaCrit', 'MegaCrit', '2019-01-23', 24.99, 19.99, 20, 89, 85000, 2500, '2-5 million', 20000, 0, 0, 0, 57, 1200, 600, 'sts_icon.jpg', 'sts_logo.jpg', 1, now(), now()),

-- Strategy Games
(9, 294100, 'RimWorld', 'Colony Simulation', 'Sci-fi colony survival', 'Ludeon Studios', 'Ludeon Studios', '2018-10-17', 34.99, 34.99, 0, 87, 75000, 3500, '1-2 million', 35000, 0, 0, 8, 25, 4800, 2400, 'rimworld_icon.jpg', 'rimworld_logo.jpg', 1, now(), now()),
(10, 105600, 'Terraria', 'Sandbox Adventure', '2D sandbox adventure', 'Re-Logic', 'Re-Logic', '2011-05-16', 9.99, 9.99, 0, 83, 650000, 15000, '35+ million', 490000, 0, 0, 0, 88, 2400, 1200, 'terraria_icon.jpg', 'terraria_logo.jpg', 1, now(), now());

-- Populate Game Categories
INSERT INTO dim_game_categories VALUES
-- Counter-Strike 2
(1, 1, 'genre', 'Action'), (2, 1, 'genre', 'FPS'), (3, 1, 'category', 'Multiplayer'), (4, 1, 'tag', 'Competitive'),
-- Dota 2  
(5, 2, 'genre', 'Strategy'), (6, 2, 'genre', 'MOBA'), (7, 2, 'category', 'Multiplayer'), (8, 2, 'tag', 'Esports'),
-- Apex Legends
(9, 3, 'genre', 'Action'), (10, 3, 'genre', 'Battle Royale'), (11, 3, 'category', 'Multiplayer'), (12, 3, 'tag', 'Fast-Paced'),
-- Baldur's Gate 3
(13, 4, 'genre', 'RPG'), (14, 4, 'genre', 'Turn-Based'), (15, 4, 'category', 'Single-player'), (16, 4, 'tag', 'Story Rich'),
-- Elden Ring
(17, 5, 'genre', 'Action'), (18, 5, 'genre', 'RPG'), (19, 5, 'category', 'Single-player'), (20, 5, 'tag', 'Dark Fantasy'),
-- Dead by Daylight
(21, 6, 'genre', 'Horror'), (22, 6, 'genre', 'Survival'), (23, 6, 'category', 'Multiplayer'), (24, 6, 'tag', 'Asymmetric'),
-- Stardew Valley
(25, 7, 'genre', 'Simulation'), (26, 7, 'genre', 'Farming'), (27, 7, 'category', 'Single-player'), (28, 7, 'tag', 'Relaxing'),
-- Slay the Spire
(29, 8, 'genre', 'Strategy'), (30, 8, 'genre', 'Roguelike'), (31, 8, 'category', 'Single-player'), (32, 8, 'tag', 'Deck Building'),
-- RimWorld
(33, 9, 'genre', 'Simulation'), (34, 9, 'genre', 'Strategy'), (35, 9, 'category', 'Single-player'), (36, 9, 'tag', 'Colony Sim'),
-- Terraria
(37, 10, 'genre', 'Adventure'), (38, 10, 'genre', 'Sandbox'), (39, 10, 'category', 'Single-player'), (40, 10, 'tag', '2D');

-- Populate Game Purchases
INSERT INTO fact_game_purchases VALUES
-- GamerPro2024 purchases
(1, 1, 1, 20231201, '2023-12-01 15:30:00', 0, 0, 'Free', 0, NULL, 12480, '2024-01-15 14:00:00', now()),
(2, 1, 2, 20231201, '2023-12-01 15:35:00', 0, 0, 'Free', 0, NULL, 8760, '2024-01-10 20:00:00', now()),
(3, 1, 4, 20231203, '2023-12-03 19:20:00', 59.99, 0, 'Store', 0, NULL, 4320, '2024-01-14 16:00:00', now()),

-- CasualPlayer purchases  
(4, 2, 1, 20240101, '2024-01-01 12:00:00', 0, 0, 'Free', 0, NULL, 6000, '2024-01-14 18:30:00', now()),
(5, 2, 3, 20240101, '2024-01-01 12:05:00', 0, 0, 'Free', 0, NULL, 2880, '2024-01-13 19:00:00', now()),
(6, 2, 7, 20240105, '2024-01-05 16:30:00', 14.99, 0, 'Store', 0, NULL, 14400, '2024-01-14 17:00:00', now()),

-- SpeedRunner99 purchases
(7, 3, 5, 20231215, '2023-12-15 20:45:00', 49.99, 17, 'Store', 0, NULL, 10800, '2024-01-13 21:45:00', now()),
(8, 3, 8, 20240110, '2024-01-10 14:15:00', 19.99, 20, 'Store', 0, NULL, 3600, '2024-01-12 22:30:00', now()),
(9, 3, 10, 20240112, '2024-01-12 11:20:00', 9.99, 0, 'Store', 0, NULL, 7200, '2024-01-15 13:45:00', now()),

-- RPGLover purchases
(10, 4, 4, 20230803, '2023-08-03 10:00:00', 59.99, 0, 'Store', 0, NULL, 18000, '2024-01-14 20:30:00', now()),
(11, 4, 5, 20230225, '2023-02-25 18:30:00', 59.99, 0, 'Store', 0, NULL, 24000, '2024-01-13 19:15:00', now()),
(12, 4, 9, 20231020, '2023-10-20 13:45:00', 34.99, 0, 'Store', 0, NULL, 9600, '2024-01-15 16:20:00', now()),

-- IndieGamer purchases
(13, 5, 7, 20240201, '2024-02-01 09:30:00', 14.99, 0, 'Store', 0, NULL, 18000, '2024-01-15 21:00:00', now()),
(14, 5, 8, 20240205, '2024-02-05 15:45:00', 19.99, 20, 'Store', 0, NULL, 4800, '2024-01-14 14:30:00', now()),
(15, 5, 9, 20240210, '2024-02-10 12:15:00', 34.99, 0, 'Store', 0, NULL, 7200, '2024-01-13 17:45:00', now());

-- Populate Gaming Sessions (realistic patterns)
INSERT INTO fact_gaming_sessions VALUES
-- GamerPro2024 sessions (competitive player, long sessions)
(1, 1, 1, 20240115, '2024-01-15 13:00:00', '2024-01-15 14:30:00', 90, 12480, 2, 0, 'Windows', now()),
(2, 1, 1, 20240114, '2024-01-14 19:00:00', '2024-01-14 21:00:00', 120, 12390, 1, 0, 'Windows', now()),
(3, 1, 4, 20240114, '2024-01-14 15:00:00', '2024-01-14 18:00:00', 180, 4320, 3, 0, 'Windows', now()),
(4, 1, 2, 20240110, '2024-01-10 18:00:00', '2024-01-10 20:30:00', 150, 8760, 0, 0, 'Windows', now()),

-- CasualPlayer sessions (shorter, varied games)
(5, 2, 1, 20240114, '2024-01-14 17:30:00', '2024-01-14 18:30:00', 60, 6000, 0, 0, 'Windows', now()),
(6, 2, 7, 20240114, '2024-01-14 16:00:00', '2024-01-14 18:00:00', 120, 14400, 1, 0, 'Windows', now()),
(7, 2, 3, 20240113, '2024-01-13 18:00:00', '2024-01-13 19:00:00', 60, 2880, 1, 0, 'Windows', now()),

-- SpeedRunner99 sessions (intense, optimization focused)
(8, 3, 5, 20240113, '2024-01-13 20:00:00', '2024-01-13 23:00:00', 180, 10800, 5, 0, 'SteamDeck', now()),
(9, 3, 8, 20240112, '2024-01-12 21:00:00', '2024-01-12 23:30:00', 150, 3600, 8, 0, 'SteamDeck', now()),
(10, 3, 10, 20240115, '2024-01-15 12:00:00', '2024-01-15 15:00:00', 180, 7200, 12, 0, 'SteamDeck', now()),

-- RPGLover sessions (long, immersive sessions)
(11, 4, 4, 20240114, '2024-01-14 18:00:00', '2024-01-14 22:00:00', 240, 18000, 4, 0, 'Windows', now()),
(12, 4, 5, 20240113, '2024-01-13 17:00:00', '2024-01-13 20:00:00', 180, 24000, 2, 0, 'Windows', now()),
(13, 4, 9, 20240115, '2024-01-15 14:00:00', '2024-01-15 18:00:00', 240, 9600, 6, 0, 'Windows', now()),

-- IndieGamer sessions (exploratory, diverse)
(14, 5, 7, 20240115, '2024-01-15 19:00:00', '2024-01-15 22:00:00', 180, 18000, 2, 0, 'Mac', now()),
(15, 5, 8, 20240114, '2024-01-14 13:00:00', '2024-01-14 15:30:00', 150, 4800, 5, 0, 'Mac', now()),
(16, 5, 9, 20240113, '2024-01-13 16:00:00', '2024-01-13 19:00:00', 180, 7200, 3, 0, 'Mac', now());

-- Sample data for ML features tables
INSERT INTO player_behavior_features VALUES
(1, '2024-01-15', 850.5, ['Action', 'FPS', 'RPG'], 135.0, 8.5, 0.85, 1.2, 0.6, 0.3),
(2, '2024-01-15', 320.0, ['Simulation', 'Action', 'FPS'], 85.0, 4.2, 0.65, 0.8, 0.7, 0.8),
(3, '2024-01-15', 420.5, ['Action', 'Strategy', 'Adventure'], 170.0, 6.0, 0.95, 1.5, 0.8, 0.4),
(4, '2024-01-15', 680.0, ['RPG', 'Strategy'], 200.0, 3.5, 0.75, 0.9, 0.4, 0.2),
(5, '2024-01-15', 280.5, ['Simulation', 'Strategy'], 170.0, 5.5, 0.80, 1.1, 0.9, 0.6);

INSERT INTO game_similarity_features VALUES
(1, 3, 0.75, 850, 0.8, 0.65, now()), -- CS2 vs Apex (both FPS)
(4, 5, 0.85, 650, 0.6, 0.80, now()), -- BG3 vs Elden Ring (both RPG)
(7, 9, 0.70, 420, 0.7, 0.55, now()), -- Stardew vs RimWorld (both sim)
(8, 10, 0.60, 280, 0.3, 0.45, now()); -- Slay the Spire vs Terraria