from aospdtgen.proprietary_files.section import Section, register_section

class UsbSection(Section):
	name = "USB"
	interfaces = [
		"android.hardware.usb",
	]

register_section(UsbSection)
