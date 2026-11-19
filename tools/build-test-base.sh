#!/usr/bin/env bash
# Сборка тестовой базы из исходников: загрузка src/ и обновление конфигурации БД.
# IB_PATH — путь к файловой базе (по умолчанию тестовая база).
set -euo pipefail
cd "$(dirname "$0")/.."

IBCMD="${IBCMD:-/opt/1cv8/x86_64/8.5.1.1150/ibcmd}"
IB_PATH="${IB_PATH:-/srv/1c/bases/shelter-test}"

if [[ "$IB_PATH" == *shelter-prod* ]]; then
  echo "Отказ: скрипт только для тестовой базы, а указана $IB_PATH" >&2
  exit 3
fi

echo "== Загрузка конфигурации из src/ в $IB_PATH"
"$IBCMD" config import --db-path="$IB_PATH" src

echo "== Обновление конфигурации базы данных"
"$IBCMD" config apply --db-path="$IB_PATH" --force
