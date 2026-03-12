#!/bin/bash
# ==========================================
# ACME.sh Cloudflare ECC 证书管理脚本（菜单化）
# ==========================================

# 检查 root
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户运行脚本"
    exit 1
fi

echo "========================================="
echo "ACME.sh Cloudflare ECC 证书管理脚本"
echo "========================================="

# 菜单函数
show_menu() {
    echo ""
    echo "请选择操作："
    echo "1) 执行完整自动化证书申请（默认）"
    echo "2) 安装依赖 curl/idn"
    echo "3) 安装 acme.sh"
    echo "4) 输入 Cloudflare CF_Token"
    echo "5) 设置默认 CA 为 Let's Encrypt"
    echo "6) 输入域名"
    echo "7) 申请 ECC 证书"
    echo "8) 安装 cron 定时任务"
    echo "0) 退出脚本"
    echo ""
}

# 初始化变量
ACME_CMD="$HOME/.acme.sh/acme.sh"
CF_Token=""
DOMAIN=""

# 自动化流程函数
full_auto() {
    echo "[自动化] 安装依赖..."
    apt update -y
    apt install -y curl idn

    echo "[自动化] 安装 acme.sh..."
    curl https://get.acme.sh | sh
    ACME_CMD="$HOME/.acme.sh/acme.sh"

    read -p "请输入 Cloudflare CF_Token: " CF_Token
    export CF_Token

    echo "[自动化] 设置默认 CA 为 Let's Encrypt..."
    $ACME_CMD --set-default-ca --server letsencrypt

    while true; do
        read -p "请输入申请证书的域名: " DOMAIN
        if [ -n "$DOMAIN" ]; then
            break
        else
            echo "域名不能为空，请重新输入！"
        fi
    done

    echo "[自动化] 申请 ECC 证书..."
    $ACME_CMD --issue -d "$DOMAIN" --dns dns_cf --keylength ec-256 --force

    if [ $? -eq 0 ]; then
        echo "证书申请成功！证书目录：$HOME/.acme.sh/$DOMAIN/"
    else
        echo "证书申请失败，请检查 CF_Token 和域名设置。"
    fi

    echo "[自动化] 安装 cron 定时任务..."
    $ACME_CMD --install-cronjob
    echo "自动化流程完成！"
}

# 菜单循环
while true; do
    show_menu
    read -p "请输入数字选择 [1]: " choice
    choice=${choice:-1}  # 默认 1 自动化流程

    case $choice in
        1)
            full_auto
            ;;
        2)
            echo "[步骤] 安装依赖..."
            apt update -y
            apt install -y curl idn
            ;;
        3)
            echo "[步骤] 安装 acme.sh..."
            curl https://get.acme.sh | sh
            ACME_CMD="$HOME/.acme.sh/acme.sh"
            ;;
        4)
            read -p "请输入 Cloudflare CF_Token: " CF_Token
            export CF_Token
            echo "CF_Token 已设置。"
            ;;
        5)
            echo "[步骤] 设置默认 CA 为 Let's Encrypt..."
            $ACME_CMD --set-default-ca --server letsencrypt
            ;;
        6)
            while true; do
                read -p "请输入申请证书的域名: " DOMAIN
                if [ -n "$DOMAIN" ]; then
                    break
                else
                    echo "域名不能为空，请重新输入！"
                fi
            done
            ;;
        7)
            echo "[步骤] 申请 ECC 证书..."
            $ACME_CMD --issue -d "$DOMAIN" --dns dns_cf --keylength ec-256 --force
            if [ $? -eq 0 ]; then
                echo "证书申请成功！证书目录：$HOME/.acme.sh/$DOMAIN/"
            else
                echo "证书申请失败，请检查 CF_Token 和域名设置。"
            fi
            ;;
        8)
            echo "[步骤] 安装 cron 定时任务..."
            $ACME_CMD --install-cronjob
            ;;
        0)
            echo "退出脚本"
            exit 0
            ;;
        *)
            echo "无效选项，请重新输入！"
            ;;
    esac
done
