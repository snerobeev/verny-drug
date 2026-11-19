#!/bin/bash
# Прогон сценариев Vanessa Automation через vanessa-runner.
# Код завершения: 0 - все сценарии прошли; 1 - есть упавшие; 2 - нет отчёта; иное - сбой vrunner.
set -u
cd "$(dirname "$0")/.."

# OneScript и vrunner: Jenkins запускает bash и не знает путей из fish.
export PATH="$HOME/tools/onescript/bin:$PATH"

IB="${IB:-/F/srv/1c/bases/shelter-test}"
VANESSA_EPF="${VANESSA_EPF:-$HOME/tools/vanessa/vanessa-automation-single.epf}"

rm -rf build
mkdir -p build

# Шаблон настроек: {{ROOT}} -> текущая папка репозитория.
sed "s|{{ROOT}}|$PWD|g" tools/VAParams.json > build/VAParams.json

vrunner test vanessa \
    --ibconnection "$IB" \
    --v8version 8.5.1.1150 \
    --bddrunner-path "$VANESSA_EPF" \
    --vanessasettings build/VAParams.json \
    --language ru
rc=$?
if [ $rc -ne 0 ]; then
    echo "vrunner завершился с кодом $rc"
    exit $rc
fi

if ! ls build/junit/*.xml >/dev/null 2>&1; then
    echo "Отчёт JUnit не найден: считаем прогон проваленным"
    exit 2
fi

if grep -qE '<(failure|error)[ >/]' build/junit/*.xml; then
    echo "ЕСТЬ УПАВШИЕ СЦЕНАРИИ, подробности в build/vanessa.log"
    exit 1
fi

echo "Все сценарии прошли"
exit 0
