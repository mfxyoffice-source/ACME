#!/bin/bash

ACME="$HOME/.acme.sh/acme.sh"

issue_cert() {

echo ""
echo "请手动输入 Cloudflare DNS API Token并回车："
read -r CF_Token

if [ -z "$CF_Token" ]; then
echo "Token不能为空"
return
fi

export CF_Token="$CF_Token"

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

install_base() {

apt update -y
apt install -y cron curl socat

systemctl enable cron
systemctl start cron

}

install_acme() {

if [ ! -f "$ACME" ]; then
curl https://get.acme.sh | sh
source ~/.bashrc
fi

}

renew_cert() {

echo "请输入需要重签的域名："
read -r domain

$ACME --issue -d "$domain" --dns dns_cf --keylength ec-256 --force

}

show_cert() {

$ACME --list

}

show_cron() {

crontab -l

}

one_key() {

install_base
install_acme
$ACME --set-default-ca --server letsencrypt
issue_cert

}

while true
do

clear

echo "======================================"
echo "        ACME 证书管理控制台"
echo "======================================"
echo "1. 一键申请证书"
echo "2. 安装基础环境"
echo "3. 安装 acme.sh"
echo "4. 申请 ECC 证书"
echo "5. 强制重新签发证书"
echo "6. 查看已申请证书"
echo "7. 查看自动续签任务"
echo "0. 退出"
echo "======================================"

read -p "请输入选项 [默认1]: " num

[ -z "$num" ] && num=1

case $num in

1)
one_key
;;

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
