import requests
from typing import Dict, Any
from pyspark.sql import DataFrame, SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
from base import get_spark_session
from config import Config


class SteamAPIClient:
    def __init__(self, api_key: str, steam_id: str):
        self.api_key = api_key
        self.steam_id = steam_id
        self.base_url = "https://api.steampowered.com"
    
    def get_player_summaries(self) -> Dict[str, Any]:
        """Get basic player profile information"""
        url = f"{self.base_url}/ISteamUser/GetPlayerSummaries/v0002/"
        params = {
            "key": self.api_key,
            "steamids": self.steam_id,
            "format": "json"
        }
        response = requests.get(url, params=params)
        return response.json()
    
    def get_owned_games(self) -> Dict[str, Any]:
        """Get list of games owned by the player"""
        url = f"{self.base_url}/IPlayerService/GetOwnedGames/v0001/"
        params = {
            "key": self.api_key,
            "steamid": self.steam_id,
            "format": "json",
            "include_appinfo": True,
            "include_played_free_games": True
        }
        response = requests.get(url, params=params)
        return response.json()
    
    def get_recently_played_games(self) -> Dict[str, Any]:
        """Get recently played games"""
        url = f"{self.base_url}/IPlayerService/GetRecentlyPlayedGames/v0001/"
        params = {
            "key": self.api_key,
            "steamid": self.steam_id,
            "format": "json",
            "count": 100
        }
        response = requests.get(url, params=params)
        return response.json()
    
    def get_player_achievements(self, app_id: int) -> Dict[str, Any]:
        """Get player achievements for a specific game"""
        url = f"{self.base_url}/ISteamUserStats/GetPlayerAchievements/v0001/"
        params = {
            "key": self.api_key,
            "steamid": self.steam_id,
            "appid": app_id,
            "format": "json"
        }
        response = requests.get(url, params=params)
        return response.json()
    
    def get_user_stats_for_game(self, app_id: int) -> Dict[str, Any]:
        """Get user statistics for a specific game"""
        url = f"{self.base_url}/ISteamUserStats/GetUserStatsForGame/v0002/"
        params = {
            "key": self.api_key,
            "steamid": self.steam_id,
            "appid": app_id,
            "format": "json"
        }
        response = requests.get(url, params=params)
        return response.json()


def fetch_steam_data(api_key: str, steam_id: str) -> Dict[str, Any]:
    """Fetch comprehensive Steam account data"""
    client = SteamAPIClient(api_key, steam_id)
    
    data = {
        "player_summary": client.get_player_summaries(),
        "owned_games": client.get_owned_games(),
        "recently_played": client.get_recently_played_games()
    }
    
    return data


def create_steam_dataframes(spark: SparkSession, steam_data: Dict[str, Any]) -> Dict[str, DataFrame]:
    """Convert Steam API data to Spark DataFrames"""
    
    # Player summary schema
    player_schema = StructType([
        StructField("steamid", StringType(), True),
        StructField("personaname", StringType(), True),
        StructField("profileurl", StringType(), True),
        StructField("avatar", StringType(), True),
        StructField("personastate", IntegerType(), True),
        StructField("communityvisibilitystate", IntegerType(), True),
        StructField("profilestate", IntegerType(), True),
        StructField("lastlogoff", IntegerType(), True),
        StructField("timecreated", IntegerType(), True)
    ])
    
    # Games schema
    games_schema = StructType([
        StructField("appid", IntegerType(), True),
        StructField("name", StringType(), True),
        StructField("playtime_forever", IntegerType(), True),
        StructField("playtime_2weeks", IntegerType(), True),
        StructField("img_icon_url", StringType(), True),
        StructField("img_logo_url", StringType(), True)
    ])
    
    dataframes = {}
    
    # Create player summary DataFrame
    if "player_summary" in steam_data and "response" in steam_data["player_summary"]:
        players = steam_data["player_summary"]["response"]["players"]
        if players:
            player_df = spark.createDataFrame(players, player_schema)
            dataframes["player_summary"] = player_df
    
    # Create owned games DataFrame
    if "owned_games" in steam_data and "response" in steam_data["owned_games"]:
        games = steam_data["owned_games"]["response"].get("games", [])
        if games:
            games_df = spark.createDataFrame(games, games_schema)
            dataframes["owned_games"] = games_df
    
    # Create recently played games DataFrame
    if "recently_played" in steam_data and "response" in steam_data["recently_played"]:
        recent_games = steam_data["recently_played"]["response"].get("games", [])
        if recent_games:
            recent_df = spark.createDataFrame(recent_games, games_schema)
            dataframes["recently_played"] = recent_df
    
    return dataframes


def process_steam_account_data(config_file: str = None) -> None:
    """Main function to process Steam account data"""
    config = Config(config_file)
    steam_config = config.get_steam_config()
    
    # Validate required configuration
    if not steam_config["api_key"] or not steam_config["steam_id"]:
        raise ValueError("Steam API key and Steam ID must be provided via config file or environment variables")
    
    spark = get_spark_session("steam-account-processor", config)
    
    # Fetch data from Steam API
    print("Fetching Steam account data...")
    steam_data = fetch_steam_data(steam_config["api_key"], steam_config["steam_id"])
    
    # Convert to DataFrames
    print("Creating Spark DataFrames...")
    dataframes = create_steam_dataframes(spark, steam_data)
    
    # Save DataFrames
    for name, df in dataframes.items():
        print(f"Processing {name}...")
        df.show(10)
        df.coalesce(1).write.mode("overwrite").json(f"{steam_config['output_path']}/{name}")
        print(f"Saved {name} to {steam_config['output_path']}/{name}")
    
    spark.stop()


def main() -> None:
    import sys
    config_file = sys.argv[1] if len(sys.argv) > 1 else None
    process_steam_account_data(config_file)


if __name__ == "__main__":
    main()
