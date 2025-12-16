<!--SPDX-License-Identifier:** CC-BY-SA-4.0-->

# UEFI spec

## UEFI Version

This document uses version 2.11 of the UEFI specification [UEFI]_.

## UEFI Compliance

All [UEFI]_ features required by [EBBR]_ are assumed.

## UEFI Extra Dependencies

The capsules installed using the procedure defined in this document must be formatted according to the FMP defined format [UEFI]_ § 23.1 - Firmware Management Protocol.  
The FMP instance must provide the `GetImageInfo` and `SetImage` functions to be used as the UpdateCapsule backend.

There are two ways of accepting a new update or reverting an existing one.
- If SetVariable at RunTime is supported `ABAction` UEFI variable is used.
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

The firmware and an Operating System may exchange information through the `ABAction` and `ABStatus`
UEFI variable as follows:

- The `ABStatus` variable returns a 64-bit unsigned integer owned by the firmware and indicates the
status of the update. This variable is set by firmware, and cannot be modified by the OS.

- The `ABAction` variable is a 64-bit unsigned integer representing a bitmask.

**Note**: It is encouraged to make `ABAction` and authenticated variable. However if the firmware doesn't support authenticated
variables it can be a normal one.

#### ABAction

**GUID** : 4a8dd2d2-8acf-11ef-b864-0242ac120002
```
FW_AB_NO_ACTION 0x00000000
FW_AB_REVERT   0x00000001
FW_AB_ACCEPT   0x00000002
```

`FW_AB_NO_ACTION` : Firmware is accepted and running.
`FW_AB_REVERT` : Revert the running firmware, only if `ABStatus` equals to FW_AB_TRIAL or FW_AB_ACCEPTED.
`FW_AB_ACCEPT` : Accept the updated firmware, only if `ABStatus` equals FW_AB_TRIAL.

#### ABStatus
**GUID**: 4a8dd2d2-8acf-11ef-b864-0242ac120002
```
FW_AB_ACCEPTED                            0x00000000
FW_AB_REJECTED                            0x00000001
FW_AB_TRIAL                               0x00000002
FW_AB_IN_PROGRESS                         0x00000003
FW_AB_SUCCESS                             0x00010000
FW_AB_ERROR_UNSUCCESSFUL                  0x00010001
FW_AB_ERROR_INSUFFICIENT_RESOURCES        0x00010002
FW_AB_ERROR_INCORRECT_VERSION             0x00010003
FW_AB_ERROR_INVALID_FORMAT                0x00010004
FW_AB_ERROR_AUTH_ERROR                    0x00010005
FW_AB_ERROR_PWR_EVT_AC                    0x00010006
FW_AB_ERROR_PWR_EVT_BATT                  0x00010007
FW_AB_ERROR_UNSATISFIED_DEPENDENCIES      0x00010008
FW_AB_ERROR_UNSUCCESSFUL_VENDOR_RANGE_MIN 0x00011000
FW_AB_ERROR_UNSUCCESSFUL_VENDOR_RANGE_MAX 0x00014000
```

`FW_AB_ACCEPTED`: The firmware is up to date and runs an accepted version.
`FW_AB_TRIAL`: The running firmware is a trial one and needs acceptance.
`FW_AB_IN_PROGRESS`: The firmware update is in progress.

### ESRT

[UEFI]_ defines the System Resource Table (ESRT) § 23.4 - EFI System Resource Table.

Each entry in the ESRT describes a device or system firmware resource that can be targeted by a firmware capsule update.  
Each entry in the ESRT is also used to report the status of the last attempted update.

The UEFI specification defines a mapping between the ESRT fields and the `EFI_FIRMWARE_IMAGE_DESCRIPTOR` provided by `FMP.GetImageInfo()`.

- The resource entry field `FwClass` must be set to "ESRT_FW_TYPE_SYSTEMFIRMWARE."
- The fields `LowestSupportedVersion` and `FwVersion` are provided by:
  - The Secure World FWU when the Secure World is responsible for the update.
  - Non-secure firmware if the Non-Secure World is responsible for the update.

[provisional]: https://github.com/ARM-software/edge-iot-arch-guide/blob/main/source/FWU/MBFW/chapter2-uefi.md
>[[1]](#provisional) Presenting the image acceptance status in the LastAttemptedStatus field is a provisional arrangement. A more permanet solution is under discussion.

### OS Requested FW Revert

The OS can request a firmware downgrade. This is done by either using a dedicated empty capsule
or setting the `ABAction` UEFI variable depending on what the firmware supports.

#### SetVariable at Runtime not supported

If the firmware does not support setting EFI variables at runtime and wants to revert the
FW images to a previously working bank, it can do so by installing the following capsule:

- `CapsuleGuid` = `acd58b4b-c0e8-475f-99b5-6b3f7e07aaf0`
- `HeaderSize` = `sizeof(EFI_CAPSULE_HEADER)`
- `Flags` = `0`
- `CapsuleImageSize` = `sizeof(EFI_CAPSULE_HEADER)`

#### SetVariable at Runtime supported

If the firmware does support setting EFI variables at runtime and wants to revert the
FW images to a previously working bank, it can do so by setting the FW_AB_REVERT bit in `ABAction`

- ABAction |= FW_AB_REVERT

On the next reboot the firmware must switch the `active_index` to a previously working bank
and clear the `ABAction` bit.

After an upgrade the firmware sets `ABStatus` to FW_AB_TRIAL.
If the OS wants to revert it sets `ABAction` to FW_AB_REVERT. The firmware
must set `ABStatus` to FW_AB_REJECTED until the next reboot.
On the next reboot the firmware clears the `ABAction` variable.

### OS Requested FW Acceptance

The OS must accept the new images. This is done by either using a dedicated empty capsule or setting the `ABAction` UEFI variable depending
on what the firmware supports. If the OS does not accept the images and the capsules where not created with 

#### SetVariable at Runtime not supported

The OS accepts each image with pending acceptance using a capsule composed of an `EFI_CAPSULE_HEADER` concatenated with the image type UUID.  
**Note:** Performing a capsule update while in the trial state is prohibited.

- `CapsuleGuid` = `0c996046-bcc0-4d04-85ec-e1fcedf1c6f8`
- `HeaderSize` = `sizeof(EFI_CAPSULE_HEADER)`
- `Flags` = `0`
- `CapsuleImageSize` = `sizeof(EFI_CAPSULE_HEADER) + sizeof(UUID)`

#### SetVariable at Runtime supported

If the firmware does support setting EFI variables at runtime and wants to accept the
FW images, it can do so by setting the FW_AB_ACCEPT bit in `ABAction`

- ABAction |= FW_AB_ACCEPT
 
**Note**: If the update agent does not have access to the metadata at runtime, on the next reboot the it
must switch the active_index to the active working bank and set `ABAction` to FW_AB_NO_ACTION.

**Note**: If the update agent can access metadata at runtime, it must update the active_index field
in the FWU Metadata or call fwu_set_active() and set `ABStatus` to FW_AB_ACCEPTED and
`ABAction` to FW_AB_NO_ACTION.

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
