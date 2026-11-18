#!/usr/bin/env bash
# Тесты API (REST Assured) в Docker-контейнере с JDK 21.
# BASE_URL — адрес HTTP-сервиса; если не задан, берётся из build.gradle.kts.
set -euo pipefail
cd "$(dirname "$0")/../api-tests"

GRADLE_CACHE="${GRADLE_CACHE:-$HOME/.cache/gradle-docker}"
mkdir -p "$GRADLE_CACHE"

ARGS=(test --no-daemon)
if [[ -n "${BASE_URL:-}" ]]; then
  ARGS+=("-DbaseUrl=$BASE_URL")
fi

exec docker run --rm \
  --network host \
  --user "$(id -u):$(id -g)" \
  -v "$PWD":/project -w /project \
  -v "$GRADLE_CACHE":/gradle-home -e GRADLE_USER_HOME=/gradle-home \
  eclipse-temurin:21-jdk \
  ./gradlew "${ARGS[@]}"
