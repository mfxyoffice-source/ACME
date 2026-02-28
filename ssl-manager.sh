#!/bin/bash

one_key_install() {

    echo "开始一键申请证书流程..."

    echo "【1/6】安装基础环境..."
    apt update -y
    apt install -y cron curl
    systemctl enable cron
    systemctl start cron

    echo "【2/6】安装 acme.sh ..."
    curl https://get.acme.sh | sh
    source ~/.bashrc

    echo "【3/6】设置默认 CA 为 Let's Encrypt ..."
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt

    echo "【4/6】设置 DNS API Token (Cloudflare)"
    read -p "请输入 Cloudflare API Token: " CF_Token
    echo "export CF_Token=\"$CF_Token\"" >> ~/.bashrc
    export CF_Token="$CF_Token"

    echo "【5/6】申请 ECC 证书"
    read -p "请输入证书域名 FQDN (Fully Qualified Domain Name): " domain
    ~/.acme.sh/acme.sh --issue -d $domain --dns dns_cf --keylength ec-256

    echo "【6/6】当前自动续签任务："
    crontab -l

    echo "=========================================="
    echo "证书申请流程完成"
    echo "如需强制重新签发，请执行："
    echo "~/.acme.sh/acme.sh --issue -d $domain --dns dns_cf --keylength ec-256 --force"
    echo "=========================================="

    read -p "按回车返回菜单..."
}

while true
do
clear
echo "=========================================="
echo "        ACME 证书管理控制台"
echo "=========================================="
echo " 1. 一键申请证书 (默认回车执行)"
echo " 2. 安装基础环境 (cron + curl)"
echo " 3. 安装 acme.sh"
echo " 4. 查看 acme.sh 版本"
echo " 5. 设置默认 CA 为 Let's Encrypt"
echo " 6. 设置 DNS API Token (Cloudflare)"
echo " 7. 申请 ECC 证书 (DNS-01)"
echo " 8. 查看自动续签任务"
echo " 9. 强制重新签发证书"
echo " 0. 退出"
echo "=========================================="

read -p "请输入数字选项 [默认1]: " num

# 如果直接回车
if [ -z "$num" ]; then
    num=1
fi

case $num in

1)
    one_key_install
    ;;

2)
    apt update -y
    apt install -y cron curl
    systemctl enable cron
    systemctl start cron
    read -p "按回车返回菜单..."
    ;;

3)
    curl https://get.acme.sh | sh
    source ~/.bashrc
    read -p "按回车返回菜单..."
    ;;

4)
    ~/.acme.sh/acme.sh --version
    read -p "按回车返回菜单..."
    ;;

5)
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    read -p "按回车返回菜单..."
    ;;

6)
    read -p "请输入 DNS API Token (Cloudflare): " CF_Token
    echo "export CF_Token=\"$CF_Token\"" >> ~/.bashrc
    export CF_Token="$CF_Token"
    read -p "按回车返回菜单..."
    ;;

7)
    read -p "请输入证书域名 FQDN: " domain
    ~/.acme.sh/acme.sh --issue -d $domain --dns dns_cf --keylength ec-256
    read -p "按回车返回菜单..."
    ;;

8)
    crontab -l
    read -p "按回车返回菜单..."
    ;;

9)
    read -p "请输入需要强制重签的 FQDN: " domain
    ~/.acme.sh/acme.sh --issue -d $domain --dns dns_cf --keylength ec-256 --force
    read -p "按回车返回菜单..."
    ;;

0)
    exit
    ;;

*)
    echo "输入错误"
    sleep 2
    ;;

esac

done
