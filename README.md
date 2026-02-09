# aospdtgen

[![PyPI version](https://img.shields.io/pypi/v/aospdtgen)](https://pypi.org/project/aospdtgen/)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/0ec14174bf9840458f27062444b1e375)](https://www.codacy.com/gh/sebaubuntu-python/aospdtgen/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sebaubuntu-python/aospdtgen&amp;utm_campaign=Badge_Grade)


Since the release of LineageOS 23.0, extract_utils.sh is no longer provided, meaning everyone should switch to extract.py. However, aospdtgen still generates extract_utils.sh, making it unusable on LineageOS 23.0. SebaUbuntu seems unconcerned about this issue. Therefore, I tried using Claude 4.5 Opus to create a fork using Vibe-Coding to ensure that aospdtgen could generate extract.py. (It doesn't generate extract_utils.sh! If you want to use this, please use the official SebaUbuntu aospdtgen.)

Create a [LineageOS 23.0](https://github.com/LineageOS)-compatible device tree from an Android stock ROM dump (made with [dumpyara](https://github.com/SebaUbuntu/dumpyara)).
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
