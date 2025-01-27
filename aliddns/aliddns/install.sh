#!/bin/sh
source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(cd $(dirname $0); pwd)
modelname=`nvram get modelname`
# stop aliddns first
enable=`dbus get aliddns_enable`
if [ "$enable" == "1" ];then
	sh /jffs/softcenter/scripts/aliddns_config.sh stop
fi

# delete some files
rm -rf /jffs/softcenter/init.d/*aliddns.sh

# install
cp -rf /tmp/aliddns/scripts/* /jffs/softcenter/scripts/
cp -rf /tmp/aliddns/webs/* /jffs/softcenter/webs/
cp -rf /tmp/aliddns/res/* /jffs/softcenter/res/
cp -rf /tmp/aliddns/install.sh /jffs/softcenter/scripts/uninstall_aliddns.sh
chmod +x /jffs/softcenter/scripts/aliddns*
chmod +x /jffs/softcenter/init.d/*
if [ "$(nvram get productid)" = "BLUECAVE" -o "$modelname" = "R7900P" -o "$modelname" = "R8000P" -o "$softcenter_usbmount" = "1" ];then
	[ ! -f "/jffs/softcenter/init.d/M98Aliddns.sh" ] && cp -r /jffs/softcenter/scripts/aliddns_config.sh /jffs/softcenter/init.d/M98Aliddns.sh
else
	[ ! -L "/jffs/softcenter/init.d/S98Aliddns.sh" ] && ln -sf /jffs/softcenter/scripts/aliddns_config.sh /jffs/softcenter/init.d/S98Aliddns.sh
fi

# 离线安装需要向skipd写入安装信息
dbus set aliddns_version="$(cat $DIR/version)"
dbus set softcenter_module_aliddns_version="$(cat $DIR/version)"
dbus set softcenter_module_aliddns_install="1"
dbus set softcenter_module_aliddns_name="aliddns"
dbus set softcenter_module_aliddns_title="阿里DDNS"
dbus set softcenter_module_aliddns_description="aliddns"

# re-enable aliddns
if [ "$enable" == "1" ];then
	sh /jffs/softcenter/scripts/aliddns_config.sh
fi

# 完成
echo_date 阿里ddns插件安装完毕！
rm -rf /tmp/aliddns* >/dev/null 2>&1
exit 0

