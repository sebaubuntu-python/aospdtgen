from aospdtgen.proprietary_files.section import Section, register_section

class FaceSection(Section):
	name = "Face"
	interfaces = [
		"android.hardware.biometrics.face",
	]

register_section(FaceSection)
