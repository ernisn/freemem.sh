#!/bin/sh

red='\e[91m'
green='\e[92m'
none='\e[0m'

selection=1

echo ""
echo "当前内存使用情况:"
free -m

echo ""
echo "选择内存释放方式:"
echo -e "${green}1. ${none}仅释放 pagecache"
echo -e "${green}2. ${none}释放 dentries + inodes"
echo -e "${green}3. ${none}释放 pagecache + dentries + inodes"
echo "--------------------"
echo -e "按${green} Ctrl + C ${none}可取消释放内存"
echo "--------------------"
read -p "输入数值进行选择: " selection

while [ "$selection" != "1" ] && [ "$selection" != "2" ] && [ "$selection" != "3" ]
    do
	echo -e "${red}输入错误${none}，你输的这玩意儿是个啥嘛..."
    read -p "请重新输入数值进行选择: " selection
done

echo ""
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

echo ""
echo "内存释放完成，清理后内存使用情况:"
free -m
echo ""