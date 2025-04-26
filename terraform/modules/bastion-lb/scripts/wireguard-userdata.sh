#!/bin/bash
set -euxo pipefail

# === 1. Подготовка системы ===
apt-get update && apt-get install -y wireguard iproute2 iptables curl

# Включаем IP forwarding навсегда
sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# === 2. Генерация ключей ===
umask 077
SERVER_PRIV=$(wg genkey)
SERVER_PUB=$(echo "$SERVER_PRIV" | wg pubkey)

CLIENT_PRIV=$(wg genkey)
CLIENT_PUB=$(echo "$CLIENT_PRIV" | wg pubkey)

# === 3. Получение публичного IP (AWS IMDSv2) ===
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60")

PUBLIC_IP=$(curl -s --fail --max-time 5 \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

if [[ -z "$PUBLIC_IP" ]]; then
  echo "❌ Не удалось получить публичный IP"
  exit 1
fi

# === 5. Серверный конфиг WireGuard ===
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.6.0.1/24
ListenPort = 51820
PrivateKey = ${SERVER_PRIV}
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -m state --state RELATED,ESTABLISHED -j ACCEPT; iptables -t nat -A POSTROUTING -s 10.6.0.0/24 -o ens5 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -m state --state RELATED,ESTABLISHED -j ACCEPT; iptables -t nat -D POSTROUTING -s 10.6.0.0/24 -o ens5 -j MASQUERADE

[Peer]
PublicKey = ${CLIENT_PUB}
AllowedIPs = 10.6.0.2/32
EOF

# === 6. Запуск и автозапуск сервера ===
systemctl enable wg-quick@wg0
systemctl restart wg-quick@wg0

# === 7. Сохраняем клиентский конфиг отдельно ===
mkdir -p ~/wireguard-client
cat > ~/wireguard-client/client.conf <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIV}
Address = 10.6.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = ${SERVER_PUB}
Endpoint = ${PUBLIC_IP}:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

chmod 600 ~/wireguard-client/client.conf

# === 8. Финал ===
echo "✅ WireGuard сервер установлен и запущен!"
echo "📄 Клиентская конфигурация сохранена в: ~/wireguard-client/client.conf"
cat ~/wireguard-client/client.conf
