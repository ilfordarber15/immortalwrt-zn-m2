# ImmortalWrt ZN-M2 Builder

[![Build Status](https://github.com/ilfordarber15/immortalwrt-zn-m2/actions/workflows/openwrt-builder.yml/badge.svg)](https://github.com/ilfordarber15/immortalwrt-zn-m2/actions/workflows/openwrt-builder.yml)
[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=LICENSE)](https://github.com/ilfordarber15/immortalwrt-zn-m2/blob/main/LICENSE)

基于 GitHub Actions 云编译的 ImmortalWrt 固件，专为 **ZN-M2** 路由器定制。

## 硬件信息

| 项目 | 规格 |
|------|------|
| 设备 | ZN-M2 |
| 平台 | Qualcomm IPQ60xx (qualcommax) |
| 架构 | ARM64 (aarch64_cortex-a53) |
| 内存 | 512MB |

## 固件特性

- **NSS 硬件转发加速** - 高通 NSS Offloading (v12.2)
- **OpenClash** - Clash 代理客户端
- **iStore** - 软件包商店
- **Argon 主题** - 美观的 LuCI 管理界面
- **无线中继** - relayd 客户端+AP 桥接
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
| 固件源码 | [breeze303/immortalwrt](https://github.com/breeze303/immortalwrt) (锁定 commit) |
| 编译模板 | [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) |

## 项目结构

```
.config                              # 固件功能配置（设备、软件包选择）
diy-part1.sh                         # feeds 更新前执行（添加 OpenClash、iStore 源）
diy-part2.sh                         # feeds 安装后执行（内核补丁、IP修改、主题安装）
.github/workflows/openwrt-builder.yml # CI 编译流水线
```

## 使用方法

1. Fork 本仓库
2. 进入 **Actions** 页面，选择 **ImmortalWrt ZN-M2 Builder**
3. 点击 **Run workflow** 手动触发编译
4. 编译完成后在 [Releases](https://github.com/ilfordarber15/immortalwrt-zn-m2/releases) 下载固件

## License

[MIT](https://github.com/ilfordarber15/immortalwrt-zn-m2/blob/main/LICENSE) © [P3TERX](https://p3terx.com)
