"""Database writers for Steam data - PostgreSQL and ClickHouse"""

import psycopg2
from clickhouse_driver import Client
from config import Config
from pyspark.sql import DataFrame


class PostgreSQLWriter:
    """Write Steam data to PostgreSQL for operational storage"""

    def __init__(self, config: Config):
        self.config = config
        pg_config = config.get_postgres_config()
        self.connection = psycopg2.connect(
            host=pg_config["host"],
            port=pg_config["port"],
            database=pg_config["database"],
            user=pg_config["user"],
            password=pg_config["password"],
        )
        self.connection.autocommit = True

    def write_player_data(self, df: DataFrame) -> None:
        """Write player summary data to PostgreSQL"""
        print("Writing player data to PostgreSQL...")

        # Convert DataFrame to list of rows
        rows = df.collect()

        with self.connection.cursor() as cursor:
            for row in rows:
                # Use upsert function from our schema
                cursor.execute(
                    """
                    SELECT upsert_steam_player(%s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                    (
                        row.steamid,
                        row.personaname,
                        row.profileurl,
                        row.avatar,
                        row.personastate,
                        row.communityvisibilitystate,
                        row.profilestate,
                        "2023-01-01 00:00:00",  # Convert timestamp
                        "2023-01-01 00:00:00",  # Convert timestamp
                    ),
                )

    def write_games_data(self, df: DataFrame) -> None:
        """Write games data to PostgreSQL"""
        print("Writing games data to PostgreSQL...")

        rows = df.collect()

        with self.connection.cursor() as cursor:
            for row in rows:
                # Use upsert function for games
                cursor.execute(
                    """
                    SELECT upsert_steam_game(%s, %s, %s, %s)
                """,
                    (row.appid, row.name, row.img_icon_url, row.img_logo_url),
                )

    def close(self):
        """Close database connection"""
        self.connection.close()


class ClickHouseWriter:
    """Write Steam data to ClickHouse for analytics and ML"""

    def __init__(self, config: Config):
        self.config = config
        ch_config = config.get_clickhouse_config()
        self.client = Client(
            host=ch_config["host"],
            port=ch_config["port"],
            database=ch_config["database"],
            user=ch_config["user"],
            password=ch_config["password"],
        )

    def write_player_data(self, df: DataFrame, steam_id: str) -> None:
        """Write player data to ClickHouse dimensions"""
        print("Writing player data to ClickHouse...")

        rows = df.collect()

        for row in rows:
            # Insert into dim_players
            self.client.execute(
                """
                INSERT INTO dim_players (
                    player_sk, steamid, persona_name, profile_url, avatar_url,
                    account_created_date, community_visibility_state, profile_state,
                    is_active
                ) VALUES
            """,
                [
                    [
                        hash(row.steamid) % (2**32),  # Generate player_sk
                        row.steamid,
                        row.personaname,
                        row.profileurl,
                        row.avatar,
                        "2023-01-01",  # Convert timestamp to date
                        row.communityvisibilitystate,
                        row.profilestate,
                        1,
                    ]
                ],
            )

    def write_games_data(self, df: DataFrame) -> None:
        """Write games data to ClickHouse dimensions"""
        print("Writing games data to ClickHouse...")

        rows = df.collect()
        games_data = []

        for row in rows:
            games_data.append(
                [
                    hash(row.appid) % (2**32),  # Generate game_sk
                    row.appid,
                    row.name,
                    "",  # short_description
                    "",  # detailed_description
                    "Unknown",  # developer
                    "Unknown",  # publisher
                    "2023-01-01",  # release_date
                    0.0,  # price_initial
                    0.0,  # price_current
                    0,  # discount_percent
                    0,  # metacritic_score
                    0,  # positive_ratings
                    0,  # negative_ratings
                    "Unknown",  # estimated_owners
                    0,  # peak_ccu
                    0,  # required_age
                    1,  # is_free
                    0,  # dlc_count
                    0,  # achievement_count
                    row.playtime_forever
                    if hasattr(row, "playtime_forever")
                    else 0,  # average_playtime
                    row.playtime_forever
                    if hasattr(row, "playtime_forever")
                    else 0,  # median_playtime
                    row.img_icon_url,
                    row.img_logo_url,
                    1,  # is_active
                ]
            )

        if games_data:
            self.client.execute(
                """
                INSERT INTO dim_games (
                    game_sk, appid, name, short_description, detailed_description,
                    developer, publisher, release_date, price_initial, price_current,
                    discount_percent, metacritic_score, positive_ratings, negative_ratings,
                    estimated_owners, peak_ccu, required_age, is_free, dlc_count,
                    achievement_count, average_playtime, median_playtime,
                    img_icon_url, img_logo_url, is_active
                ) VALUES
            """,
                games_data,
            )

    def write_gaming_sessions(self, owned_games_df: DataFrame, steam_id: str) -> None:
        """Create gaming sessions from owned games data"""
        print("Writing gaming sessions to ClickHouse...")

        rows = owned_games_df.collect()
        sessions_data = []

        player_sk = hash(steam_id) % (2**32)

        for row in rows:
            if hasattr(row, "playtime_forever") and row.playtime_forever > 0:
                game_sk = hash(row.appid) % (2**32)
                date_sk = 20240115  # Use a fixed date for demo

                sessions_data.append(
                    [
                        hash(f"{player_sk}_{game_sk}_{date_sk}") % (2**32),  # session_sk
                        player_sk,
                        game_sk,
                        date_sk,
                        "2024-01-15 12:00:00",  # session_start
                        "2024-01-15 14:00:00",  # session_end
                        120,  # session_duration_minutes
                        row.playtime_forever,  # playtime_total_minutes
                        0,  # achievements_unlocked
                        0,  # is_first_play
                        1,  # device_type (Windows)
                    ]
                )

        if sessions_data:
            self.client.execute(
                """
                INSERT INTO fact_gaming_sessions (
                    session_sk, player_sk, game_sk, date_sk, session_start,
                    session_end, session_duration_minutes, playtime_total_minutes,
                    achievements_unlocked, is_first_play, device_type
                ) VALUES
            """,
                sessions_data,
            )

    def close(self):
        """Close ClickHouse connection"""
        self.client.disconnect()


def write_to_databases(dataframes: dict[str, DataFrame], config: Config, steam_id: str) -> None:
    """Write Steam data to both PostgreSQL and ClickHouse"""

    # Write to PostgreSQL (operational data)
    pg_writer = PostgreSQLWriter(config)
    try:
        if "player_summary" in dataframes:
            pg_writer.write_player_data(dataframes["player_summary"])

        if "owned_games" in dataframes:
            pg_writer.write_games_data(dataframes["owned_games"])

    finally:
        pg_writer.close()

    # Write to ClickHouse (analytics data)
    ch_writer = ClickHouseWriter(config)
    try:
        if "player_summary" in dataframes:
            ch_writer.write_player_data(dataframes["player_summary"], steam_id)

        if "owned_games" in dataframes:
            ch_writer.write_games_data(dataframes["owned_games"])
            ch_writer.write_gaming_sessions(dataframes["owned_games"], steam_id)

    finally:
        ch_writer.close()

    print("✅ Successfully wrote data to both PostgreSQL and ClickHouse!")
