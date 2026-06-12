#!/bin/bash
echo "🚀 INICIANDO PIPELINE"
python3 test_app.py
docker build -t mi-app .
docker run --rm mi-app
