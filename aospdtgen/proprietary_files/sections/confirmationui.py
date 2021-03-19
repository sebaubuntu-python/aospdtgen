from aospdtgen.proprietary_files.section import Section, register_section

class ConfirmationUISection(Section):
	name = "Confirmation UI"
	interfaces = [
		"android.hardware.confirmationui",
	]

register_section(ConfirmationUISection)
