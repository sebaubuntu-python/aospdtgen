from aospdtgen.proprietary_files.section import Section, register_section

class RadioSection(Section):
	name = "Radio"
	interfaces = [
		"android.hardware.radio",
		"mtkfusionrild",
		"qcrild",
		"vendor.mediatek.hardware.mtkradioex",
		"vendor.mediatek.hardware.radio",
		"vendor.qti.hardware.radio.am",
		"vendor.qti.hardware.radio.atcmdfwd",
		"vendor.qti.hardware.radio.internal.deviceinfo",
		"vendor.qti.hardware.radio.lpa",
		"vendor.qti.hardware.radio.qcrilhook",
		"vendor.qti.hardware.radio.qtiradio",
		"vendor.qti.hardware.radio.uim",
	]
	hardware_modules = [
		"radio",
	]
	apps = [
		"IWlanService",
		"QtiTelephonyService",
		"qcrilmsgtunnel",
	]
	binaries = [
		"ATFWD-daemon",
		"adpl",
		"ks",
		"mdm_helper",
		"netmgrd",
		"pd-mapper",
		"port-bridge",
		"qrtr-cfg",
		"qrtr-lookup",
		"qrtr-ns",
		"qti",
		"rmt_storage",
		"ssgtzd",
		"tftp_server",
	]
	folders = [
		"radio/qcril_database",
	]
	patterns = [
		"etc/seccomp_policy/atfwd(@[0-9]+\.[0-9]+)?.policy",
	]

class RadioImsSection(Section):
	name = "Radio (IMS)"
	interfaces = [
		"com.qualcomm.qti.imscmservice",
		"com.qualcomm.qti.uceservice",
		"vendor.qti.hardware.radio.ims",
		"vendor.qti.ims.callcapability",
		"vendor.qti.ims.callinfo",
		"vendor.qti.ims.factory",
		"vendor.qti.ims.rcsconfig",
		"vendor.qti.imsrtpservice",
	]
	apps = [
		"ims",
	]
	filenames = [
		"imsrtp.policy",
	]

register_section(RadioSection)
register_section(RadioImsSection)
