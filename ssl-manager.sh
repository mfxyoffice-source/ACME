#!/bin/bash
# ==========================================
# ACME.sh 一键安装与 Cloudflare DNS ECC 证书申请
# ==========================================

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户运行此脚本"
    exit 1
fi

echo "========================================="
echo "  ACME.sh 一键安装与 Cloudflare DNS ECC 证书申请"
echo "========================================="

# 安装依赖
echo "[1/7] 安装依赖：curl idn..."
apt update -y
apt install -y curl idn

# 安装 acme.sh
echo "[2/7] 安装 acme.sh..."
curl https://get.acme.sh | sh
if [ $? -ne 0 ]; then
    echo "acme.sh 安装失败！"
    exit 1
fi

# 立即使用完整路径
ACME_CMD="$HOME/.acme.sh/acme.sh"

# 显示版本
echo "[3/7] 当前 acme.sh 版本："
$ACME_CMD --version

# 输入 Cloudflare CF_Token
read -p "请输入 Cloudflare CF_Token: " CF_Token
export CF_Token="$CF_Token"
echo "CF_Token 已设置。"

# 设置默认 CA 为 Let's Encrypt
echo "[4/7] 设置默认 CA 为 Let's Encrypt..."
$ACME_CMD --set-default-ca --server letsencrypt

# 输入域名
read -p "请输入申请证书的域名: " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo "域名不能为空！"
    exit 1
fi

# 是否强制刷新证书
read -p "是否强制刷新证书？(y/n, 默认 n): " FORCE_CHOICE
if [[ "$FORCE_CHOICE" == "y" || "$FORCE_CHOICE" == "Y" ]]; then
    FORCE_ARG="--force"
else
    FORCE_ARG=""
fi

# 申请 ECC 证书
echo "[5/7] 正在申请 ECC 证书..."
$ACME_CMD --issue -d "$DOMAIN" --dns dns_cf --keylength ec-256 $FORCE_ARG

# 检查结果
if [ $? -eq 0 ]; then
    echo "========================================="
    echo "证书申请成功！"
    echo "证书文件目录：$HOME/.acme.sh/$DOMAIN/"
    echo "========================================="
else
    echo "证书申请失败，请检查 CF_Token 和域名设置。"
fi

echo "[6/7] 安装 cron 定时任务..."
$ACME_CMD --install-cronjob

echo "[7/7] 完成！"
exit 0
