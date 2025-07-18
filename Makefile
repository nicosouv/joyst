.PHONY: help install test lint format tf-fmt tf-lint tf-validate docker-build docker-push clean all

# Default target
help:
	@echo "Available targets:"
	@echo "  install      - Install Python dependencies"
	@echo "  test         - Run Python tests"
	@echo "  lint         - Run Python linting (ruff)"
	@echo "  format       - Format Python code (ruff)"
	@echo "  format-check - Check Python formatting"
	@echo "  tf-fmt       - Format OpenTofu files"
	@echo "  tf-fmt-check - Check OpenTofu formatting"
	@echo "  tf-lint      - Run OpenTofu linting (tflint)"
	@echo "  tf-validate  - Validate OpenTofu configuration"
	@echo "  tf-init      - Initialize OpenTofu"
	@echo "  docker-build - Build Docker image"
	@echo "  docker-push  - Push Docker image to registry"
	@echo "  clean        - Clean up temporary files"
	@echo "  all          - Run all checks (format, lint, test)"
	@echo "  urls         - Show URLs for all services"

# Python targets
install:
	uv venv --python 3.10
	uv pip install -e .
	uv pip install ruff pytest

test:
	uv run python -m pytest spark_jobs/tests/ -v

lint:
	uv run ruff check .

format:
	uv run ruff format .

format-check:
	uv run ruff format --check .

# OpenTofu targets
tf-fmt:
	tofu fmt -recursive terraform/

tf-fmt-check:
	tofu fmt -check -recursive terraform/

tf-lint:
	cd terraform && tflint --init && tflint

tf-validate:
	cd terraform && tofu validate

tf-init:
	cd terraform && tofu init

# Docker targets
docker-build:
	CR_PAT=$(CR_PAT) .infrastructure/build.sh spark

docker-push: docker-build

# Infrastructure targets
infra-up:
	cd terraform && tofu init && tofu apply -var-file="environments/local/local.tfvars" -auto-approve

infra-down:
	cd terraform && tofu destroy -var-file="environments/local/local.tfvars" -auto-approve

infra-plan:
	cd terraform && tofu plan -var-file="environments/local/local.tfvars"

# Spark job targets
spark-submit:
	docker run --rm \
		-v $(PWD):/opt/spark/work-dir \
		ghcr.io/nicosouv/joyst-spark:latest \
		spark-submit --master spark://joyst-spark-master-local:7077 spark_jobs/src/steam_job.py

# Clean up
clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name ".pytest_cache" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf .venv/
	rm -rf build/
	rm -rf dist/

# Run all checks
all: format-check lint test tf-fmt-check tf-validate

# URLs for accessing services
urls:
	@echo "🚀 JOYST Services:"
	@echo "📊 Metabase Dashboard:  http://localhost:3000"
	@echo "⚡ Spark Master UI:     http://localhost:8080"
	@echo "🔢 ClickHouse HTTP:     http://localhost:8123"
	@echo "🐘 PostgreSQL:          localhost:5432"
	@echo "🎯 Prefect UI:          http://localhost:4200"

# Development setup
setup: install tf-init
	@echo "Development environment setup complete!"
	@echo "Run 'make urls' to see service URLs"
	@echo "Run 'make help' to see available commands"