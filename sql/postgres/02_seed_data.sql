-- Seed data for JOYST Steam analytics platform
-- Run after steam_schema.sql to populate initial data

-- Insert sample Steam games (popular titles for testing)
INSERT INTO steam_games (appid, name, img_icon_url, img_logo_url) VALUES
(730, 'Counter-Strike 2', '69f7ebe2735c7c6ecfd1de48c6fc6e15d635bd2b', 'ef4cf001bb99e5bab0ec0d5b15b9e3e4a999fd61'),
(570, 'Dota 2', 'd4f5467db4edacc8cbfc3ca8f9ba2b9e0f8c2b4f', 'eca1642c9bb50b3a3d94b4a76a2c9b95e3d9c5e8'),
(440, 'Team Fortress 2', '6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b', '1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b'),
(1172470, 'Apex Legends', 'f8e7d6c5b4a39283746561728394057482930174', '2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c'),
(1086940, 'Baldur''s Gate 3', 'a1b2c3d4e5f6789abcdef0123456789abcdef012', '9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b'),
(1245620, 'ELDEN RING', '3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a', 'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0'),
(271590, 'Grand Theft Auto V', '6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d', 'd5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4'),
(413150, 'Stardew Valley', 'e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7', 'f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6');

-- Insert sample player data (anonymized for testing)
INSERT INTO steam_players (steamid, personaname, profileurl, avatar, personastate, communityvisibilitystate, profilestate, lastlogoff, timecreated) VALUES
('76561197960287930', 'TestPlayer1', 'https://steamcommunity.com/profiles/76561197960287930', 'https://avatars.akamai.steamstatic.com/default_avatar.jpg', 1, 3, 1, '2024-01-15 14:30:00', '2010-03-15 10:00:00'),
('76561197960287931', 'TestPlayer2', 'https://steamcommunity.com/profiles/76561197960287931', 'https://avatars.akamai.steamstatic.com/default_avatar.jpg', 0, 3, 1, '2024-01-14 18:45:00', '2011-07-20 15:30:00'),
('76561197960287932', 'TestPlayer3', 'https://steamcommunity.com/profiles/76561197960287932', 'https://avatars.akamai.steamstatic.com/default_avatar.jpg', 3, 3, 1, '2024-01-13 22:15:00', '2012-12-01 09:45:00');

-- Insert sample owned games data
INSERT INTO steam_owned_games (player_id, game_id, appid, playtime_forever, playtime_2weeks, last_played) VALUES
-- TestPlayer1 games
(1, 1, 730, 12480, 180, '2024-01-15 14:00:00'),  -- CS2: 208 hours total, 3 hours recent
(1, 2, 570, 8760, 0, '2024-01-10 20:00:00'),     -- Dota 2: 146 hours total, no recent
(1, 5, 1086940, 4320, 120, '2024-01-14 16:00:00'), -- Baldur's Gate 3: 72 hours total, 2 hours recent

-- TestPlayer2 games  
(2, 1, 730, 6000, 300, '2024-01-14 18:30:00'),    -- CS2: 100 hours total, 5 hours recent
(2, 4, 1172470, 2880, 90, '2024-01-13 19:00:00'), -- Apex: 48 hours total, 1.5 hours recent
(2, 8, 413150, 14400, 240, '2024-01-14 17:00:00'), -- Stardew: 240 hours total, 4 hours recent

-- TestPlayer3 games
(3, 3, 440, 1800, 0, '2024-01-05 15:00:00'),      -- TF2: 30 hours total, no recent
(3, 6, 1245620, 10800, 420, '2024-01-13 21:45:00'), -- Elden Ring: 180 hours total, 7 hours recent
(3, 7, 271590, 7200, 60, '2024-01-12 14:00:00');   -- GTA V: 120 hours total, 1 hour recent

-- Insert sample recently played data (last 2 weeks activity)
INSERT INTO steam_recently_played (player_id, game_id, appid, playtime_forever, playtime_2weeks, recorded_at) VALUES
(1, 1, 730, 12480, 180, '2024-01-15 14:00:00'),
(1, 5, 1086940, 4320, 120, '2024-01-14 16:00:00'),
(2, 1, 730, 6000, 300, '2024-01-14 18:30:00'),
(2, 8, 413150, 14400, 240, '2024-01-14 17:00:00'),
(2, 4, 1172470, 2880, 90, '2024-01-13 19:00:00'),
(3, 6, 1245620, 10800, 420, '2024-01-13 21:45:00'),
(3, 7, 271590, 7200, 60, '2024-01-12 14:00:00');

-- Verify data insertion
SELECT 'Players' as table_name, COUNT(*) as count FROM steam_players
UNION ALL
SELECT 'Games' as table_name, COUNT(*) as count FROM steam_games  
UNION ALL
SELECT 'Owned Games' as table_name, COUNT(*) as count FROM steam_owned_games
UNION ALL
SELECT 'Recently Played' as table_name, COUNT(*) as count FROM steam_recently_played;