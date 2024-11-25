#!/bin/bash

# 安装和更新软件包
UPDATE_PACKAGE() {
    local PKG_NAME=$1
    local PKG_REPO=$2
    local PKG_BRANCH=$3
    local PKG_SPECIAL=$4
    local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

    # 删除现有的软件包目录
    rm -rf $(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune)
    
    if [[ $PKG_NME == "mosdns" ]]; then
        rm -rf $(find ../feeds/packages/ -maxdepth 3 -type d -iname "*v2ray_geodata*" -prune)
    fi
    
    # 克隆指定分支的仓库
    git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

    # 根据 PKG_SPECIAL 参数处理不同情况
    if [[ $PKG_SPECIAL == "select" ]]; then
        cp -rf $(find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune) ./
        rm -rf ./$REPO_NAME/
    elif [[ $PKG_SPECIAL == "rename" ]]; then
        mv -f $REPO_NAME $PKG_NAME
    fi
}

#UPDATE_PACKAGE "包名" "地址" "分支" "select/rename 从中提取包名插件/重命名为包名"
#UPDATE_PACKAGE "argon" "jerrykuku/luci-theme-argon" "master"
#UPDATE_PACKAGE "argon-config" "jerrykuku/luci-app-argon-config" "master"
UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5"
if [[ $WRT_UNAME != "immortalwrt" ]]; then
    UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "main"
fi

# 更新软件组件包
UPDATE_VERSION() {
    local PKG_NAME="$1"
    local PKG_REPO="$2"
    local BRANCH="$3"

    local FOUND_DIR=$(find ./ ../feeds/ -maxdepth 5 -type f -path "*/$PKG_NAME/Makefile")

    echo
    if [ -z "$FOUND_DIR" ]; then
        echo "未找到本地 Makefile 目录: ${PKG_NAME}"
        return
    fi

    echo "$PKG_NAME 版本检查开始!"
    local URL="https://api.github.com/repos/${PKG_REPO}"

    if [ -n "$BRANCH" ]; then
        if [ "$PKG_NAME" == "v2ray-geodata" ]; then
            local GITHUB_RAW_URL="https://raw.githubusercontent.com/${PKG_REPO}/${BRANCH}/Makefile"
            if curl -fsSL "${GITHUB_RAW_URL}" -o "${FOUND_DIR}"; then
                echo "Makefile 已更新: ${FOUND_DIR}"
            else
                echo "更新失败: ${GITHUB_RAW_URL}"
                return 1
            fi
            return
        else
            local PKG_INFO="$(curl -s "${URL}/commits" | jq -r 'map(select(.commit.message | contains(" to ")))[].commit.message')"
            local NEW_VER="$(echo "$PKG_INFO" | grep "$PKG_NAME" | head -n 1 | awk -F' ' '{print $4}')"
            if [ "$PKG_NAME" == "golang" ]; then
                local OLD_VER="$(grep -Po ".*_VERSION_MAJOR_MINOR:=\K.*" "$FOUND_DIR").$(grep -Po ".*_VERSION_PATCH:=\K.*" "$FOUND_DIR")"
            else
                local OLD_VER="$(grep -Po "PKG_VERSION:=\K.*" "$FOUND_DIR")"
            fi
        fi
    else
        local PKG_INFO="$(curl -sL "${URL}/releases/latest")"
        local NEW_VER="$(echo "$PKG_INFO" | jq -r '.tag_name' | sed "s/.*v//g; s/_/./g")"
        local OLD_VER="$(grep -Po "PKG_VERSION:=\K.*" "$FOUND_DIR")"
    fi

    echo "$PKG_NAME 当前版本: $OLD_VER, 最新版本: $NEW_VER"

    if [[ "$NEW_VER" =~ ^[0-9] ]] && [[ "$(printf '%s\n' "$OLD_VER" "$NEW_VER" | sort -V | head -n1)" != "$NEW_VER" ]]; then
        if [ "$PKG_NAME" = "golang" ]; then
            rm -rf ./../feeds/packages/lang/golang
            git clone https://github.com/$PKG_REPO -b "$BRANCH" ./../feeds/packages/lang/golang
        elif [ "$PKG_NAME" = "chinadns-ng" ]; then
            local GITHUB_RAW_URL="https://raw.githubusercontent.com/${PKG_REPO}/${BRANCH}/${PKG_NAME}/Makefile"
            if curl -fsSL "${GITHUB_RAW_URL}" -o "${FOUND_DIR}"; then
                echo "Makefile 已更新: ${FOUND_DIR}"
            else
                echo "更新失败: ${GITHUB_RAW_URL}"
                return 1
            fi
        else
            local NEW_HASH=$(curl -sL "https://codeload.github.com/${PKG_REPO}/tar.gz/v${NEW_VER}" | sha256sum | cut -b -64)
            sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$FOUND_DIR"
            sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$FOUND_DIR"
            echo "新的PKG_HASH: $NEW_HASH"
        fi
        echo "$PKG_NAME 已更新到 $NEW_VER !"
    fi
}

#UPDATE_VERSION "包名" "项目名" "分支" "更新标识"
UPDATE_VERSION "chinadns-ng" "xiaorouji/openwrt-passwall-packages" "main"
if [[ $WRT_UNAME != "immortalwrt" ]]; then
    UPDATE_VERSION "v2ray-geodata" "sbwml/v2ray-geodata" "master"
    UPDATE_VERSION "xray-core" "XTLS/Xray-core"
fi
UPDATE_VERSION "golang" "sbwml/packages_lang_golang" "23.x"
UPDATE_VERSION "sing-box" "SagerNet/sing-box"
