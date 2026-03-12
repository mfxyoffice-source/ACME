#!/bin/bash
# ==========================================
# ACME.sh 一键安装与 Cloudflare DNS 证书申请
# ==========================================

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 用户运行此脚本"
  exit 1
fi

echo "========================================="
echo "  ACME.sh 一键安装与 Cloudflare DNS 证书申请"
echo "========================================="

# 1. 安装 acme.sh
echo "[1/6] 安装 acme.sh..."
curl https://get.acme.sh | sh
source ~/.bashrc

# 2. 显示版本
echo "[2/6] 当前 acme.sh 版本："
acme.sh --version

# 3. 设置 Cloudflare API Token
CF_Token="这里填写你的CF_Token"
export CF_Token="$CF_Token"
echo "CF_Token 已设置。"

# 4. 设置默认 CA 为 Let's Encrypt
echo "[3/6] 设置默认 CA 为 Let's Encrypt..."
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt

# 5. 设置域名
DOMAIN="这里填写你的域名"

# 6. 是否强制刷新证书
FORCE_ARG="--force"

# 7. 申请 ECC 证书
echo "[4/6] 正在申请 ECC 证书..."
~/.acme.sh/acme.sh --issue -d "$DOMAIN" --dns dns_cf --keylength ec-256 $FORCE_ARG

# 8. 完成提示
if [ $? -eq 0 ]; then
    echo "========================================="
    echo "证书申请成功！"
    echo "证书文件目录：~/.acme.sh/$DOMAIN/"
    echo "========================================="
else
    echo "证书申请失败，请检查 CF_Token 和域名设置。"
fi

exit 0
