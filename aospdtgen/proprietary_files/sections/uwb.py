#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section


class UwbSection(Section):
    name = "UWB"
    interfaces = [
        "android.hardware.uwb",
        "android.hardware.uwb.fira_android",
    ]


register_section(UwbSection)
