#!/bin/sh

# Colors
red='\e[91m'
green='\e[92m'
none='\e[0m'

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
    echo -e "${red}Virt-What 安装失败${none}，无法自动判断本机虚拟化"
	echo -e "架构，故请自行判断；本脚本不支持${red} OpenVZ ${none}。"
else
    virtua=$(virt-what) 2>/dev/null
    [ ${virtua} == "openvz" ] && { echo -e "本机虚拟化架构为${red} OpenVZ ${none}，本脚本不支持${red} OpenVZ ${none}。"; exit 1; }
fi

# 执行内存释放
echo "--------------------"
echo "当前内存使用情况:"
free -m
echo "--------------------"
echo "选择内存释放方式:"
echo -e "${green}1. ${none}仅释放 pagecache"
echo -e "${green}2. ${none}释放 dentries + inodes"
echo -e "${green}3. ${none}释放 pagecache + dentries + inodes"
echo -e "按${green} Ctrl + C ${none}可取消释放内存"
echo "--------------------"
read -p "输入数值进行选择: " selection
while [ "$selection" != 1 ] && [ "$selection" != 2 ] && [ "$selection" != 3 ]
    do
	echo -e "${red}输入错误${none}，你输的真的是${green} 1 ${none}或${green} 2 ${none}或${green} 3 ${none}吗？"
    read -p "请重新输入数值进行选择: " selection
done
echo "同步数据中..."
sync
echo "完成同步，开始释放内存..."
if [ "$selection" == 1 ]
    then
        echo "释放 pagecache 中..."
        echo 1 > /proc/sys/vm/drop_caches
fi
if [ "$selection" == 2 ]
    then
        echo "释放 dentries + inodes 中..."
        echo 2 > /proc/sys/vm/drop_caches
fi
if [ "$selection" == 3 ]
    then
        echo "释放 pagecache + dentries + inodes 中..."
        echo 3 > /proc/sys/vm/drop_caches
fi
echo "--------------------"
echo "内存释放完成，清理后内存使用情况:"
free -m
echo "--------------------"
