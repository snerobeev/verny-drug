#!/usr/bin/env bash
# Модульные тесты YAxUnit: загрузка расширений в тестовую базу и прогон тестов.
# Код завершения: 0 - все тесты прошли; 1 - есть упавшие; 2 - нет результата; иное - сбой.
#
# Нужно заранее: тестовая база собрана (tools/build-test-base.sh),
# yaxunit.cfe скачан из релизов github.com/bia-technologies/yaxunit.
set -euo pipefail
cd "$(dirname "$0")/.."

V8_DIR="${V8_DIR:-/opt/1cv8/x86_64/8.5.1.1150}"
IBCMD="${IBCMD:-$V8_DIR/ibcmd}"
V8="${V8:-$V8_DIR/1cv8}"
IB_PATH="${IB_PATH:-/srv/1c/bases/shelter-test}"
YAXUNIT_CFE="${YAXUNIT_CFE:-$HOME/tools/yaxunit/yaxunit.cfe}"
OUT="build-unit"

if [[ "$IB_PATH" == *shelter-prod* ]]; then
  echo "Отказ: модульные тесты только для тестовой базы, а указана $IB_PATH" >&2
  exit 3
fi
if [[ ! -f "$YAXUNIT_CFE" ]]; then
  echo "Не найден $YAXUNIT_CFE: скачайте yaxunit.cfe и укажите путь в YAXUNIT_CFE" >&2
  exit 4
fi

rm -rf "$OUT"
mkdir -p "$OUT/allure-results"

echo "== Загрузка YAxUnit"
"$IBCMD" config load --db-path="$IB_PATH" --extension=YAxUnit "$YAXUNIT_CFE"

echo "== Загрузка расширения с тестами из exts/tests"
"$IBCMD" config import --db-path="$IB_PATH" --extension=ВерныйДруг_Тесты exts/tests

for EXT in YAxUnit ВерныйДруг_Тесты; do
  echo "== $EXT: применение к базе данных"
  "$IBCMD" config apply --db-path="$IB_PATH" --extension="$EXT" --force

  echo "== $EXT: отключаем безопасный режим и защиту от опасных действий"
  "$IBCMD" extension update --db-path="$IB_PATH" --name="$EXT" \
      --safe-mode=no --unsafe-action-protection=no
done

# Настройки прогона YAxUnit
cat > "$OUT/yaxunit.json" <<JSON
{
  "filter": { "extensions": ["ВерныйДруг_Тесты"] },
  "reportFormat": "allure",
  "reportPath": "$PWD/$OUT/allure-results",
  "exitCode": "$PWD/$OUT/exit-code.txt",
  "closeAfterTests": true,
  "showReport": false
}
JSON

echo "== Прогон тестов"
"$V8" ENTERPRISE /F "$IB_PATH" /DisableStartupDialogs /DisableStartupMessages \
    /Out "$PWD/$OUT/1cv8.log" /C "RunUnitTests=$PWD/$OUT/yaxunit.json" || true

if [[ ! -f "$OUT/exit-code.txt" ]]; then
  echo "YAxUnit не записал код завершения, подробности в $OUT/1cv8.log"
  exit 2
fi

rc=$(tr -dc '0-9' < "$OUT/exit-code.txt")
if [[ "$rc" == "0" ]]; then
  echo "Все модульные тесты прошли"
  exit 0
fi
echo "ЕСТЬ УПАВШИЕ МОДУЛЬНЫЕ ТЕСТЫ, результаты в $OUT/allure-results"
exit 1
