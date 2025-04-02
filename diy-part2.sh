#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# 创建目标文件夹
mkdir -p ./files/etc/config

# 写入 network 配置文件
cat <<'EOF' > ./files/etc/config/network
config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '10.10.10.66'
        option netmask '255.255.255.0'
        option gateway '10.10.10.1'
        list dns '10.10.10.1'
        option delegate '0'
EOF

# 写入 dhcp 配置文件
cat <<'EOF' > ./files/etc/config/dhcp
config dhcp 'lan'
        option interface 'lan'
        option start '50'
        option limit '200'
        option leasetime '12h'
        option dhcpv4 'server'
        option ignore '1'
        option dynamicdhcp '0'
EOF
