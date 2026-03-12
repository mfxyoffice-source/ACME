#!/bin/bash

ACME="$HOME/.acme.sh/acme.sh"

install_base() {

echo "安装基础环境..."
apt update -y
apt install -y cron curl socat

systemctl enable cron
systemctl start cron

echo "基础环境安装完成"

}

install_acme() {

if [ ! -f "$ACME" ]; then

echo "安装 acme.sh ..."
curl https://get.acme.sh | sh
source ~/.bashrc

else

echo "acme.sh 已安装"

fi

}

set_ca() {

$ACME --set-default-ca --server letsencrypt

}

issue_cert() {

echo ""
echo "======================================"
echo "请手动输入 Cloudflare DNS API Token"
echo "======================================"

echo "示例："
echo "export CF_Token=\"你的token\""
echo ""

read -p "请输入命令并回车: "

echo ""
echo "Token 已导出"
echo ""

echo "======================================"
echo "请输入需要申请证书的域名"
echo "======================================"

read -p "证书域名: " domain

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

renew_cert() {

read -p "请输入需要强制重签的域名: " domain

if [ -z "$domain" ]; then
echo "域名不能为空"
return
fi

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
set_ca
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
echo "4. 申请 ECC 证书 (手动输入 Token)"
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
