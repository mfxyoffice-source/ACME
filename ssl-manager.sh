#!/bin/bash

ACME="$HOME/.acme.sh/acme.sh"

# ----------------------------------
# 申请证书函数（完全手动交互）
# ----------------------------------
issue_cert() {
    echo ""
    echo "======================================"
    echo "请手动输入 Cloudflare DNS API Token"
    echo "======================================"
    read -r CF_Token

    if [ -z "$CF_Token" ]; then
        echo "Token 不能为空"
        return
    fi

    # 导出环境变量，供 acme.sh 使用
    export CF_Token="$CF_Token"
    echo "Token 已导出"

    echo ""
    echo "按回车继续输入证书域名..."
    read -r

    echo ""
    echo "请输入证书域名并回车："
    read -r domain

    if [ -z "$domain" ]; then
        echo "域名不能为空"
        return
    fi

    echo ""
    echo "开始申请证书..."
    echo ""

    $ACME --issue -d "$domain" --dns dns_cf --keylength ec-256

    echo ""
    echo "证书路径："
    echo "$HOME/.acme.sh/${domain}_ecc/"
    echo ""
}

# ----------------------------------
# 安装基础依赖
# ----------------------------------
install_base() {
    apt update -y
    apt install -y cron curl socat
    systemctl enable cron
    systemctl start cron
    echo "基础环境安装完成"
}

# ----------------------------------
# 安装 acme.sh
# ----------------------------------
install_acme() {
    if [ ! -f "$ACME" ]; then
        curl https://get.acme.sh | sh
        source ~/.bashrc
        echo "acme.sh 已安装"
    else
        echo "acme.sh 已经存在"
    fi
}

# ----------------------------------
# 强制重签
# ----------------------------------
renew_cert() {
    echo "请输入需要重签的域名："
    read -r domain
    if [ -z "$domain" ]; then
        echo "域名不能为空"
        return
    fi
    $ACME --issue -d "$domain" --dns dns_cf --keylength ec-256 --force
}

# ----------------------------------
# 查看已申请证书
# ----------------------------------
show_cert() {
    $ACME --list
}

# ----------------------------------
# 查看自动续签任务
# ----------------------------------
show_cron() {
    crontab -l
}

# ----------------------------------
# 菜单循环
# ----------------------------------
while true
do
    clear
    echo "======================================"
    echo "        ACME 证书管理控制台"
    echo "======================================"
    echo "2. 安装基础环境"
    echo "3. 安装 acme.sh"
    echo "4. 申请 ECC 证书（手动输入 Token）"
    echo "5. 强制重新签发证书"
    echo "6. 查看已申请证书"
    echo "7. 查看自动续签任务"
    echo "0. 退出"
    echo "======================================"

    read -p "请输入选项: " num

    case $num in
        2)
            install_base
            ;;
        3)
            install_acme
            ;;
        4)
            issue_cert
            ;;
        5)
            renew_cert
            ;;
        6)
            show_cert
            ;;
        7)
            show_cron
            ;;
        0)
            exit
            ;;
        *)
            echo "输入错误"
            sleep 2
            ;;
    esac

    echo ""
    read -p "按回车返回菜单..."
done
