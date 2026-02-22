# ImmortalWrt ZN-M2 Builder

[![Build Status](https://github.com/ilfordarber15/immortalwrt-zn-m2/actions/workflows/openwrt-builder.yml/badge.svg)](https://github.com/ilfordarber15/immortalwrt-zn-m2/actions/workflows/openwrt-builder.yml)
[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=LICENSE)](https://github.com/ilfordarber15/immortalwrt-zn-m2/blob/main/LICENSE)

基于 GitHub Actions 云编译的 ImmortalWrt 固件，专为 **ZN-M2** 路由器定制。

## 硬件信息

| 项目 | 规格 |
|------|------|
| 设备 | ZN-M2 |
| 平台 | Qualcomm IPQ6000 (qualcommax) |
| 架构 | ARM64 (aarch64_cortex-a53) |
| 内存 | 512MB |
| 闪存 | NAND |
| WiFi | ath11k 双频 AX1800 |
| 网口 | 3 LAN + 1 WAN |

## 固件特性

- **官方 ImmortalWrt** - 基于 immortalwrt/immortalwrt master 分支
- **Argon 主题** - 美观的 LuCI 管理界面
- **无线中继** - relayd 客户端+AP 桥接
- **wpad-openssl** - 完整的 WPA/802.1x 支持
- **ZRAM** - 内存压缩交换
- **ttyd** - Web 终端
- **UPnP** - 自动端口映射

## 默认配置

- 管理地址：`192.168.20.1`
- 默认用户：`root`
- 默认密码：`password`

## 源码

| 项目 | 来源 |
|------|------|
| 固件源码 | [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt) (master 分支) |
| 编译模板 | [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) |

## 项目结构

```
.config                              # 固件功能配置（设备、软件包选择）
diy-part1.sh                         # feeds 更新前执行
diy-part2.sh                         # feeds 安装后执行（DTS、设备定义、IP修改、主题安装）
files/board-zn_m2.ipq6018            # WiFi 校准数据文件
.github/workflows/openwrt-builder.yml # CI 编译流水线
```

## 使用方法

1. Fork 本仓库
2. 进入 **Actions** 页面，选择 **ImmortalWrt ZN-M2 Builder**
3. 点击 **Run workflow** 手动触发编译
4. 编译完成后在 [Releases](https://github.com/ilfordarber15/immortalwrt-zn-m2/releases) 下载固件
5. 通过 breed 刷入 `factory.ubi`，或通过 LuCI 刷入 `sysupgrade.bin`

## License

[MIT](https://github.com/ilfordarber15/immortalwrt-zn-m2/blob/main/LICENSE) © [P3TERX](https://p3terx.com)
