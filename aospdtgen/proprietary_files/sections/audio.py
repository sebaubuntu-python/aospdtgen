from aospdtgen.proprietary_files.section import Section, register_section

class AudioSection(Section):
	name = "Audio"
	interfaces = [
		"android.hardware.audio",
		"android.hardware.audio.effect",
		"vendor.qti.hardware.audiohalext",
	]
	hardware_modules = [
		"audio.primary",
		"audio.r_submix",
		"audio.usb",
	]

class AudioFxModulesSection(Section):
	name = "Audio (FX modules)"
	folders = [
		"lib/soundfx",
		"lib64/soundfx",
	]

class AudioConfigsSection(Section):
	name = "Audio configs"
	patterns = [
		"etc/audio_configs.*\.xml",
		"etc/audio_effects.*\.(conf|xml)",
		"etc/audio_io_policy\.conf",
		"etc/.*audio_policy.*\.xml",
		"etc/audio_tuning_mixer\.txt",
	]

register_section(AudioSection)
register_section(AudioFxModulesSection)
register_section(AudioConfigsSection)
