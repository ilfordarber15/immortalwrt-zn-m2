#!/bin/bash
#
# DIY script part 2 (After Update feeds)
#

# 修复 skbuff_recycle.c 中 skb_release_data 参数不匹配问题（NSS与6.12内核兼容性）
# Linux 6.12 中 skb_release_data 签名变为 (skb, reason)，去掉了第三个 bool 参数
SKB_FILE="target/linux/qualcommax/files/net/core/skbuff_recycle.c"
if [ -f "$SKB_FILE" ]; then
    sed -i 's/#if LINUX_VERSION_CODE >= KERNEL_VERSION(6,2,0)/#if LINUX_VERSION_CODE >= KERNEL_VERSION(6,12,0)\n\t\tskb_release_data(skb, SKB_CONSUMED);\n#elif LINUX_VERSION_CODE >= KERNEL_VERSION(6,2,0)/' "$SKB_FILE"
    grep -q "KERNEL_VERSION(6,12,0)" "$SKB_FILE" && echo "skbuff_recycle.c patched OK" || echo "WARNING: skbuff_recycle.c patch failed"
fi

# 修复 mac80211 补丁 237 应用失败问题
# backports 6.12.6 中 minstrel_ht_debugfs.c 已无 .llseek 字段，acpi_amd_wbrf.h 已不存在
# 只保留 unaligned.h 的修改
PATCH_FILE="package/kernel/mac80211/patches/build/237-add_kernel_6.12_support.patch"
if [ -f "$PATCH_FILE" ]; then
    cat > "$PATCH_FILE" << 'PATCH_EOF'
--- a/backport-include/asm/unaligned.h
+++ b/backport-include/asm/unaligned.h
@@ -1,6 +1,6 @@
 #ifndef __BACKPORT_ASM_GENERIC_UNALIGNED_H
 #define __BACKPORT_ASM_GENERIC_UNALIGNED_H
-#include_next <asm/unaligned.h>
+#include_next <linux/unaligned.h>

 #if LINUX_VERSION_IS_LESS(5,7,0)
 static inline u32 __get_unaligned_be24(const u8 *p)
PATCH_EOF
    echo "mac80211 patch 237 fixed OK"
fi

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.20.1/g' package/base-files/files/bin/config_generate

# 设置默认密码为 password
sed -i '/^root:/c\root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::' package/base-files/files/etc/shadow

# Argon 主题 (使用 master 分支适配新版 LuCI)
rm -rf feeds/luci/themes/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# 修改 Makefile 路径
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;
