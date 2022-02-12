from aospdtgen.proprietary_files.section import Section, register_section

class TrustedUiSection(Section):
	name = "Trusted UI"
	interfaces = [
		"vendor.qti.hardware.trustedui",
		"vendor.qti.hardware.tui_comm",
	]
	binaries = [
		"TrustedUISampleTest",
	]
	libraries = [
		"libTrustedUITZ",
	]

register_section(TrustedUiSection)
