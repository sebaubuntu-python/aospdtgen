#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from functools import cmp_to_key
from locale import strcoll

class Hal:
	"""Class representing a HAL."""
	def __init__(self, name) -> None:
		"""Initialize an object."""
		self.name = name

def strcoll_cast_to_str(obj1: object, obj2: object) -> int:
	obj1 = str(obj1)
	obj2 = str(obj2)

	return strcoll(obj1, obj2)

cast_to_str_key = cmp_to_key(strcoll_cast_to_str)
