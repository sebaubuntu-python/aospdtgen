from aospdtgen.proprietary_files.section import Section, register_section

class NfcSection(Section):
	name = "NFC"
	interfaces = [
		"android.hardware.nfc",
		"vendor.nxp.hardware.nfc",
	]
	hardware_modules = [
		"nfc",
	]

class NfcConfigsSection(Section):
	name = "NFC configs"
	patterns = [
		"etc/libnfc-.*\.conf"
	]

register_section(NfcSection)
register_section(NfcConfigsSection)
