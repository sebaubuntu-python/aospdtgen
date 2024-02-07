#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class StorageFirmwareSection(Section):
    name = "Storage firmware"
    folders = [
        "firmware/ufs",
	]

register_section(StorageFirmwareSection)
