#!/bin/bash
# guardian_auto_maintenance.sh
# Autor: ChatGPT via Rafael Ziviani
# Descrição: Script de manutenção automática para o Sistema Guardian

LOG_FILE="/home/jbm/guardian_maintenance_log.txt"
ENV_PATH="/home/jbm/zabbix_env"
APP_PATH="/home/jbm/guardian_web_app"
ORCHESTRATOR="/home/jbm/orchestrator_ia_guardian.py"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "===== MANUTENÇÃO INICIADA: $DATE =====" > "$LOG_FILE"

# Ativar ambiente virtual
echo "[*] Ativando ambiente virtual..." >> "$LOG_FILE"
source "$ENV_PATH/bin/activate"

# Atualizar dependências
echo "[*] Atualizando dependências..." >> "$LOG_FILE"
pip install -r "$APP_PATH/requirements.txt" --upgrade >> "$LOG_FILE" 2>&1

# Corrigir permissões
echo "[*] Corrigindo permissões..." >> "$LOG_FILE"
chown -R jbm:jbm "$APP_PATH"
chmod -R 750 "$APP_PATH"

# Verificar se app Flask está rodando
echo "[*] Verificando Flask..." >> "$LOG_FILE"
APP_PID=$(ps aux | grep "flask run" | grep -v grep | awk '{print $2}')
if [ -z "$APP_PID" ]; then
  echo "[*] Iniciando aplicação Flask..." >> "$LOG_FILE"
  nohup flask --app "$APP_PATH/app.py" run --host=0.0.0.0 --port=5000 >> "$APP_PATH/flask.log" 2>&1 &
else
  echo "[*] Flask já está em execução (PID: $APP_PID)" >> "$LOG_FILE"
fi

# Rodar orquestrador de IA
echo "[*] Executando orquestrador IA..." >> "$LOG_FILE"
"$ENV_PATH/bin/python3" "$ORCHESTRATOR" >> "$LOG_FILE" 2>&1

# Verificar status dos serviços
echo "[*] Verificando serviços críticos..." >> "$LOG_FILE"
for service in apache2 zabbix-server fail2ban postfix; do
  systemctl is-active "$service" >> "$LOG_FILE" 2>&1
done

# Commit e push no Git
echo "[*] Atualizando repositório Git..." >> "$LOG_FILE"
cd "$APP_PATH"
git add . >> "$LOG_FILE" 2>&1
git commit -m "Auto manutenção $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE" 2>&1
git push origin main >> "$LOG_FILE" 2>&1

echo "===== MANUTENÇÃO FINALIZADA: $(date "+%Y-%m-%d %H:%M:%S") =====" >> "$LOG_FILE"
