#!/usr/bin/env bash
# Обновление рабочей базы из исходников: копия базы, загрузка src/, обновление конфигурации БД.
# IB_PATH — путь к рабочей базе; переопределяется только для пробы на копии.
set -euo pipefail
cd "$(dirname "$0")/.."

IBCMD="${IBCMD:-/opt/1cv8/x86_64/8.5.1.1150/ibcmd}"
IB_PATH="${IB_PATH:-/srv/1c/bases/shelter-prod}"
BACKUP_DIR="${BACKUP_DIR:-/srv/1c/backups}"
BACKUP_FILE="$BACKUP_DIR/$(basename "$IB_PATH")_predeploy_$(date +%F_%H%M%S).dt"

echo "== Копия базы $IB_PATH -> $BACKUP_FILE"
"$IBCMD" infobase dump --db-path="$IB_PATH" "$BACKUP_FILE"

echo "== Загрузка конфигурации из src/ в $IB_PATH"
"$IBCMD" config import --db-path="$IB_PATH" src

echo "== Обновление конфигурации базы данных (без --force)"
"$IBCMD" config apply --db-path="$IB_PATH" < /dev/null

echo "== Готово. Откат при необходимости: tools/restore-prod.sh $BACKUP_FILE"

