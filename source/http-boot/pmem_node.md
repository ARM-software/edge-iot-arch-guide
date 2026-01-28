<!--SPDX-License-Identifier: CC-BY-SA-4.0-->

# About This Document

This document describes a proposal for providing the operating system with access
to the boot image, exposed as a ramdisk via a PMEM node on Device Tree based
platforms.

In this document, the term *firmware* is used generically to refer to platform
firmware components involved in the boot process, including the BL33 loader
(e.g., U-Boot), where applicable.

## Overview

When the kernel is booted from a Linux live image or an installer image
(where installation requires access to local packages),
the boot image must remain accessible after the kernel calls ExitBootServices.

With EFI HTTP boot, the firmware downloads a live or installer ISO image
and places it at a location in system memory.
Information about this image must be passed to the operating system kernel.

On ACPI-based systems, the NFIT (NVDIMM Firmware Interface Table) is used to
describe Persistent Memory (PMEM) regions, allowing the OS to expose the image
as a ramdisk.

On Device Tree (DT) platforms, PMEM devices can be described using
[Device Tree PMEM binding](https://www.kernel.org/doc/Documentation/devicetree/bindings/pmem/pmem-region.yaml),
enabling similar functionality without ACPI.

On DT–based systems, firmware describes the persistent memory
region using the standard PMEM DT binding. The kernel discovers this
region during early boot and registers it via the LIBNVDIMM subsystem,
which then exposes it as a pmem block device (e.g. /dev/pmem0)
allowing a filesystem to be mounted on it.

The kernel must include drivers required for PMEM devices support.

## Firmware responsibilities

The firmware is responsible for inserting a PMEM Device Tree node that describes
the persistent memory region containing the downloaded image, allowing the
operating system to discover and access it during boot.

### PMEM Representation in Device Tree

According to the PMEM Device Tree bindings, the memory region should:

- be described as volatile memory
- include the `"pmem-region"` compatible string
- use start and end addresses that satisfy the alignment requirements imposed
  by the kernel configuration (page size or 2 MiB)

The following example illustrates a PMEM region inserted into Device Tree by firmware.
```dts
/* Example PMEM Device Tree node */
pmem@40200000 {
        reg = <0x00 0x40200000 0x00 0x24600000>;
        volatile;
        compatible = "pmem-region";
};
```

### PMEM Memory Region and EFI memory map

It is recommended that firmware excludes the PMEM memory region from the EFI memory
map handed over to the OS. If the region is instead included in the EFI memory map
and only marked as reserved in Device Tree, then depending on the OS kernel version
and configuration the PMEM driver may fail to reserve the region for a namespace
and instantiate a `/dev/pmemX` device.

#### Details for Linux 5.x and 6.10 kernel versions

If the `CONFIG_ZONE_DEVICE` and `CONFIG_SPARSEMEM` kernel options are enabled, the PMEM driver
invokes `devm_memremap_pages()` instead of `devm_memremap()`. While
`devm_memremap()` works correctly whether the memory region is omitted from the
EFI memory map or marked as reserved, `devm_memremap_pages()` only succeeds when
the region is omitted.

The following kernel messages illustrate the failure observed when the PMEM
driver is unable to reserve the memory region:
```
[  111.743083] [  T517] nd_pmem namespace0.0: could not reserve region [mem 0x48000000-0x67ffffff]
[  111.743211] [  T517] nd_pmem namespace0.0: probe with driver nd_pmem failed with error -16
```

A kernel fix addressing this issue has been proposed and is under review:
[Don't call __add_pages() for reserved memory](https://gitlab.com/ilias.apalodimas/net-next/-/commit/0e1b2d01511e59008ef21c3c84cd347780cd0a51)

## OS responsibilities

With a correct PMEM Device Tree node definition and all required drivers included
in the Linux kernel, the OS instantiates a `/dev/pmemX` device. As needed,
partitions contained within the PMEM region can then be mounted by the installer
or live environment. Support depends on kernel configuration and the contents of
the installer or live image.

### Linux Kernel Support Requirements

The following kernel configuration options are required to support PMEM regions
described via Device Tree:
```
CONFIG_ARM64_PMEM
CONFIG_LIBNVDIMM
CONFIG_BLK_DEV_PMEM
CONFIG_OF_PMEM
```

Additional options such as `CONFIG_ARCH_HAS_PMEM_API` are selected implicitly by
the architecture, and transport-specific drivers (e.g. `CONFIG_VIRTIO_PMEM`)
are not required for Device Tree–described PMEM regions.

### Linux distros support

Most modern Linux distributions already include the required drivers in their
live or net-installer images, including:

- Ubuntu (22.04 and later)
- RHEL (9.4 and later)
- Debian (12.10.0 and later)
- Fedora and Fedora IoT (42 and later)
- Rocky Linux (9.4 and later)
- openSUSE Tumbleweed
- Yocto (genericarm64 machine, Walnascar 5.2 and later)

## References & Links

- [PMEM support is in U-Boot since v2025.07](https://lore.kernel.org/u-boot/20250317083402.412310-1-sughosh.ganu@linaro.org/)
- [Device Tree PMEM binding](https://www.kernel.org/doc/Documentation/devicetree/bindings/pmem/pmem-region.yaml)
- [LIBNVDIMM subsystem (kernel documentation)](https://docs.kernel.org/driver-api/nvdimm/nvdimm.html)
- [Linux kernel PMEM NVDIMM documentation](https://nvdimm.docs.kernel.org/)
- [Don't call __add_pages() for reserved memory](https://gitlab.com/ilias.apalodimas/net-next/-/commit/0e1b2d01511e59008ef21c3c84cd347780cd0a51)
