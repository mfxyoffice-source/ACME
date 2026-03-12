#!/bin/bash
# ==========================================
# ACME.sh 完全自动 Cloudflare DNS ECC 证书申请
# ==========================================

# 1. 检查 root
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户运行此脚本"
    exit 1
fi

echo "========================================="
echo "  ACME.sh 完全自动 Cloudflare DNS ECC 证书申请"
echo "========================================="

# 2. 安装依赖
echo "[1/7] 安装依赖：curl idn..."
apt update -y
apt install -y curl idn

# 3. 安装 acme.sh
echo "[2/7] 安装 acme.sh..."
curl https://get.acme.sh | sh
ACME_CMD="$HOME/.acme.sh/acme.sh"

# 4. 显示版本
echo "[3/7] 当前 acme.sh 版本："
$ACME_CMD --version

# 5. 设置 Cloudflare CF_Token 和域名
CF_Token="这里填你的CF_Token"
export CF_Token="$CF_Token"

DOMAIN="这里填你的域名"

# 6. 设置默认 CA 为 Let's Encrypt
echo "[4/7] 设置默认 CA 为 Let's Encrypt..."
$ACME_CMD --set-default-ca --server letsencrypt

# 7. 申请 ECC 证书
echo "[5/7] 正在申请 ECC 证书..."
$ACME_CMD --issue -d "$DOMAIN" --dns dns_cf --keylength ec-256 --force

# 8. 检查结果
if [ $? -eq 0 ]; then
    echo "========================================="
    echo "证书申请成功！"
    echo "证书文件目录：$HOME/.acme.sh/$DOMAIN/"
    echo "========================================="
else
    echo "证书申请失败，请检查 CF_Token 和域名设置。"
    exit 1
fi

# 9. 安装 cron 定时任务
echo "[6/7] 安装 cron 定时任务..."
$ACME_CMD --install-cronjob

echo "[7/7] 完成！"
exit 0
