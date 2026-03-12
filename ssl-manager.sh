#!/bin/bash
# ==========================================
# ACME.sh 自动申请 Cloudflare ECC 证书（Token & 域名手动输入）
# ==========================================

# 1. 检查 root
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户运行脚本"
    exit 1
fi

echo "========================================="
echo "ACME.sh 自动申请 Cloudflare ECC 证书"
echo "========================================="

# 2. 安装依赖
echo "[1/6] 安装依赖：curl idn..."
apt update -y
apt install -y curl idn

# 3. 安装 acme.sh
echo "[2/6] 安装 acme.sh..."
curl https://get.acme.sh | sh
ACME_CMD="$HOME/.acme.sh/acme.sh"

# 4. 输入 CF Token
read -p "请输入 Cloudflare CF_Token: " CF_Token
export CF_Token="$CF_Token"
echo "CF_Token 已设置。"

# 5. 设置默认 CA
echo "[3/6] 设置默认 CA 为 Let's Encrypt..."
$ACME_CMD --set-default-ca --server letsencrypt

# 6. 输入域名
while true; do
    read -p "请输入申请证书的域名: " DOMAIN
    if [ -n "$DOMAIN" ]; then
        break
    else
        echo "域名不能为空，请重新输入！"
    fi
done

# 7. 申请 ECC 证书
echo "[4/6] 正在申请 ECC 证书..."
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
echo "[5/6] 安装 cron 定时任务..."
$ACME_CMD --install-cronjob

echo "[6/6] 脚本执行完成！"
