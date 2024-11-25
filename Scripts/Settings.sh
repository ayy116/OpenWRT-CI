#!/bin/bash

# 修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")

CFG_FILE="./package/base-files/files/bin/config_generate"
# 修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
# 修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
# 修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")

# 机型及特殊插件
if [[ $WRT_UNAME != "immortalwrt" ]]; then
    sed -i "/CONFIG_TARGET_DEVICE_mediatek_mt7981_DEVICE_.*=y/{ /_rax3000m=/!{ s/^/#/; s/=y/ is not set/; } }" ./.config
    echo "CONFIG_PACKAGE_luci-app-passwall=y" >> ./.config
    echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray=y" >> ./.config
else
    echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ./.config
fi

# 配置文件修改
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "# CONFIG_PACKAGE_luci-app-$WRT_THEME-config is not set" >> ./.config
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config