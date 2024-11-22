# OpenWRT-CI
云编译OpenWRT固件

OpenWRT源码：[OpenWRT](https://github.com/openwrt/openwrt)

LEDE源码：[LEDE](https://github.com/coolsnowwolf/lede)

ImmortalWRT源码：[ImmortalWRT](https://github.com/immortalwrt/immortalwrt)

Hanwckf源码：[Hanwckf](https://github.com/hanwckf/immortalwrt-mt798x)

Padavanonly源码：[Padavanonly](https://github.com/padavanonly/immortalwrt-mt798x-23.05)

# 参数简要说明

Secrets参数:
    
    MY_TOKEN 私人令牌
    
    WIFI_PASSWORD 无线密码

Variables(vars)参数:
    
    WIFI_SSID 无线名称
        
    PRIVATE_REPO_NAME 私人仓库名称

# 固件简要说明：

固件每5天早上2点15分自动编译。

固件信息里的时间为编译完成的时间。

MEDIATEK系列：RAX3000M NAND。

修改自 [VIKINGYFY](https://github.com/VIKINGYFY/OpenWRT-CI) , [lgs2007m](https://github.com/lgs2007m/Actions-OpenWrt) 。

# 目录简要说明：

workflows——自定义CI配置

Config——自定义配置

Scripts——自定义脚本
