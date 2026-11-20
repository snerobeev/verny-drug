#!/usr/bin/env bash
# Расширенная проверка конфигурации тестовой базы: Конфигуратор в пакетном режиме.
# Код 0 — замечаний нет, 101 — есть замечания (список в выводе и в build/check-config.log).
# Конфигуратор — графическая программа: в Jenkins запускать через xvfb-run.
set -euo pipefail
cd "$(dirname "$0")/.."

V8="${V8:-/opt/1cv8/x86_64/8.5.1.1150}"
IB_PATH="${IB_PATH:-/srv/1c/bases/shelter-test}"
LOG=build/check-config.log

mkdir -p build
rm -f "$LOG"

echo "== Расширенная проверка конфигурации $IB_PATH"
set +e
"$V8/1cv8" DESIGNER /F "$IB_PATH" /DisableStartupDialogs \
  /CheckConfig -ThinClient -WebClient -Server -ExtendedModulesCheck \
  /Out "$LOG"
rc=$?
set -e

cat "$LOG"
exit "$rc"

