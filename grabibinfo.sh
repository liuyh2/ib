#!/bin/bash
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
bred(){
    echo -e "\033[31m\033[01m\033[05m$1\033[0m"
}
byellow(){
    echo -e "\033[33m\033[01m\033[05m$1\033[0m"
}
hostname=`hostname`
ts=`date   "+%Y_%m_%d_%H_%M"`
filename="/tmp/$hostname"_"$ts".txt
red "ofed_info": |tee -a $filename
ofed_info  -s |tee -a $filename
red "lscpi":  |tee -a $filename
lspci |grep -i mellanox  |tee -a $filename
red  "ibstat:"  |tee -a $filename
ibstat  |tee -a $filename
mst start  >> /dev/null
red "ib recomdation:"  |tee -a $filename
mlxlink -d /dev/mst/mt4123_pciconf0  -m |grep -i Recommendation  |tee -a $filename
red  "iblinkinfo -D 0,1"  |tee -a $filename
iblinkinfo -D 0,1  |tee -a $filename
red "sminfo:"  |tee -a $filename
sminfo  |tee -a $filename
swber=`iblinkinfo -D 0,1|grep `hostname`|sed 's/\[//g'|awk '{system("mlxlink -d lid-" $1 " -port " $2 " -c |grep BER|grep Eff")}'| awk -F : '{print $2}'|cut -d '-' -f 2`
hcaber=`mlxlink -d /dev/mst/mt4123_pciconf0  -c|grep BER|grep Eff|awk -F : '{print $2}'|cut -d '-' -f 2`
red "swber:$swber, hcaber:$hcaber"  |tee -a $filename

red "dmesg:"  |tee -a $filename
dmesg -T |grep  -i mlx|grep -v irq  |tee -a $filename
red "sw fireware:"  |tee -a $filename
lid=`iblinkinfo -D 0,1 |grep -i hca|head -n 1 |awk '{print $1}'`
flint -d lid-$lid q  |tee -a $filename
temp=`mget_temp -d /dev/mst/mt4123_pciconf0`
swtemp=`mget_temp -d lid-$lid`
red "hca temp:$temp     sw temp:$swtemp"   |tee -a $filename

swnum=`ibswitches |wc -l`
nodes=`ibhosts|wc -l`
red    "switches:$swnum hosts:$nodes"  |tee -a $filename


red "ifconfig"   |tee -a $filename
ifconfig  |tee -a $filename
red  "the file save in: $filename" |tee -a $filename

smlid=`ibstat |grep -i 'sm lid'|head -n 1 |awk -F : '{print $2}'`
baselid=`ibstat |grep -i 'Base lid'|head -n 1 |awk -F :  '{print $2}'`
red "ibtracert" |tee -a $filename
ibtracert  $smlid   $baselid  |tee -a $filename
opensmnode=`smpquery  nd $smlid|awk -F '.' '{print $NF}'|awk '{print $1}'`
green  "please  exec  cat /var/log/opensm|grep -i `hostname`  in opensm node: $opensmnode!"  |tee -a $filename
