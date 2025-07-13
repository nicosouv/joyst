from spark_jobs import steam_job


def test_load_schema():
    df = steam_job.load_steam_games("tests/sample_steam.json")
    assert "name" in df.columns
