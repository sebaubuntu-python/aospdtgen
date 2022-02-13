from aospdtgen.proprietary_files.section import Section, register_section

class DspSection(Section):
	name = "DSP"
	interfaces = [
		"vendor.qti.hardware.dsp",
	]
	binaries = [
		"dspservice",
	]
	filenames = [
		"vendor.qti.hardware.dsp.policy",
	]

register_section(DspSection)
