#!/bin/bash
# === ihoralex3: установка cloudflared + подключение к CF-туннелю ===
# Выполнить в веб-консоли провайдера (root)
set -e
token="$1"
ARCH=$(uname -m)
case $ARCH in
  x86_64)  CFARCH=amd64 ;;
  aarch64) CFARCH=arm64 ;;
  *) echo "unknown arch: $ARCH"; exit 1 ;;
esac

echo "[1/3] Скачиваю и ставлю cloudflared ($CFARCH)..."
curl -fsSL -o /tmp/cloudflared.deb   "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CFARCH}.deb"
dpkg -i /tmp/cloudflared.deb

echo "[2/3] Подключаю сервер к туннелю (systemd-сервис cloudflared)..."
cloudflared service install $token

echo "[3/3] Статус:"
sleep 3
systemctl is-active cloudflared && echo "OK: cloudflared работает" || { journalctl -u cloudflared -n 20 --no-pager; exit 1; }
echo "Готово. SSH теперь доступен через ssh.smeleyka.ru"
