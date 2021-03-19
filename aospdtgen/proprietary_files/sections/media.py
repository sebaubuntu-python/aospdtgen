from aospdtgen.proprietary_files.section import Section, register_section

class MediaSection(Section):
	name = "Media"
	interfaces = [
		"android.hardware.media",
		"android.hardware.media.bufferpool",
		"android.hardware.media.c2",
		"android.hardware.media.omx",
		"vendor.qti.media.c2",
	]
	patterns = [
		"lib(64)?/libOmx.*\.so",
	]

register_section(MediaSection)
