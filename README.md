# aospdtgen

[![PyPI version](https://img.shields.io/pypi/v/aospdtgen)](https://pypi.org/project/aospdtgen/)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/0ec14174bf9840458f27062444b1e375)](https://app.codacy.com/gh/sebaubuntu-python/aospdtgen/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)

Create a [LineageOS](https://github.com/LineageOS)-compatible device tree from an Android stock ROM dump (made with [dumpyara](https://github.com/SebaUbuntu/dumpyara)).
This script supports any Android firmware from a Treble-enabled device (Higher than Android 8.0 and with VNDK enabled, you can check it with [Treble Info](https://play.google.com/store/apps/details?id=tk.hack5.treblecheck) or with `adb shell getprop ro.treble.enabled`).
For pre-Treble devices please use [twrpdtgen](https://github.com/twrpdtgen/twrpdtgen).

Requires Python 3.9 or greater

## Installation

```sh
pip install aospdtgen
```

## Instructions

```
$ python3 -m aospdtgen -h
Android device tree generator
Version 0.1.0

usage: python3 -m aospdtgen [-h] [-o OUTPUT] dump_path

positional arguments:
  dump_path             path to an Android dump made with dumpyara

optional arguments:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        custom output folder
```

## License

```
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
```
