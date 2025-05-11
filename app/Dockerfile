# Use a minimal base image with Python
FROM python:3.12-slim

# Create a non-root user
RUN useradd -m simpleuser

# Set work directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app code
COPY main.py .

# Ensure permissions
RUN chown -R simpleuser:simpleuser /app

# Switch to non-root user
USER simpleuser

# Expose port
EXPOSE 8080

# Run the application
CMD ["python", "main.py"]