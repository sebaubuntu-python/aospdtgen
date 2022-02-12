from aospdtgen.proprietary_files.section import Section, register_section

class IpaSection(Section):
	name = "IPA"
	binaries = [
		"ipacm",
		"ipacm-diag",
	]
	libraries = [
		"libipanat",
		"liboffloadhal",
	]
	filenames = [
		"IPACM_cfg.xml",
	]

class IpaFirmwareSection(Section):
	name = "IPA firmware"
	filenames = [
		"ipa_fws.rc",
	]
	patterns = [
		"firmware/.*ipa_fws*.",
	]

register_section(IpaSection)
register_section(IpaFirmwareSection)
