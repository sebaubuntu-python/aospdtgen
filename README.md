# aospdtgen

Create a [LineageOS](https://github.com/LineageOS)-compatible device tree from an Android stock ROM dump (made with [dumpyara](https://github.com/nickel-labs/nickel_tools_dumpyara)).

This fork adds support for LineageOS 23.0's new Python-based `extract-utils` system while maintaining backward compatibility with the legacy shell-based `extract_utils.sh` for LineageOS 22.x and earlier.

## Features

- Generates a complete device tree from an Android firmware dump
- Supports both **Python** (LineageOS >= 23.0) and **Shell** (LineageOS <= 22.x) extract scripts
- Override device codename via command-line argument
- Supports any Treble-enabled device (Android 8.0+ with VNDK enabled)

> For pre-Treble devices, please use [twrpdtgen](https://github.com/twrpdtgen/twrpdtgen).

## Requirements

- Python 3.9 or greater
- An Android firmware dump created by [dumpyara](https://github.com/nickel-labs/nickel_tools_dumpyara)

## Installation

```sh
pip3 install git+https://github.com/DestoryG/aospdtgen.git
```

## Usage

```
$ python3 -m aospdtgen -h
Android device tree generator

usage: python3 -m aospdtgen [-h] [-o OUTPUT] [-c CODENAME] [--python | --shell] dump_path

positional arguments:
  dump_path                     path to an Android dump made with dumpyara

options:
  -h, --help                    show this help message and exit
  -o OUTPUT, --output OUTPUT    custom output folder
  -c CODENAME, --codename CODENAME
                                override the device codename
  --python                      generate Python-based extract scripts (LineageOS >= 23.0, default)
  --shell                       generate shell-based extract scripts (LineageOS <= 22.x)
```

### Examples

Generate a device tree for LineageOS 23.0 (Python mode, default):
```sh
python3 -m aospdtgen ~/dump -o ~/android/device/oplus/re5c33 -c re5c33
```

Generate a device tree for LineageOS 22.x or earlier (Shell mode):
```sh
python3 -m aospdtgen ~/dump -o ~/android/device/oplus/re5c33 -c re5c33 --shell
```

## Changes from upstream

- Added `--python` / `--shell` flags to select extract script type
- Added `-c` / `--codename` flag to override auto-detected device codename
- Added Python-based `extract-files.py` and `setup-makefiles.py` templates for LineageOS 23.0+
- Removed `BOARD_API_LEVEL` from `device.mk` template (not allowed in Android 16+)
- Fixed `BuildFingerprint` syntax in `lineage_device.mk` template

## License

```
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
```
