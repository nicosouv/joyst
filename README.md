# JOYST - Journey Over Your Saved Titles

A comprehensive gaming analytics platform that extracts, processes, and visualizes Steam gaming data using modern data engineering practices and machine learning-ready infrastructure.

## Overview

JOYST is an end-to-end data platform for gaming analytics that combines:
- **Real-time data extraction** from Steam Web API
- **Distributed processing** with Apache Spark
- **Dual-database architecture** for operational and analytical workloads
- **Interactive dashboards** for gaming insights
- **ML-ready data warehouse** for game recommendations

## Architecture

```
Steam API → Spark Processing → PostgreSQL (Operational)
                            → ClickHouse (Analytics) → Metabase Dashboards
                            → JSON (Backup)
```

### Core Components:
- **🎮 Steam API Integration**: Real-time player and game data extraction
- **⚡ Apache Spark**: Distributed data processing and transformation
- **🐘 PostgreSQL**: Operational data store with ACID transactions
- **🔢 ClickHouse**: Columnar analytics warehouse optimized for ML
- **📊 Metabase**: Interactive dashboards and visualizations
- **🚀 Docker + OpenTofu**: Infrastructure as Code deployment

## Prerequisites

- Docker and Docker Compose
- OpenTofu >= 1.8.0
- Python 3.10+
- Steam API Key (get from [Steam Web API](https://steamcommunity.com/dev/apikey))
- GitHub Container Registry access (for custom Spark image)

## Quick Start

### 1. Setup Development Environment

```bash
# Clone and setup
git clone <repository>
cd joyst
task setup  # Installs dependencies and initializes OpenTofu
```

### 2. Configure Steam API

Update `config.json` with your Steam credentials:

```json
{
  "steam_api_key": "YOUR_STEAM_API_KEY",
  "steam_id": "YOUR_STEAM_ID_64_BIT",
  "output_path": "data/steam_account",
  "postgres_host": "localhost",
  "postgres_port": "5432",
  "postgres_db": "joyst_dw",
  "postgres_user": "admin",
  "postgres_password": "admin",
  "clickhouse_host": "localhost",
  "clickhouse_port": "9000",
  "clickhouse_db": "gaming_analytics",
  "clickhouse_user": "admin",
  "clickhouse_password": "admin123"
}
```

### 3. Deploy Complete Infrastructure

```bash
# Deploy all services (PostgreSQL, ClickHouse, Spark, Metabase)
task infra-up

# Check all service URLs
task urls
```

### 4. Build and Run Data Pipeline

```bash
# Build custom Spark image
task docker-build

# Run Steam data extraction and processing
task spark-submit
```

### 5. Access Dashboards

```bash
# View service URLs
task urls

# Open Metabase for dashboards
open http://localhost:3000
```

## Project Structure

```
├── .infrastructure/          # Build and deployment
│   ├── build.sh             # Docker image build script  
│   └── docker/
│       └── spark.Dockerfile # Custom Spark image
├── .github/workflows/       # CI/CD pipelines
├── spark_jobs/              # Spark job implementations
│   ├── src/
│   │   ├── steam_job.py     # Main Steam data processor
│   │   ├── database_writers.py # PostgreSQL & ClickHouse writers
│   │   ├── config.py        # Configuration management
│   │   └── base.py          # Spark session utilities
│   └── tests/               # Unit tests
├── sql/                     # Database schemas
│   ├── postgres/            # PostgreSQL schemas
│   │   ├── 01_steam_schema.sql
│   │   └── 02_seed_data.sql
│   └── clickhouse/          # ClickHouse schemas  
│       ├── 03_clickhouse_schema.sql
│       └── 04_clickhouse_seed_data.sql
├── tofu/                    # Infrastructure as Code
│   ├── modules/
│   │   ├── network/         # Docker networking
│   │   ├── postgres/        # PostgreSQL deployment
│   │   ├── clickhouse/      # ClickHouse deployment  
│   │   ├── spark/           # Spark cluster
│   │   ├── metabase/        # Dashboard service
│   │   └── prefect/         # Workflow orchestration
│   └── environments/
│       └── local/           # Local development config
├── config.json             # Application configuration
└── Makefile                 # Development commands
```

## Services & Access Points

| Service | URL | Purpose |
|---------|-----|---------|
| 📊 **Metabase** | http://localhost:3000 | Interactive dashboards and analytics |
| ⚡ **Spark Master UI** | http://localhost:8080 | Spark cluster monitoring |
| 🔢 **ClickHouse HTTP** | http://localhost:8123 | Analytics database interface |
| 🐘 **PostgreSQL** | localhost:5432 | Operational database |
| 🎯 **Prefect UI** | http://localhost:4200 | Workflow orchestration |

## Data Architecture

### PostgreSQL (Operational Store)
- **Purpose**: ACID transactions, referential integrity
- **Schema**: Normalized relational model
- **Tables**: `steam_players`, `steam_games`, `steam_owned_games`
- **Use Cases**: Data consistency, operational queries

### ClickHouse (Analytics Warehouse)  
- **Purpose**: Fast analytics, ML feature store
- **Schema**: Star schema with dimension and fact tables
- **Tables**: `dim_players`, `dim_games`, `fact_gaming_sessions`
- **Use Cases**: Analytics, reporting, ML model training

## Development

### Available Task Commands

```bash
task               # Show all available commands
task setup         # Complete development environment setup
task install       # Install Python dependencies
task test          # Run test suite
task lint          # Run code linting
task format        # Format code
task docker-build  # Build custom Spark image
task infra-up      # Deploy complete infrastructure
task infra-down    # Destroy infrastructure
task spark-submit  # Run Spark data processing job
task urls          # Show all service URLs
task clean         # Clean temporary files
```

### Configuration

Configuration priority (highest to lowest):
1. **Environment variables** 
2. **Config file** (`config.json`)
3. **Default values**

Key configuration options:

| Environment Variable | Config File Key | Default | Description |
|---------------------|----------------|---------|-------------|
| `STEAM_API_KEY` | `steam_api_key` | - | Steam Web API key |
| `STEAM_ID` | `steam_id` | - | Steam user ID (64-bit) |
| `POSTGRES_HOST` | `postgres_host` | `localhost` | PostgreSQL host |
| `CLICKHOUSE_HOST` | `clickhouse_host` | `localhost` | ClickHouse host |
| `SPARK_MASTER` | `spark_master` | `spark://localhost:7077` | Spark master URL |

## Data Pipeline

### Steam Web API Integration

The platform extracts comprehensive gaming data:

- **Player Summaries**: Profile information, creation dates, activity status
- **Owned Games**: Complete game library with playtime statistics
- **Recently Played Games**: Recent gaming activity and session data
- **Game Metadata**: Titles, images, categories, and playtime metrics

### Data Processing Flow

1. **Extract**: Steam API → Raw JSON data
2. **Transform**: Spark DataFrames → Structured schemas  
3. **Load**: 
   - PostgreSQL → Operational data (OLTP)
   - ClickHouse → Analytics data (OLAP)
   - JSON → Backup/debugging

### ML Features Ready

The ClickHouse warehouse includes ML-ready features:
- **Player behavior patterns**: Playtime, preferences, session duration
- **Game similarity metrics**: For collaborative filtering
- **Time-series data**: Seasonal patterns, trends
- **Feature engineering tables**: Pre-computed ML features

## Dashboards & Analytics

### Metabase Setup

1. **Access**: http://localhost:3000
2. **Add PostgreSQL datasource**:
   - Host: `localhost:5432`
   - Database: `joyst_dw`
   - User: `admin` / Password: `admin`

3. **Add ClickHouse datasource**:
   - Host: `localhost:8123` 
   - Database: `gaming_analytics`
   - User: `admin` / Password: `admin123`

### Dashboard Ideas

**Gaming Analytics**:
- Player activity timelines
- Game popularity rankings  
- Playtime distribution analysis
- Gaming session patterns

**ML Insights**:
- Player clustering and segmentation
- Game recommendation accuracy
- Seasonal gaming trends
- Player lifecycle analysis

## Infrastructure

### Local Environment Components

| Component | Purpose | Port |
|-----------|---------|------|
| **Spark Master** | Distributed processing coordinator | 8080 |
| **Spark Worker** | Processing node | - |
| **PostgreSQL** | Operational database | 5432 |
| **ClickHouse** | Analytics warehouse | 8123, 9000 |
| **Metabase** | Dashboard and BI tool | 3000 |
| **Prefect** | Workflow orchestration | 4200 |

### OpenTofu Modules

- **`network`**: Docker networking and service discovery
- **`postgres`**: Operational database with automatic schema setup
- **`clickhouse`**: Analytics warehouse with star schema
- **`spark`**: Distributed processing cluster (master + worker)  
- **`metabase`**: Dashboard service with database connections
- **`prefect`**: Workflow orchestration (future use)

## Next Steps

### Recommended Enhancements

1. **Machine Learning Models**:
   - Game recommendation engine using ClickHouse features
   - Player behavior prediction models
   - Seasonal gaming pattern analysis

2. **Advanced Analytics**:
   - Real-time streaming with Kafka
   - Advanced Spark ML pipelines  
   - A/B testing framework for recommendations

3. **Monitoring & Observability**:
   - Prometheus metrics collection
   - Grafana monitoring dashboards
   - Data quality checks and alerts

## Getting Your Steam ID

To find your Steam ID (64-bit format):

1. Visit [steamidfinder.com](https://www.steamidfinder.com/)
2. Enter your Steam profile URL (e.g., `https://steamcommunity.com/id/classquette`)
3. Copy the **SteamID64** value
4. Use this value in your `config.json`

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **Java Version Mismatch** | Use Docker containers instead of local Spark |
| **Database Connection Failed** | Ensure services are running: `make urls` |
| **Steam API Rate Limits** | Check API key validity and request frequency |
| **Permission Denied (ClickHouse data)** | Add `tofu/clickhouse-data/` to `.gitignore` |
| **Container Network Issues** | Restart infrastructure: `make infra-down && make infra-up` |

### Useful Commands

```bash
# Check service status
docker ps

# View service logs  
docker logs joyst-spark-master-local
docker logs joyst-postgres-local
docker logs joyst-clickhouse-local
docker logs joyst-metabase-local

# Restart specific service
docker restart joyst-metabase-local

# Clean and restart everything
task infra-down && task clean && task infra-up
```

### Development Workflow

```bash
# 1. Start development
task setup

# 2. Deploy infrastructure  
task infra-up

# 3. Make code changes
# Edit files in spark_jobs/src/

# 4. Test changes
task test && task lint

# 5. Rebuild and test pipeline
task docker-build
task spark-submit

# 6. Check results in Metabase
open http://localhost:3000
```

## License

This project is for personal use and learning purposes.

---

**JOYST** - Transform your Steam gaming data into actionable insights! 🎮📊✨