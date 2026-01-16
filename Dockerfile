FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install core dependencies first
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Install AI dependencies separately to manage memory usage
RUN pip install --no-cache-dir torch==2.1.1+cpu torchvision==0.16.1+cpu -f https://download.pytorch.org/whl/torch_stable.html
RUN pip install --no-cache-dir transformers>=4.35.2
RUN pip install --no-cache-dir sentence-transformers==2.2.2
RUN pip install --no-cache-dir spacy==3.7.2

# Download spaCy model
RUN python -m spacy download en_core_web_sm

# Copy the rest of the application
COPY . .

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
