#!/usr/bin/env bash
# Откат рабочей базы из выгрузки .dt.
# Текущая база не удаляется, а откладывается рядом с меткой времени.
# Использование: tools/restore-prod.sh <файл.dt>
# IB_PATH — путь к рабочей базе; переопределяется только для пробы на копии.
set -euo pipefail

DT_FILE="${1:?Укажите файл выгрузки .dt}"
V8="${V8:-/opt/1cv8/x86_64/8.5.1.1150}"
IB_PATH="${IB_PATH:-/srv/1c/bases/shelter-prod}"
ASIDE="${IB_PATH}.before-restore_$(date +%F_%H%M%S)"

[[ -f "$DT_FILE" ]] || { echo "Нет файла $DT_FILE" >&2; exit 2; }

echo "== Текущая база $IB_PATH -> $ASIDE"
mv "$IB_PATH" "$ASIDE"

echo "== Создание пустой базы с Locale=ru_RU"
"$V8/1cv8" CREATEINFOBASE "File=$IB_PATH;Locale=ru_RU" /Out "$ASIDE.create.log"
cat "$ASIDE.create.log"

echo "== Загрузка выгрузки $DT_FILE"
"$V8/ibcmd" infobase restore --db-path="$IB_PATH" "$DT_FILE"

echo "== Готово. Отложенная база: $ASIDE (удалить вручную после проверки)"

