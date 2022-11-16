#!/bin/bash
#============================================================
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#============================================================

set -x

CONFIG_FILE="$1"

# # rm -rvf package/admin/netdata
# # svn co https://github.com/immortalwrt/packages/trunk/admin/netdata package/admin/netdata
# grep '^PKG_VERSION' feeds/packages/admin/netdata/Makefile
# rm -rvf feeds/packages/admin/netdata
# svn co https://github.com/immortalwrt/packages/trunk/admin/netdata feeds/packages/admin/netdata
# grep '^PKG_VERSION' feeds/packages/admin/netdata/Makefile

git clone --depth 1 https://github.com/aa65535/openwrt-chinadns.git package/chinadns
git clone --depth 1 https://github.com/aa65535/openwrt-dns-forwarder.git package/dns-forwarder
git clone --depth 1 https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci
git clone --depth 1 https://github.com/shadowsocks/luci-app-shadowsocks.git package/luci-app-shadowsocks
ls -lh package

if echo "$CONFIG_FILE"|grep -i robimarko
then
    # Modify default IP
    sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

    # Modify hostname
    sed -i 's/OpenWrt/robimarko/g' package/base-files/files/bin/config_generate
elif echo "$CONFIG_FILE"|grep -i GL-SFT1200
then
    sed -i '/DISTRIB_REVISION/d' package/base-files/files/etc/openwrt_release
    echo "DISTRIB_REVISION=' GL-iNet Inc'" >> package/base-files/files/etc/openwrt_release
    sed -i '/DISTRIB_DESCRIPTION/d' package/base-files/files/etc/openwrt_release
    echo "DISTRIB_DESCRIPTION='OpenWrt R$(date +%y.%m.%d) '" >> package/base-files/files/etc/openwrt_release
    sed -i 's/192.168.1.1/10.10.10.1/' package/base-files/files/bin/config_generate
    sed -i 's/OpenWrt/GL-SFT1200/' package/base-files/files/bin/config_generate
else
    sed -i 's/OpenWrt/AX1800/g' package/base-files/files/bin/config_generate
fi

# # Modify the version number
# sed -i "s/OpenWrt /GitHub Actions Build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

# Modify default theme
if echo "$CONFIG_FILE"|grep -i GL-SFT1200
then
    sed -i 's/luci-theme-bootstrap/luci-theme-argonv3/g' feeds/luci/collections/luci/Makefile
else
    sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
fi

# Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_USER="LVII"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_USER=\).*@\1$"LVII"@' .config

# Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_DOMAIN=\).*@\1$"GitHub Actions"@' .config

sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf
