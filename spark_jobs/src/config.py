import json
import os
from pathlib import Path
from typing import Any


class Config:
    """Configuration manager with environment variable fallback"""

    def __init__(self, config_file: str | None = None):
        if config_file is None:
            # Look for config.json in project root (two levels up from spark_jobs/src/)
            project_root = Path(__file__).parent.parent.parent
            self.config_file = str(project_root / "config.json")
        else:
            self.config_file = config_file
        self.config_data = self._load_config()

    def _load_config(self) -> dict[str, Any]:
        """Load configuration from file if it exists"""
        config_path = Path(self.config_file)

        if config_path.exists():
            try:
                with open(config_path) as f:
                    return json.load(f)
            except (OSError, json.JSONDecodeError) as e:
                print(f"Warning: Could not load config file {self.config_file}: {e}")
                return {}
        else:
            print(f"Config file {self.config_file} not found, using environment variables only")
            return {}

    def get(self, key: str, default: Any = None, env_var: str | None = None) -> Any:
        """
        Get configuration value with environment variable fallback

        Priority:
        1. Environment variable (if env_var is specified)
        2. Config file value
        3. Default value
        """
        # Check environment variable first (if specified)
        if env_var:
            env_value = os.getenv(env_var)
            if env_value is not None:
                return env_value

        # Check config file
        if key in self.config_data:
            return self.config_data[key]

        # Return default
        return default

    def get_steam_config(self) -> dict[str, str]:
        """Get Steam API configuration"""
        return {
            "api_key": self.get("steam_api_key", env_var="STEAM_API_KEY"),
            "steam_id": self.get("steam_id", env_var="STEAM_ID"),
            "output_path": self.get(
                "output_path", "data/steam_account", env_var="STEAM_OUTPUT_PATH"
            ),
        }

    def get_spark_config(self) -> dict[str, str]:
        """Get Spark configuration"""
        return {
            "master": self.get("spark_master", "spark://localhost:7077", env_var="SPARK_MASTER"),
            "app_name": self.get(
                "spark_app_name", "steam-account-processor", env_var="SPARK_APP_NAME"
            ),
            "shuffle_partitions": self.get(
                "spark_shuffle_partitions", "4", env_var="SPARK_SHUFFLE_PARTITIONS"
            ),
        }

    def get_postgres_config(self) -> dict[str, str]:
        """Get PostgreSQL configuration"""
        return {
            "host": self.get("postgres_host", "localhost", env_var="POSTGRES_HOST"),
            "port": self.get("postgres_port", "5432", env_var="POSTGRES_PORT"),
            "database": self.get("postgres_db", "joyst_dw", env_var="POSTGRES_DB"),
            "user": self.get("postgres_user", "admin", env_var="POSTGRES_USER"),
            "password": self.get("postgres_password", env_var="POSTGRES_PASSWORD"),
        }

    def get_clickhouse_config(self) -> dict[str, str]:
        """Get ClickHouse configuration"""
        return {
            "host": self.get("clickhouse_host", "localhost", env_var="CLICKHOUSE_HOST"),
            "port": self.get("clickhouse_port", "9000", env_var="CLICKHOUSE_PORT"),
            "database": self.get("clickhouse_db", "gaming_analytics", env_var="CLICKHOUSE_DB"),
            "user": self.get("clickhouse_user", "admin", env_var="CLICKHOUSE_USER"),
            "password": self.get("clickhouse_password", env_var="CLICKHOUSE_PASSWORD"),
        }
