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
	filenames = [
		"c2_manifest_vendor.xml",
	]
	patterns = [
		"lib(64)?/libOmx.*\.so",
		"lib(64)?/libstagefright.*\.so",
	]

class MediaConfigsSection(Section):
	name = "Media configs"
	patterns = [
		"etc/media_codecs.*\.xml",
		"etc/media_profiles.*\.xml",
	]

register_section(MediaSection)
register_section(MediaConfigsSection)
