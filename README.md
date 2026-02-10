# aospdtgen

Create a [LineageOS][lineageos]-compatible device tree
from an Android stock ROM dump
(made with [dumpyara][dumpyara]).

This fork adds support for LineageOS 23.0's new
Python-based `extract-utils` system while maintaining
backward compatibility with the legacy shell-based
`extract_utils.sh` for LineageOS 22.x and earlier.

## Features

- Generates a complete device tree from a firmware dump
- Supports both **Python** (LineageOS >= 23.0)
  and **Shell** (LineageOS <= 22.x) extract scripts
- Override device codename via command-line argument
- Supports any Treble-enabled device (Android 8.0+)

> For pre-Treble devices, please use
> [twrpdtgen](https://github.com/twrpdtgen/twrpdtgen).

## Requirements

- Python 3.9 or greater
- An Android firmware dump created by [dumpyara][dumpyara]

## Installation

```sh
pip3 install git+https://github.com/DestoryG/aospdtgen.git
```

## Usage

```text
$ python3 -m aospdtgen -h
Android device tree generator

usage: python3 -m aospdtgen [-h] [-o OUTPUT]
       [-c CODENAME] [--python | --shell] dump_path

positional arguments:
  dump_path             path to a dumpyara dump

options:
  -h, --help            show this help message
  -o OUTPUT, --output OUTPUT
                        custom output folder
  -c CODENAME, --codename CODENAME
                        override the device codename
  --python              Python extract scripts
                        (LineageOS >= 23.0, default)
  --shell               shell extract scripts
                        (LineageOS <= 22.x)
```

### Examples

Generate a device tree for LineageOS 23.0
(Python mode, default):

```sh
python3 -m aospdtgen ~/dump -o ~/output -c re5c33
```

Generate a device tree for LineageOS 22.x or earlier
(Shell mode):

```sh
python3 -m aospdtgen ~/dump -o ~/output --shell
```

## Changes from upstream

- Added `--python` / `--shell` flags
- Added `-c` / `--codename` flag
- Added Python-based `extract-files.py` and
  `setup-makefiles.py` templates for LineageOS 23.0+
- Removed `BOARD_API_LEVEL` from `device.mk`
  template (not allowed in Android 16+)
- Fixed `BuildFingerprint` syntax
  in `lineage_device.mk` template

## License

```text
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
```

[lineageos]: https://github.com/LineageOS
[dumpyara]: https://github.com/nickel-labs/nickel_tools_dumpyara
