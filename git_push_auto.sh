#!/bin/bash

# Caminho do seu repositório local
REPO_DIR="/home/jbm/sistema-guardian"

cd "$REPO_DIR" || { echo "Pasta $REPO_DIR não encontrada"; exit 1; }

git add .
git commit -m "Atualização automática $(date +"%Y-%m-%d %H:%M:%S")" || echo "Nada para commitar"
git push origin main

echo "Push concluído."
