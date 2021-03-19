#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from logging import basicConfig, INFO

def setup_logging(level = INFO):
	basicConfig(format='[%(asctime)s] [%(filename)s:%(lineno)s %(levelname)s] %(funcName)s: %(message)s',
	            level=level)
