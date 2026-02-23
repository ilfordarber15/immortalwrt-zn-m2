#!/bin/bash
#
# DIY script part 2 (After Update feeds)
# Add ZN-M2 device support to official immortalwrt
#

# ============================================================
# a) Create ZN-M2 DTS file
# ============================================================
DTS_DIR="target/linux/qualcommax/files/arch/arm64/boot/dts/qcom"

cat > "$DTS_DIR/ipq6000-zn-m2.dts" << 'DTS_EOF'
// SPDX-License-Identifier: GPL-2.0-or-later OR MIT

/dts-v1/;

#include "ipq6018-512m.dtsi"
#include "ipq6018-ess.dtsi"

#include <dt-bindings/gpio/gpio.h>
#include <dt-bindings/input/input.h>
#include <dt-bindings/leds/common.h>

/ {
	model = "ZN M2";
	compatible = "zn,m2", "qcom,ipq6018";

	aliases {
		serial0 = &blsp1_uart3;
		led-boot = &led_power;
		led-failsafe = &led_power;
		led-running = &led_power;
		led-upgrade = &led_power;

		ethernet0 = &dp1;
		ethernet1 = &dp2;
		ethernet3 = &dp4;
		ethernet4 = &dp5;
	};

	chosen {
		stdout-path = "serial0:115200n8";
		bootargs-append = " root=/dev/ubiblock0_1";
	};

	keys {
		compatible = "gpio-keys";

		reset {
			label = "reset";
			gpios = <&tlmm 60 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_RESTART>;
		};

		wps {
			label = "wps";
			gpios = <&tlmm 9 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_WPS_BUTTON>;
		};
	};

	leds {
		compatible = "gpio-leds";

		led_power: power {
			label = "blue:power";
			gpios = <&tlmm 58 GPIO_ACTIVE_HIGH>;
		};

		mesh {
			label = "blue:mesh";
			gpios = <&tlmm 73 GPIO_ACTIVE_HIGH>;
		};

		lan {
			label = "blue:lan";
			gpios = <&tlmm 74 GPIO_ACTIVE_HIGH>;
		};

		wan {
			label = "blue:wan";
			gpios = <&tlmm 37 GPIO_ACTIVE_HIGH>;
		};

		wlan5g {
			label = "blue:wlan5g";
			gpios = <&tlmm 35 GPIO_ACTIVE_HIGH>;
		};

		wlan2g {
			label = "blue:wlan2g";
			gpios = <&tlmm 70 GPIO_ACTIVE_HIGH>;
		};
	};
};

&tlmm {
	gpio-reserved-ranges = <20 1>;

	mdio_pins: mdio-pins {
		mdc {
			pins = "gpio64";
			function = "mdc";
			drive-strength = <8>;
			bias-pull-up;
		};

		mdio {
			pins = "gpio65";
			function = "mdio";
			drive-strength = <8>;
			bias-pull-up;
		};
	};
};

&blsp1_uart3 {
	status = "okay";
	pinctrl-0 = <&serial_3_pins>;
	pinctrl-names = "default";
};

&crypto {
	status = "okay";
};

&cryptobam {
	status = "okay";
};

&prng {
	status = "okay";
};

&qpic_bam {
	status = "okay";
};

&qusb_phy_0 {
	status = "okay";
};

&ssphy_0 {
	status = "okay";
};

&usb3 {
	status = "okay";
};

&mdio {
	status = "okay";

	pinctrl-0 = <&mdio_pins>;
	pinctrl-names = "default";
	reset-gpios = <&tlmm 75 GPIO_ACTIVE_LOW>;

	ethernet-phy-package@0 {
		compatible = "qcom,qca8075-package";
		#address-cells = <1>;
		#size-cells = <0>;
		reg = <0>;

		qca8075_0: ethernet-phy@0 {
			compatible = "ethernet-phy-ieee802.3-c22";
			reg = <0>;
		};

		qca8075_1: ethernet-phy@1 {
			compatible = "ethernet-phy-ieee802.3-c22";
			reg = <1>;
		};

		qca8075_3: ethernet-phy@3 {
			compatible = "ethernet-phy-ieee802.3-c22";
			reg = <3>;
		};

		qca8075_4: ethernet-phy@4 {
			compatible = "ethernet-phy-ieee802.3-c22";
			reg = <4>;
		};
	};
};

&switch {
	status = "okay";

	switch_lan_bmp = <(ESS_PORT1 | ESS_PORT2 | ESS_PORT4)>;
	switch_wan_bmp = <ESS_PORT5>;
	switch_mac_mode = <MAC_MODE_PSGMII>;

	qcom,port_phyinfo {
		port@1 {
			port_id = <1>;
			phy_address = <0>;
		};

		port@2 {
			port_id = <2>;
			phy_address = <1>;
		};

		port@4 {
			port_id = <4>;
			phy_address = <3>;
		};

		port@5 {
			port_id = <5>;
			phy_address = <4>;
		};
	};
};

&qpic_nand {
	status = "okay";

	nand@0 {
		#address-cells = <1>;
		#size-cells = <1>;
		reg = <0>;

		nand-ecc-strength = <4>;
		nand-ecc-step-size = <512>;
		nand-bus-width = <8>;

		partitions {
			compatible = "qcom,smem-part";
		};
	};
};

&dp1 {
	status = "okay";
	phy-handle = <&qca8075_0>;
	label = "lan3";
};

&dp2 {
	status = "okay";
	phy-handle = <&qca8075_1>;
	label = "lan2";
};

&dp4 {
	status = "okay";
	phy-handle = <&qca8075_3>;
	label = "lan1";
};

&dp5 {
	status = "okay";
	phy-handle = <&qca8075_4>;
	label = "wan";
};

&edma {
	status = "okay";
};

&wifi {
	status = "okay";
	qcom,ath11k-fw-memory-mode = <1>;
	qcom,ath11k-calibration-variant = "ZN-M2";
};
DTS_EOF
echo "ZN-M2 DTS created OK"

# ============================================================
# b) Append device definition to ipq60xx.mk (if not exists)
# ============================================================
MK_FILE="target/linux/qualcommax/image/ipq60xx.mk"
if ! grep -q "Device/zn_m2" "$MK_FILE"; then
    cat >> "$MK_FILE" << 'MK_EOF'

define Device/zn_m2
  $(call Device/FitImage)
  $(call Device/UbiFit)
  DEVICE_VENDOR := ZN
  DEVICE_MODEL := M2
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  SOC := ipq6000
  DEVICE_DTS := ipq6000-zn-m2
  DEVICE_DTS_CONFIG := config@cp03-c1
  DEVICE_PACKAGES := ipq-wifi-zn_m2
endef
TARGET_DEVICES += zn_m2
MK_EOF
    echo "ZN-M2 device definition added to ipq60xx.mk"
else
    echo "ZN-M2 device definition already exists in ipq60xx.mk"
fi

# ============================================================
# c) Register WiFi firmware in ipq-wifi Makefile (if not exists)
# ============================================================
WIFI_MK="package/firmware/ipq-wifi/Makefile"
if ! grep -q "zn_m2" "$WIFI_MK"; then
    # Add to ALLWIFIBOARDS: append \ to last entry and add zn_m2
    sed -i '/^[[:space:]]*zyxel_scr50axe[[:space:]]*$/s/[[:space:]]*$/ \\/' "$WIFI_MK"
    sed -i '/zyxel_scr50axe.*\\/a\\tzn_m2' "$WIFI_MK"
    # Add generate-ipq-wifi-package call
    sed -i '/generate-ipq-wifi-package,zyxel_scr50axe/a\$(eval $(call generate-ipq-wifi-package,zn_m2,ZN M2))' "$WIFI_MK"
    echo "ZN-M2 WiFi firmware registered"
else
    echo "ZN-M2 WiFi firmware already registered"
fi

# ============================================================
# d) Add WiFi calibration board file
# ============================================================
BOARD_FILE="package/firmware/ipq-wifi/board-zn_m2.ipq6018"
if [ ! -f "$BOARD_FILE" ]; then
    # Copy from repo's files directory (bundled with this build system)
    if [ -f "files/board-zn_m2.ipq6018" ]; then
        cp "files/board-zn_m2.ipq6018" "$BOARD_FILE"
        echo "WiFi board file copied from files/ ($(wc -c < "$BOARD_FILE") bytes)"
    elif [ -f "$GITHUB_WORKSPACE/files/board-zn_m2.ipq6018" ]; then
        cp "$GITHUB_WORKSPACE/files/board-zn_m2.ipq6018" "$BOARD_FILE"
        echo "WiFi board file copied from workspace ($(wc -c < "$BOARD_FILE") bytes)"
    else
        # Fallback: download from breeze303's repo
        wget -q -O "$BOARD_FILE" \
            "https://raw.githubusercontent.com/breeze303/immortalwrt/main/package/firmware/ipq-wifi/board-zn_m2.ipq6018" \
            2>/dev/null
        if [ -s "$BOARD_FILE" ]; then
            echo "WiFi board file downloaded OK ($(wc -c < "$BOARD_FILE") bytes)"
        else
            echo "WARNING: WiFi board file not found - copy manually"
            rm -f "$BOARD_FILE"
        fi
    fi
else
    echo "WiFi board file already exists"
fi

# ============================================================
# e) Add network configuration (if not exists)
# ============================================================
NETWORK_FILE="target/linux/qualcommax/ipq60xx/base-files/etc/board.d/02_network"
if ! grep -q "zn,m2" "$NETWORK_FILE"; then
    # Add zn,m2 to the 3-LAN + WAN case block (first occurrence only, in ucidef_set_interfaces section)
    sed -i '0,/qihoo,360v6)/{/qihoo,360v6)/i\\tzn,m2|\\
}' "$NETWORK_FILE"
    echo "ZN-M2 network config added"
else
    echo "ZN-M2 network config already exists"
fi

# ============================================================
# f) Add upgrade support (if not exists)
# ============================================================
PLATFORM_FILE="target/linux/qualcommax/ipq60xx/base-files/lib/upgrade/platform.sh"
if ! grep -q "zn,m2" "$PLATFORM_FILE"; then
    # Add zn,m2 to the nand_do_upgrade block (alongside similar devices)
    sed -i '/glinet,gl-ax1800/i\\tzn,m2|\\' "$PLATFORM_FILE"
    echo "ZN-M2 upgrade support added"
else
    echo "ZN-M2 upgrade support already exists"
fi

# ============================================================
# g) Add WiFi caldata hotplug (if not exists)
# ============================================================
CALDATA_FILE="target/linux/qualcommax/ipq60xx/base-files/etc/hotplug.d/firmware/11-ath11k-caldata"
if ! grep -q "zn,m2" "$CALDATA_FILE"; then
    # Add zn,m2 to the caldata_extract "0:art" block
    sed -i '/qihoo,360v6/i\\tzn,m2|\\' "$CALDATA_FILE"
    echo "ZN-M2 caldata hotplug added"
else
    echo "ZN-M2 caldata hotplug already exists"
fi

# ============================================================
# Customizations
# ============================================================

# Modify default IP
sed -i 's/192.168.1.1/192.168.20.1/g' package/base-files/files/bin/config_generate

# Set default password to 'password'
sed -i '/^root:/c\root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::' package/base-files/files/etc/shadow

# Argon theme
rm -rf feeds/luci/themes/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# Fix Makefile paths for external packages
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}

# Remove default theme setting
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

echo "diy-part2.sh completed successfully"
