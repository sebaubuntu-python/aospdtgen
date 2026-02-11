#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section


class WeaverSection(Section):
    name = "Weaver"
    interfaces = [
        "android.hardware.weaver",
    ]


register_section(WeaverSection)
