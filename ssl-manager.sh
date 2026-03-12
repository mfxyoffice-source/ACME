#!/bin/bash

ACME="$HOME/.acme.sh/acme.sh"
CONF="$HOME/.acme.sh/account.conf"

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

echo "acme.sh 安装完成"

else

echo "acme.sh 已安装"

fi

}

set_ca() {

$ACME --set-default-ca --server letsencrypt
echo "默认CA已设置为 Let's Encrypt"

}

set_cf_token() {

read -p "请输入 Cloudflare API Token: " CF_Token

if [ -z "$CF_Token" ]; then
echo "Token 不能为空"
return
fi

echo "export CF_Token=\"$CF_Token\"" >> ~/.bashrc
echo "CF_Token=\"$CF_Token\"" >> $CONF

export CF_Token="$CF_Token"

echo "Token 已保存"

}

issue_cert() {

if [ ! -f "$ACME" ]; then
echo "acme.sh 未安装"
return
fi

read -p "请输入证书域名 (例如 cdn.example.com): " domain

if [ -z "$domain" ]; then
echo "域名不能为空"
return
fi

echo "开始申请证书..."

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

echo "重签完成"

}

list_cert() {

$ACME --list

}

show_cron() {

echo "当前自动续签任务："
crontab -l

}

one_key_install() {

install_base
install_acme
set_ca
set_cf_token
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
echo "4. 设置 Cloudflare Token"
echo "5. 申请 ECC 证书"
echo "6. 强制重新签发证书"
echo "7. 查看已申请证书"
echo "8. 查看自动续签任务"
echo "0. 退出"
echo "======================================"

read -p "请输入选项 [默认1]: " num

[ -z "$num" ] && num=1

case $num in

1)
one_key_install
;;

2)
install_base
;;

3)
install_acme
;;

4)
set_cf_token
;;

5)
issue_cert
;;

6)
renew_cert
;;

7)
list_cert
;;

8)
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
