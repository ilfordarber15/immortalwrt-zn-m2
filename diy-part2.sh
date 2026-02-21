#!/bin/bash
#
# DIY script part 2 (After Update feeds)
#

# 修复 skbuff_recycle.c 中 skb_release_data 参数不匹配问题（NSS与6.12内核兼容性）
# Linux 6.12 中 skb_release_data 签名变为 (skb, reason)，去掉了第三个 bool 参数
sed -i 's/#if LINUX_VERSION_CODE >= KERNEL_VERSION(6,2,0)/#if LINUX_VERSION_CODE >= KERNEL_VERSION(6,12,0)\n\t\tskb_release_data(skb, SKB_CONSUMED);\n#elif LINUX_VERSION_CODE >= KERNEL_VERSION(6,2,0)/' target/linux/qualcommax/files/net/core/skbuff_recycle.c

# 修复 mac80211 补丁 237 应用失败问题
# backports 6.12.6 中 acpi_amd_wbrf.h 已不存在，需要删除补丁中对应部分
# 方法：删除原补丁，替换为只包含前两个有效 hunk 的版本
cat > package/kernel/mac80211/patches/build/237-add_kernel_6.12_support.patch << 'PATCH_EOF'
--- a/backport-include/asm/unaligned.h
+++ b/backport-include/asm/unaligned.h
@@ -1,6 +1,6 @@
 #ifndef __BACKPORT_ASM_GENERIC_UNALIGNED_H
 #define __BACKPORT_ASM_GENERIC_UNALIGNED_H
-#include_next <asm/unaligned.h>
+#include_next <linux/unaligned.h>

 #if LINUX_VERSION_IS_LESS(5,7,0)
 static inline u32 __get_unaligned_be24(const u8 *p)
--- a/net/mac80211/rc80211_minstrel_ht_debugfs.c
+++ b/net/mac80211/rc80211_minstrel_ht_debugfs.c
@@ -187,7 +187,7 @@ static const struct file_operations mins
 	.open = minstrel_ht_stats_open,
 	.read = minstrel_stats_read,
 	.release = minstrel_stats_release,
-	.llseek = no_llseek,
+	.llseek = noop_llseek,
 };

 static char *
@@ -323,7 +323,7 @@ static const struct file_operations mins
 	.open = minstrel_ht_stats_csv_open,
 	.read = minstrel_stats_read,
 	.release = minstrel_stats_release,
-	.llseek = no_llseek,
+	.llseek = noop_llseek,
 };

 void
PATCH_EOF
# 同时删除可能残留的 acpi_amd_wbrf.h 文件（如果存在）
rm -f package/kernel/mac80211/files/backport-include/linux/acpi_amd_wbrf.h 2>/dev/null || true

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
