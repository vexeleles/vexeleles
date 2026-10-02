FROM python:3.12-slim
WORKDIR /app
COPY bot/requirements.txt bot/requirements.txt
RUN pip install --no-cache-dir -r bot/requirements.txt
COPY bot/ bot/
COPY webapp/ webapp/
ENV WEBAPP_DIR=/app/webapp DB_PATH=/data/starlify_shop.db PYTHONUNBUFFERED=1
WORKDIR /app/bot
CMD ["python", "main.py"]
