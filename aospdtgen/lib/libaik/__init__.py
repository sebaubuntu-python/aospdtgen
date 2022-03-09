from aospdtgen.lib.liblogging import LOGD, LOGI
from git import Repo
from pathlib import Path
from platform import system
from shutil import which
from subprocess import check_output, STDOUT, CalledProcessError
from tempfile import TemporaryDirectory
import re

AIK_REPO = "https://github.com/SebaUbuntu/AIK-Linux-mirror"

ALLOWED_OS = [
	"Linux",
	"Darwin",
]

class AIKImageInfo:
	def __init__(self,
	             base_address: str,
	             board_name: str,
	             cmdline: str,
	             dt: Path,
	             dtb: Path,
	             dtb_offset: str,
	             dtbo: Path,
	             header_version: str,
	             image_type: str,
	             kernel: Path,
	             kernel_offset: str,
	             origsize: str,
	             os_version: str,
	             pagesize: str,
	             ramdisk: Path,
	             ramdisk_compression: str,
	             ramdisk_offset: str,
	             tags_offset: str,
	            ):
		self.kernel = kernel
		self.dt = dt
		self.dtb = dtb
		self.dtbo = dtbo
		self.ramdisk = ramdisk
		self.base_address = base_address
		self.board_name = board_name
		self.cmdline = cmdline
		self.dtb_offset = dtb_offset
		self.header_version = header_version
		self.image_type = image_type
		self.kernel_offset = kernel_offset
		self.origsize = origsize
		self.os_version = os_version
		self.pagesize = pagesize
		self.ramdisk_compression = ramdisk_compression
		self.ramdisk_offset = ramdisk_offset
		self.tags_offset = tags_offset

	def __str__(self):
		return (
			f"base address: {self.base_address}\n"
			f"board name: {self.board_name}\n"
			f"cmdline: {self.cmdline}\n"
			f"dtb offset: {self.dtb_offset}\n"
			f"header version: {self.header_version}\n"
			f"image type: {self.image_type}\n"
			f"kernel offset: {self.kernel_offset}\n"
			f"original size: {self.origsize}\n"
			f"os version: {self.os_version}\n"
			f"page size: {self.pagesize}\n"
			f"ramdisk compression: {self.ramdisk_compression}\n"
			f"ramdisk offset: {self.ramdisk_offset}\n"
			f"tags offset: {self.tags_offset}\n"
		)

class AIKManager:
	"""
	This class is responsible for dealing with AIK tasks
	such as cloning, updating, and extracting recovery images.
	"""

	def __init__(self):
		"""Initialize AIKManager class."""
		if system() not in ALLOWED_OS:
			raise NotImplementedError(f"{system()} is not supported")

		# Check whether cpio package is installed
		if which("cpio") is None:
			raise RuntimeError("cpio package is not installed")

		self.tempdir = TemporaryDirectory()
		self.path = Path(self.tempdir.name)

		self.images_path = self.path / "split_img"
		self.ramdisk_path = self.path / "ramdisk"

		LOGI("Cloning AIK...")
		Repo.clone_from(AIK_REPO, self.path)

	def unpackimg(self, image: Path):
		"""Extract recovery image."""
		image_prefix = image.name

		try:
			process = self._execute_script("unpackimg.sh", image)
		except CalledProcessError as e:
			returncode = e.returncode
			output = e.output
		else:
			returncode = 0
			output = process

		if returncode != 0:
			LOGD(output)
			raise RuntimeError(f"AIK extraction failed, return code {returncode}")

		return self.get_current_extracted_info(image_prefix)

	def repackimg(self):
		return self._execute_script("repack.sh")

	def cleanup(self):
		return self._execute_script("cleanup.sh")

	def get_current_extracted_info(self, prefix: str):
		cmdline = None
		for name in ["cmdline", "vendor_cmdline"]:
			_cmdline = self._read_recovery_file(prefix, name)
			if _cmdline:
				cmdline = re.sub("buildvariant=(user|userdebug|eng)", '', _cmdline).strip()

		dt = self._get_extracted_info(prefix, "dt")
		dt = dt if dt.is_file() else None

		dtb = self._get_extracted_info(prefix, "dtb")
		dtb = dtb if dtb.is_file() else None

		dtbo = None
		for name in ["dtbo", "recovery_dtbo"]:
			_dtbo = self._get_extracted_info(prefix, name)
			if _dtbo.is_file():
				dtbo = _dtbo

		kernel = self._get_extracted_info(prefix, "kernel")
		kernel = kernel if kernel.is_file() else None

		ramdisk = self.ramdisk_path if self.ramdisk_path.is_dir() else None

		ramdisk_compression = None
		for name in ["ramdiskcomp", "vendor_ramdiskcomp"]:
			_ramdisk_compression = self._read_recovery_file(prefix, name)
			if ramdisk_compression:
				ramdisk_compression = _ramdisk_compression

		return AIKImageInfo(
			base_address=self._read_recovery_file(prefix, "base"),
			board_name=self._read_recovery_file(prefix, "board"),
			cmdline=cmdline,
			dt=dt,
			dtb=dtb,
			dtb_offset=self._read_recovery_file(prefix, "dtb_offset"),
			dtbo=dtbo,
			header_version=self._read_recovery_file(prefix, "header_version", default="0"),
			image_type=self._read_recovery_file(prefix, "imgtype"),
			kernel=kernel,
			kernel_offset=self._read_recovery_file(prefix, "kernel_offset"),
			origsize=self._read_recovery_file(prefix, "origsize"),
			os_version=self._read_recovery_file(prefix, "os_version"),
			pagesize=self._read_recovery_file(prefix, "pagesize"),
			ramdisk=ramdisk,
			ramdisk_compression=ramdisk_compression,
			ramdisk_offset=self._read_recovery_file(prefix, "ramdisk_offset"),
			tags_offset=self._read_recovery_file(prefix, "tags_offset"),
		)

	def _read_recovery_file(self, prefix: str, fragment: str, default: str = None) -> str:
		file = self._get_extracted_info(prefix, fragment)
		return file.read_text().splitlines()[0].strip() if file.exists() else default

	def _get_extracted_info(self, prefix: str, fragment: str) -> Path:
		return self.images_path / f"{prefix}-{fragment}"

	def _execute_script(self, script: str, *args):
		command = [self.path / script, "--nosudo", *args]
		return check_output(command, stderr=STDOUT, universal_newlines=True)
