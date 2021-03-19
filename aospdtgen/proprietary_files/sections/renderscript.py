from aospdtgen.proprietary_files.section import Section, register_section

class RenderscriptSection(Section):
	name = "RenderScript"
	interfaces = [
		"android.hardware.renderscript",
	]

register_section(RenderscriptSection)
