#!/bin/bash

while true
do
clear
echo "=========================================="
echo "        ACME 证书管理控制台"
echo "=========================================="
echo " 1. 安装基础环境 (cron + curl)"
echo " 2. 安装 acme.sh"
echo " 3. 设置默认 CA 为 Let's Encrypt"
echo " 4. 设置 DNS API Token (Cloudflare)"
echo " 5. 查看 acme.sh 版本"
echo " 6. 查看自动续签任务"
echo " 7. 申请 ECC 证书 (DNS-01 Challenge)"
echo " 8. 强制重新签发证书"
echo " 0. 退出"
echo "=========================================="

read -p "请输入数字选项: " num

case $num in

1)
    echo "安装基础环境..."
    apt update -y
    apt install -y cron curl
    systemctl enable cron
    systemctl start cron
    echo "完成"
    read -p "按回车返回菜单..."
    ;;

2)
    echo "安装 acme.sh ..."
    curl https://get.acme.sh | sh
    source ~/.bashrc
    echo "安装完成"
    read -p "按回车返回菜单..."
    ;;

3)
    echo "设置默认 CA 为 Let's Encrypt ..."
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    echo "已切换至 Let's Encrypt"
    read -p "按回车返回菜单..."
    ;;

4)
    read -p "请输入 DNS API Token (Cloudflare): " CF_Token
    echo "export CF_Token=\"$CF_Token\"" >> ~/.bashrc
    export CF_Token="$CF_Token"
    echo "Token 已保存并生效"
    read -p "按回车返回菜单..."
    ;;

5)
    echo "当前 acme.sh 版本："
    acme.sh --version
    read -p "按回车返回菜单..."
    ;;

6)
    echo "当前自动续签任务："
    crontab -l
    read -p "按回车返回菜单..."
    ;;

7)
    read -p "请输入证书 FQDN (Fully Qualified Domain Name): " domain
    ~/.acme.sh/acme.sh --issue -d $domain --dns dns_cf --keylength ec-256
    read -p "按回车返回菜单..."
    ;;

8)
    read -p "请输入需要强制重签的 FQDN: " domain
    ~/.acme.sh/acme.sh --issue -d $domain --dns dns_cf --keylength ec-256 --force
    read -p "按回车返回菜单..."
    ;;

0)
    echo "退出脚本"
    exit
    ;;

*)
    echo "输入错误，请重新选择"
    sleep 2
    ;;

esac

done
