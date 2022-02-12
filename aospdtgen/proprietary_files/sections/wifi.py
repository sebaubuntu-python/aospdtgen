from aospdtgen.proprietary_files.section import Section, register_section

class WifiSection(Section):
	name = "Wi-Fi"
	interfaces = [
		"android.hardware.wifi",
		"vendor.mediatek.hardware.wifi.hostapd",
		"vendor.mediatek.hardware.wifi.supplicant",
		"vendor.qti.hardware.wifi.hostapd",
		"vendor.qti.hardware.wifi.keystore",
		"vendor.qti.hardware.wifi.supplicant",
		"vendor.qti.hardware.wifi.wifilearner",
	]
	binaries = [
		"hostapd",
		"wpa_supplicant",
	]

register_section(WifiSection)
