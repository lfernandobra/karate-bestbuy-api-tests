#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_API_DIR="$(cd "$REPO_ROOT/.." && pwd)/api-playground"
API_DIR="${BESTBUY_API_DIR:-$DEFAULT_API_DIR}"

PID_FILE="/tmp/bestbuy-api-playground.pid"
LOG_FILE="/tmp/bestbuy-api-playground.log"
API_URL="http://localhost:3030"

is_healthy() {
  curl -fsS "${API_URL}/healthcheck" >/dev/null 2>&1
}

ensure_api_dir() {
  if [[ ! -d "$API_DIR" || ! -f "$API_DIR/package.json" ]]; then
    echo "Erro: diretório da Best Buy API Playground não encontrado em: $API_DIR" >&2
    echo "Defina BESTBUY_API_DIR ou clone em $DEFAULT_API_DIR" >&2
    exit 1
  fi
}

cmd_start() {
  ensure_api_dir
  if is_healthy; then
    echo "Best Buy API Playground já está rodando em ${API_URL}"
    echo "Swagger UI: ${API_URL}/docs/"
    return 0
  fi

  echo "Iniciando Best Buy API Playground em ${API_DIR}..."
  (
    cd "$API_DIR"
    nohup node src/ > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
  )

  for _ in $(seq 1 20); do
    if is_healthy; then
      echo "API pronta em ${API_URL}"
      echo "Swagger UI: ${API_URL}/docs/"
      echo "Logs: ${LOG_FILE}"
      return 0
    fi
    sleep 0.5
  done

  echo "Falha ao iniciar a API. Verifique o log em: ${LOG_FILE}" >&2
  tail -n 30 "$LOG_FILE" >&2 || true
  exit 1
}

cmd_stop() {
  local stopped=0
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid="$(cat "$PID_FILE" || true)"
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      stopped=1
    fi
    rm -f "$PID_FILE"
  fi

  if [[ "$stopped" -eq 0 ]]; then
    local port_pid
    port_pid="$(lsof -tiTCP:3030 -sTCP:LISTEN || true)"
    if [[ -n "$port_pid" ]]; then
      kill "$port_pid" 2>/dev/null || true
      stopped=1
    fi
  fi

  if [[ "$stopped" -eq 1 ]]; then
    echo "Best Buy API Playground encerrada."
  else
    echo "Nenhum processo encontrado na porta 3030."
  fi
}

cmd_status() {
  if is_healthy; then
    echo "Status: ONLINE (${API_URL})"
    curl -sS "${API_URL}/healthcheck"
    echo ""
  else
    echo "Status: OFFLINE (${API_URL})"
    return 1
  fi
}

cmd_reset_db() {
  ensure_api_dir
  local was_running=0
  if is_healthy; then
    was_running=1
    cmd_stop
  fi

  git -C "$API_DIR" checkout -- dataset.sqlite
  echo "Banco SQLite restaurado ao estado original (dataset.sqlite)."

  if [[ "$was_running" -eq 1 ]]; then
    cmd_start
  fi
}

case "${1:-}" in
  start) cmd_start ;;
  stop) cmd_stop ;;
  status) cmd_status ;;
  reset-db) cmd_reset_db ;;
  *)
    echo "Uso: $0 {start|stop|status|reset-db}"
    exit 1
    ;;
esac
