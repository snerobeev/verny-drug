#!/usr/bin/env bash
# Обновление рабочей базы из исходников: копия базы, загрузка конфигурации, обновление конфигурации БД.
# Код 102: обновление требует реструктуризации таблиц с данными, список объектов в build/restructure.txt.
#   Повторный запуск с FORCE_APPLY=1 применяет изменения с --force (только после подтверждения человеком).
# IB_PATH, SRC_DIR, BACKUP_DIR переопределяются только для пробы на копии.
set -euo pipefail
cd "$(dirname "$0")/.."

IBCMD="${IBCMD:-/opt/1cv8/x86_64/8.5.1.1150/ibcmd}"
IB_PATH="${IB_PATH:-/srv/1c/bases/shelter-prod}"
SRC_DIR="${SRC_DIR:-src}"
BACKUP_DIR="${BACKUP_DIR:-/srv/1c/backups}"
FORCE_APPLY="${FORCE_APPLY:-0}"
BACKUP_FILE="$BACKUP_DIR/$(basename "$IB_PATH")_predeploy_$(date +%F_%H%M%S).dt"

mkdir -p build
rm -f build/restructure.txt

echo "== Копия базы $IB_PATH -> $BACKUP_FILE"
"$IBCMD" infobase dump --db-path="$IB_PATH" "$BACKUP_FILE"

echo "== Загрузка конфигурации из $SRC_DIR в $IB_PATH"
"$IBCMD" config import --db-path="$IB_PATH" "$SRC_DIR"

if [[ "$FORCE_APPLY" == "1" ]]; then
  echo "== Обновление конфигурации базы данных с --force (реструктуризация подтверждена)"
  "$IBCMD" config apply --db-path="$IB_PATH" --force
else
  echo "== Обновление конфигурации базы данных (без --force)"
  set +e
  "$IBCMD" config apply --db-path="$IB_PATH" < /dev/null 2>&1 | tee build/apply.log
  rc=${PIPESTATUS[0]}
  set -e
  if [[ $rc -eq 102 ]]; then
    grep 'Object modified' build/apply.log > build/restructure.txt || true
    echo
    echo "== Нужна реструктуризация таблиц с данными:"
    cat build/restructure.txt
    exit 102
  elif [[ $rc -ne 0 ]]; then
    exit "$rc"
  fi
fi

echo "== Готово. Откат при необходимости: tools/restore-prod.sh $BACKUP_FILE"

