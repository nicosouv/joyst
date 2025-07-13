FROM apache/spark:4.0.0-python3

USER root

# Install Python dependencies
COPY pyproject.toml /opt/spark/work-dir/
WORKDIR /opt/spark/work-dir

# Install uv for faster dependency management
RUN pip install uv

# Copy source code
COPY spark_jobs/ /opt/spark/work-dir/spark_jobs/
COPY pipelines/ /opt/spark/work-dir/pipelines/
COPY dags/ /opt/spark/work-dir/dags/

# Install project in development mode
RUN uv pip install --system -e .

# Set Python path
ENV PYTHONPATH=/opt/spark/work-dir:$PYTHONPATH

# Switch back to spark user
USER spark

WORKDIR /opt/spark/work-dir