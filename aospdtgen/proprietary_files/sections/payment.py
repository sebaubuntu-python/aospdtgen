#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class PaymentEIDSection(Section):
	name = "Payment (eID)"
	interfaces = [
		"vendor.qti.hardware.eid",
	]

class PaymentIFAASection(Section):
	name = "Payment (IFAA)"
	interfaces = [
		"vendor.qti.hardware.ifaa",
	]
	apps = [
		"IFAAService",
	]

class PaymentOplusSection(Section):
	name = "Payment (oplus)"
	interfaces = [
		"vendor.oplus.hardware.biometrics.fingerprintpay",
		"vendor.oplus.hardware.fido.fido2ca",
		"vendor.oplus.hardware.fido.fidoca",
	]

class PaymentXiaomiSection(Section):
	name = "Payment (Xiaomi)"
	interfaces = [
		"vendor.fido.fidoca",
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


class PaymentFirmwareSection(Section):
	name = "Payment firmware"
	patterns = [
		"(.*/)?firmware/alipay\..*",
		"(.*/)?firmware/fidoctap\..*",
		"(.*/)?firmware/fidotap\..*",
	]

register_section(PaymentEIDSection)
register_section(PaymentIFAASection)
register_section(PaymentOplusSection)
register_section(PaymentXiaomiSection)
register_section(PaymentFirmwareSection)
