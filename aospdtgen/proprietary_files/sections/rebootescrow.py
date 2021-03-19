from aospdtgen.proprietary_files.section import Section, register_section

class RebootEscrowSection(Section):
	name = "Reboot escrow"
	interfaces = [
		"android.hardware.rebootescrow",
	]

register_section(RebootEscrowSection)
