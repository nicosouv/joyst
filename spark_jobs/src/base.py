from pyspark.sql import SparkSession
from config import Config

def get_spark_session(app_name: str = "joyst", config: Config = None) -> SparkSession:
    if config is None:
        config = Config()
    
    spark_config = config.get_spark_config()
    
    return (
        SparkSession.builder
        .appName(spark_config.get("app_name", app_name))
        .master(spark_config["master"])
        .config("spark.sql.shuffle.partitions", spark_config["shuffle_partitions"])
        .getOrCreate()
    )
