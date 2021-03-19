from aospdtgen.proprietary_files.section import Section, register_section

class FingerprintSection(Section):
	name = "Fingerprint"
	interfaces = [
		"android.hardware.biometrics.fingerprint",
		"vendor.goodix.hardware.biometrics.fingerprint",
		"vendor.xiaomi.hardware.fingerprintextension",
	]
	hardware_modules = [
		"fingerprint",
		"gf_fingerprint",
	]

register_section(FingerprintSection)
