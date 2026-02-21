#!/bin/bash
#
# DIY script part 2 (After Update feeds)
#

# 修复 skbuff_recycle.c 中 skb_release_data 参数不匹配问题（NSS与6.12内核兼容性）
# Linux 6.12 中 skb_release_data 签名变为 (skb, reason)，去掉了第三个 bool 参数
sed -i 's/#if LINUX_VERSION_CODE >= KERNEL_VERSION(6,2,0)/#if LINUX_VERSION_CODE >= KERNEL_VERSION(6,12,0)\n\t\tskb_release_data(skb, SKB_CONSUMED);\n#elif LINUX_VERSION_CODE >= KERNEL_VERSION(6,2,0)/' target/linux/qualcommax/files/net/core/skbuff_recycle.c

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.20.1/g' package/base-files/files/bin/config_generate

# Argon 主题
rm -rf feeds/luci/themes/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# 修改 Makefile 路径
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;
