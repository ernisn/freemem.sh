#!/bin/sh

# 颜色
red='\033[0;31m'
green='\033[0;32m'
none='\033[0m'

# 检测 root
[[ $(id -u) != 0 ]] && echo -e "请使用${red} root ${none}用户运行该脚本。" && exit 1

# 检测系统版本
if [ -f /etc/redhat-release ]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
fi

# 安装 Virt-what
if  [ ! -e '/usr/sbin/virt-what' ]; then
    echo "正在安装必要的程序 Virt-What ，请稍后..."
    if [ "${release}" == "centos" ]; then
        yum -y install virt-what > /dev/null 2>&1
    else
        apt-get update
        apt-get -y install virt-what > /dev/null 2>&1
    fi
fi

# 检测虚拟化架构是否为 OpenVZ
if  [ ! -e '/usr/sbin/virt-what' ]; then
    echo ""
    echo -e "${red}Virt-What 安装失败${none}，无法自动判断本机虚拟化架构，故请自行判断；本脚本不支持${red} OpenVZ ${none}。"
else
    virtua=$(virt-what) 2>/dev/null
    [ ${virtua} == "openvz" ] && { echo -e "本机虚拟化架构为${red} OpenVZ ${none}，本脚本不支持${red} OpenVZ ${none}。"; exit 1; }
fi

# 传参执行内存释放
if  [ "$1" == "-p" ] ; then
    sync
    echo 1 > /proc/sys/vm/drop_caches && exit 1
elif [ "$1" == "-di" ] ; then
    sync
    echo 2 > /proc/sys/vm/drop_caches && exit 1
elif [ "$1" == "-pdi" ] ; then
    sync
    echo 3 > /proc/sys/vm/drop_caches && exit 1
elif [ "$1" == "-s" ] ; then
    sync
    swapoff -a && swapon -a && exit 1
elif [ "$1" == "-a" ] || [ "$1" == "-all" ] ; then
    sync
    echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a && exit 1
elif [ "$#" != "0" ] ; then
    echo "————使用说明———————————————————————————————————————————————————————————————————"
    echo -e "  · bash freemem.sh ${green}-p ${none}仅释放 pagecache"
	echo -e "  · bash freemem.sh ${green}-di ${none}释放 dentries + inodes"
	echo -e "  · bash freemem.sh ${green}-pdi ${none}释放 pagecache + dentries + inodes"
	echo -e "  · bash freemem.sh ${green}-s ${none}释放 swap"
	echo -e "  · bash freemem.sh ${green}-a/-all ${none}释放 pagecache + dentries + inodes + swap"
	echo "———————————————————————————————————————————————————————————————————————————————"
	exit 1
fi

# 清理前内存
echo "————当前内存使用情况———————————————————————————————————————————————————————————"
free -h
echo "———————————————————————————————————————————————————————————————————————————————"

# 未传参执行内存释放
echo "请选择内存释放方式:"
echo -e "  ${green}1 ${none}仅释放 pagecache"
echo -e "  ${green}2 ${none}释放 dentries + inodes"
echo -e "  ${green}3 ${none}释放 pagecache + dentries + inodes"
echo -e "  ${green}4 ${none}释放 swap"
echo -e "  * 按${green} Ctrl + C ${none}可取消释放内存"
echo "———————————————————————————————————————————————————————————————————————————————"
read -p "输入数值进行选择 (默认:1): " selection
if  [ ! -n "$selection" ] ; then
    echo "未进行选择，默认仅释放 pagecache 。"
else
    while [ -n "$selection" ] && [ "$selection" != 1 ] && [ "$selection" != 2 ] && [ "$selection" != 3 ] && [ "$selection" != 4 ]
        do
	    echo -e "${red}输入错误${none}，请确认输入为${green} 1 ${none}-${green} 4 ${none}的整数"
        read -p "请重新输入数值进行选择 (默认:1): " selection
		[ ! -n "$selection" ] && echo "未进行选择，默认仅释放 pagecache 。" 
    done
fi
echo "  · 同步数据中..."
sync
echo "  · 完成同步，开始释放内存..."
[ ! -n "$selection" ] || [ "$selection" == 1 ] && echo "  · 释放 pagecache 中..." && echo 1 > /proc/sys/vm/drop_caches
[ "$selection" == 2 ] && echo "  · 释放 dentries + inodes 中..." && echo 2 > /proc/sys/vm/drop_caches
[ "$selection" == 3 ] && echo "  · 释放 pagecache + dentries + inodes 中..." && echo 3 > /proc/sys/vm/drop_caches
[ "$selection" == 4 ] && echo "  · 释放 swap 中..." && swapoff -a && swapon -a
echo "  · 内存释放完成。"

# 清理后内存
echo "————当前内存使用情况———————————————————————————————————————————————————————————"
free -h
echo "———————————————————————————————————————————————————————————————————————————————"