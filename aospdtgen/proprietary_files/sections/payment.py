#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class PaymentXiaomiSection(Section):
	name = "Payment (Xiaomi)"
	interfaces = [
		"vendor.xiaomi.hardware.mfidoca",
		"vendor.xiaomi.hardware.mlipay",
		"vendor.xiaomi.hardware.mtdservice",
		"vendor.xiaomi.hardware.tidaservice",
	]
	patterns = [
		"bin/fidoca(@[0-9]+\.[0-9]+)?$",
		"bin/mlipayd(@[0-9]+\.[0-9]+)?$",
		"bin/mtd(@[0-9]+\.[0-9]+)?$",
		"bin/tidad(@[0-9]+\.[0-9]+)?$",
	]

register_section(PaymentXiaomiSection)
