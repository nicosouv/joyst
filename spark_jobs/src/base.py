from pyspark.sql import SparkSession

def get_spark_session(app_name: str = "joyst") -> SparkSession:
    return (
        SparkSession.builder
        .appName(app_name)
        .master("spark://localhost:7077")  # si cluster Docker
        .config("spark.sql.shuffle.partitions", "4")
        .getOrCreate()
    )
