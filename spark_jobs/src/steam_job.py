from pyspark.sql import DataFrame
from spark_jobs.base import get_spark_session


def load_steam_games(path: str) -> DataFrame:
    spark = get_spark_session("steam-games-loader")
    return spark.read.json(path)


def main() -> None:
    df = load_steam_games("data/steam_games.json")
    df.printSchema()
    df.show(5)


if __name__ == "__main__":
    main()
