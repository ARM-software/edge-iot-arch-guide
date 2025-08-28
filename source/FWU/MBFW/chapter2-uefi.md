<!--SPDX-License-Identifier:** CC-BY-SA-4.0-->

# UEFI spec

## UEFI Version

This document uses version 2.9 of the UEFI specification [UEFI]_.

## UEFI Compliance

All [UEFI]_ features required by [EBBR]_ are assumed.

## UEFI Extra Dependencies

The capsules installed using the procedure defined in this document must be formatted according to the FMP defined format [UEFI]_ § 23.1 - Firmware Management Protocol.
The FMP instance must provide the `GetImageInfo` and `SetImage` functions to be used as the UpdateCapsule backend.

There are two ways of accepting a new update or reverting an existing one.
- If SetVariable at RunTime is supported `ABAction_<FMP GUID>` UEFI variable is used.
- If SetVariable at Runtime is not supported an empty capsule with a specific GUID is used.

### Acceptance and Revert requests in firmware

When UEFI receives an acceptance or downgrade request it must:

1. Call the FWU primitive `fwu_set_active` [FWU]_ if the flash store is owned by the Secure World.
2. Set the `active_index` field in the FWU Metadata [FWU]_ if the flash store is owned by the Normal World.
3. Restore EFI variables to their previous state, if changed during the firmware upgrade.

### Explicit Capsule Acceptance

The firmware can skip the steps described in [OS Requested FW Acceptance](#os-requested-fw-acceptance) and immediately accept a new firmware.
In order to do so, the OS must set the `EFI_CAPSULE_HEADER.Flags[15]` to `1` during the capsule creation.
Other images may be implicitly accepted by the UEFI implementation.

### Exchanging information for AB updates between the OS and the Firmware

The firmware and an Operating System may exchange information through the `ABAction_FMP GUID>` and the
`ABStatus_<FMP GUID>` variables as follows:

- The `ABAction_<FMP GUID>` variable is owned by the OS and is used to indicate which actions the OS
wants the firmware to take. The OS will supply this data with a SetVariable() call.
-  The `ABStatus_<FMP GUID>` variable is owned by the firmware and indicates the status of the
   update.This variable is recreated by the firmware and cannot be modified by the OS.

**Note**: It is encouraged to make `ABAction_<FMP GUID>` an authenticated variable. However if the firmware doesn't support authenticated
variables it can be a normal one.

#### ABAction_<FMP GUID>

**GUID** : 4a8dd2d2-8acf-11ef-b864-0242ac120002
```
FW_AB_REVERT 0x00000001
FW_AB_ACCEPT 0x00000002
```

`FW_AB_REVERT` : Revert the running firmware.
`FW_AB_ACCEPT` : Accept the updated firmware.

#### ABStatus_<FMP GUID>
**GUID**: 4a8dd2d2-8acf-11ef-b864-0242ac120002
TODO: copy paste the ESRTv2 doc once we finalize it

### ESRT

[UEFI]_ defines the System Resource Table (ESRT) § 23.4 - EFI System Resource Table.

Each entry in the ESRT describes a device or system firmware resource that can be targeted by a firmware capsule update.
Each entry in the ESRT is also used to report the status of the last attempted update.

The UEFI specification defines a mapping between the ESRT fields and the `EFI_FIRMWARE_IMAGE_DESCRIPTOR` provided by `FMP.GetImageInfo()`.

- The resource entry field `FwClass` must be set to "ESRT_FW_TYPE_SYSTEMFIRMWARE."
- The fields `LowestSupportedVersion` and `FwVersion` are provided by:
  - The Secure World FWU when the Secure World is responsible for the update.
  - Non-secure firmware if the Non-Secure World is responsible for the update.

`LastAttemptStatus` is expected to be maintained by the UEFI implementation, relying partially on information provided by early platform boot stages [FWU]_.

The acceptance status of each FW image is provisionally displayed in the `LastAttemptedStatus` field [[1]](#provisional) in the ESRT image entry.
A value of `0x3fff` implies that the image has not been accepted. The OS must explicitly accept the image by installing an acceptance capsule or set ABindications as described in `OS directed FW image acceptance`_.

[provisional]: https://gitlab.com/Linaro/trustedsubstrate/mbfw/-/blob/master/source/chapter2-uefi.rst?ref_type=heads&plain=0#id7
>[[1]](#provisional) Presenting the image acceptance status in the LastAttemptedStatus field is a provisional arrangement. A more permanet solution is under discussion.

### OS Requested FW Revert

The OS can request a firmware downgrade. This is done by either using a dedicated empty capsule or setting an EFI variable depending
on what the firmware supports.

#### SetVariable at Runtime not supported

If the firmware does not support setting EFI variables at runtime and wants to revert the
FW images to a previously working bank, it can do so by installing the following capsule:

- `CapsuleGuid` = `acd58b4b-c0e8-475f-99b5-6b3f7e07aaf0`
- `HeaderSize` = `sizeof(EFI_CAPSULE_HEADER)`
- `Flags` = `0`
- `CapsuleImageSize` = `sizeof(EFI_CAPSULE_HEADER)`

#### SetVariable at Runtime supported

If the firmware does support setting EFI variables at runtime and wants to revert the
FW images to a previously working bank, it can do so by setting the bit 0 in ABAction_<FMP GUID>

- ABAction_<FMP GUID> = 0x1

On the next reboot the firmware must switch the `active_index` to a previously working bank
and clear the ABAction_<FMP GUID> bit.

### OS Requested FW Acceptance

The OS must accept the new images. This is done by either using a dedicated empty capsule or setting an EFI variable depending
on what the firmware supports.

#### SetVariable at Runtime not supported

The OS accepts each image with pending acceptance using a capsule composed of an `EFI_CAPSULE_HEADER` concatenated with the image type UUID.
**Note:** Performing a capsule update while in the trial state is prohibited.

- `CapsuleGuid` = `0c996046-bcc0-4d04-85ec-e1fcedf1c6f8`
- `HeaderSize` = `sizeof(EFI_CAPSULE_HEADER)`
- `Flags` = `0`
- `CapsuleImageSize` = `sizeof(EFI_CAPSULE_HEADER) + sizeof(UUID)`

#### SetVariable at Runtime supported

If the firmware does support setting EFI variables at runtime and wants to accept the
FW images, it can do so by setting the bit 1 in ABAction_<FMP GUID>

- ABAction_<FMP GUID> = 0x2

**Note**: On the next reboot the firmware must switch the active_index to the active working bank
and clear the ABAction_<FMP GUID> bit

### Update Permission Verification

The FW management guidelines in [NIST_800_193]_ specify:

1. Verification of FW image authenticity.
2. Authorization of the FW update procedure.

- FW image authenticity is implemented by authenticating FW images.
- FW update authorization ensures that the capsule or components were assembled by the platform owner.

### FW Update Authorization

FW update authorization [NIST_800_193]_ may be checked by the OS before calling `UpdateCapsule`.
Alternatively, it can rely on FW image authenticity checks. If all images in the capsule are authentic, the user is authorized to proceed.

### FW Image Authentication

Each FW image should be signed by the FW vendor. The FW vendor signature should be placed before the image as described in the UEFI FMP definition (§ 23.1 [UEFI]_).
FW images must be authenticated before being written to the store or executed.

### Maximum Trial Platform Boots

The UEFI implementation must count consecutive platform boots in the Trial state [FWU]_. If the number exceeds `max_trial_boots`, the UEFI implementation must revert to the previous working bank [FWU]_.

**Note:** Similar functionality must be implemented in the first-stage bootloader. This is platform-specific but must count reboots and revert to a previous working version if the threshold is exceeded.
