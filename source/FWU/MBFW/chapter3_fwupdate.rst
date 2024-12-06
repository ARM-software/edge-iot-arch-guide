.. SPDX-License-Identifier: CC-BY-SA-4.0

**********************************************
Secure Firmware on non-Secure firmware updates
**********************************************

Firmware Flash owned by Secure World
====================================

If the flash device is owned by the Secure World, the FMP managing the FW
images must communicate the FW images to the Firmware Update Implementation
[FWU]_.
The Firmware Update
Implementation in Secure World [FWU]_ writes the FW images to flash.
In this model the OS can install the
capsule by invoking the UEFI UpdateCapsule runtime service. The capsule can
be installed, by the UEFI Implementation, without requiring a system reboot.

The FWU metadata [FWU]_ is managed by the FWU Implementation in the Secure world.
The FWU metadata is described in Section 4.1 of [FWU]_.

When the flash is owned by the Secure World, the FMP communicates with the FWU Implementation
in the secure world using the [FFA]_ Firmware Update ABI [FWU]_

The FWU Implementation provides Non-secure firmware with a list of all FW images handled by it.  The information
is provided via the image directory [#FFANote]_.

.. [#FFANote] image directory is a stream of data structured as an array of image entries [FWU]_.

FMP interface for Secure World updates
---------------------------------------
The FMP is responsible for committing the FW images to flash and to provide the information used to
construct the ESRT table.

Each image entry in the FWU image directory exposes a set of fields which map directly to the
EFI_FIRMWARE_IMAGE_DESCRIPTOR as defined in the following table:

.. table:: EFI_FIRMWARE_IMAGE_DESCRIPTOR Implementation Requirements

   =============================== =============================
   FWU image directory entry field EFI_FIRMWARE_IMAGE_DESCRIPTOR
   =============================== =============================
   img_type_uuid                   ImageTypeId
   lowest_accepted_version         LowestSupportedImageVersion
   last_attempted_version          LastAttemptedVersion
   version                         Version
   image_max_size                  Size
   =============================== =============================

Firmware Flash owned by non-Secure World
========================================

If the flash device is owned by the Normal World, the FW images must be written to it directly by
the UEFI implementation.

Two models exist in this platform model:

- The OS places the capsule on the EFI system partition in the /efi/updatecapsule directory, as
  defined in § 8.5.5 - Delivery of Capsules via file on Mass Storage device [UEFI]_. After this
  the OS requests a platform reset.  The OS may optionally install an update application which
  installs the capsule at the next reboot.

- The OS calls the UEFI UpdateCapsule runtime service. The Capsule must have the
  CAPSULE_FLAGS_PERSIST_ACROSS_RESET bit set in the EFI_CAPSULE_HEADER flags field.
  The implementation must correctly flush all caches prior to performing the warm reset.

The FWU metadata [FWU]_ is managed by the UEFI implementation.
The FWU metadata is described in Section 4.1 of [FWU]_.

Example flows
=============


Capsule install Secure World
----------------------------

.. uml::

  skinparam sequenceMessageAlign center
  participant "TF-A" as TFA #CE5756
  participant FWU #6b8724
  participant UEFI #0093a6
  participant OS #7773cf

  activate OS
  OS -> OS : set ACCEPTANCE_REQUEST on intended capsules
  OS -> UEFI ++: call CapsuleUpdate()
  UEFI -> FWU ++: transfer FW blobs
  FWU -> UEFI --
  UEFI -> OS --
  OS -> UEFI ++: call ResetSystem()
  UEFI -> TFA: PSCI_SYSTEM_RESET

#. OS receives a capsule with the new firmware
#. OS sets the acceptance request bit the Capsule header for all the images it wants to accept
#. OS passes the capsules to the UpdateCapsule runtime service
#. UEFI implementation traverses all the images in the capsule passing them to their corresponding FMPs
#. The FMP transfers the images to the FWU Implementation in the Secure World [FWU]_
#. OS requests a system reboot

Capsule install non-Secure World
--------------------------------

.. uml::

  skinparam sequenceMessageAlign center
  participant "TF-A" as TFA #CE5756
  participant "FWU in EFI" as FWU #6b8724
  participant UEFI #0093a6
  participant OS #7773cf

  activate OS
  OS -> OS : set ACCEPTANCE_REQUEST on intended capsules
  OS -> UEFI: Schedule CapsuleUpdate() on reboot
  OS -> UEFI ++: Call ResetSystem()
  UEFI -> TFA: PSCI_SYSTEM_RESET
  deactivate UEFI
  TFA -> UEFI ++:
  UEFI -> FWU: Perform FW update

  UEFI -> TFA: PSCI_SYSTEM_RESET

#. OS receives a capsule with the new firmware
#. OS sets the acceptance request bit the Capsule header for all the images it wants to accept
#. OS schedules a CapsuleUpdate on disk and reboots
#. UEFI implementation traverses all the images in the capsule passing them to their corresponding FMPs
#. The UEFI firmware performs the update
#. UEFI firmware requests a system reboot

Post-capsule install -- Reboot success
--------------------------------------

.. note:: When the Normal world controls flash, FWU and UEFI are within the same \
   execution context.  In this case, the activations and returns between FWU and \
   UEFI are internal to the UEFI implementation.

.. uml::

  skinparam sequenceMessageAlign center
  participant "TF-A" as TFA #CE5756
  participant FWU #6b8724
  participant UEFI #0093a6
  participant OS #7773cf

  activate TFA
  TFA -> UEFI -- : platform boot
  activate UEFI

  loop over FW images accepted by UEFI
  UEFI -> FWU ++ : image accept
  FWU -> UEFI -- :
  end loop

  UEFI --> OS : ESRT
  UEFI -> OS --: OS boot
  activate OS

  loop over all un-accepted images in ESRT
  OS -> OS : execute image acceptance test if one exists

  OS -> UEFI ++ : Update Capsule hollow image accept
  UEFI -> FWU ++ : image accept
  FWU -> UEFI --
  UEFI -> OS --

  end loop

#. Platform boots with the new FW
#. From the TFA boot report [FWU]_, UEFI verifies that platform booted from the intended bank
#. UEFI accepts a sub-set of the FW images [FWU]_ (the sub-set is platform specific)
#. OS loader obtains the ESRT from UEFI
#. OS boots
#. OS inspects the information in the ESRT
#. OS performs an image acceptance test for any un-accepted image
#. If all image tests pass correctly the OS exits the FW update procedure
#. OS install the image acceptance capsule when all acceptance tests pass
#. Firmware processes the image acceptance capsule and updates the boot bank
#. Rollback counter updates
    * If the Non-secure firmware can update the rollback counter(s) directly, it should do it on the fly
    * Otherwise, on the next reboot Secure firmware must detect the new version
      (rollback counter < fw rollback counter)and update the rollback counter(s) accordingly.

Post-capsule install -- Reboot fails before UEFI
------------------------------------------------

.. note:: When the Normal world controls flash, FWU and UEFI are within the same \
   execution context.  In this case, the activations and returns between FWU and \
   UEFI are internal to the UEFI implementation.

.. uml::

  skinparam sequenceMessageAlign center
  participant "TF-A" as TFA #CE5756
  participant FWU #6b8724
  participant UEFI #0093a6
  participant OS #7773cf

  activate TFA
  TFA ->x UEFI : platform attempt boot
  note over TFA : img auth fails or GWD fire
  note over TFA : TFA selects a known good bank to boot

  TFA -> UEFI -- : platform boot

  activate UEFI

  UEFI -> FWU ++ : change active bank to boot bank
  FWU -> UEFI -- :

  UEFI --> OS : ESRT
  UEFI -> OS --: OS boot
  activate OS

#. Platform boots with the new FW
#. The images fail to authenticate or the generic watchdog fires
#. Platform resets
#. Early platform bootloader detects FW malfunction and selects another bank to boot from
#. UEFI receives the report from TFA of the failed boot attempt
#. UEFI effectivates the permanent bank change
#. UEFI generates the ESRT reflecting the bank that booted the system
#. OS loader obtains the ESRT from UEFI
#. OS boots
#. OS inspects the information in the ESRT

Post-capsule install -- OS fails to boot
----------------------------------------

.. note:: When the Normal world controls flash, FWU and UEFI are within the same \
   execution context.  In this case, the activations and returns between FWU and \
   UEFI are internal to the UEFI implementation.

.. uml::
  skinparam sequenceMessageAlign center
  participant "TF-A" as TFA #CE5756
  participant FWU #6b8724
  participant UEFI #0093a6
  participant OS #7773cf

  activate TFA
  TFA -> UEFI -- : platform boot with trial firmware
  activate UEFI

  UEFI --> OS : ESRT
  UEFI -> OS --: OS boot!

  activate OS
  loop *max_trial_boots* failed boot attempts
  note over OS: OS boot failed!
  end loop

  UEFI -> FWU ++: set previously working bank as active
  FWU -> UEFI -- :
  UEFI --> OS : ESRT
  UEFI -> OS --: OS boot
  activate OS

#. Platform boots with the new FW
#. From the TFA boot report [FWU]_, UEFI verifies that platform booted from the intended bank
#. OS loader obtains the ESRT from UEFI
#. OS boot fails and *max_trial_boots* is reached
#. The FW automatically selects the previously working FW bank and reboots
#. OS Boots

Post-capsule install -- Image fails OS test
-------------------------------------------

.. note:: When the Normal world controls flash, FWU and UEFI are within the same \
   execution context.  In this case, the activations and returns between FWU and \
   UEFI are internal to the UEFI implementation.

.. uml::

  skinparam sequenceMessageAlign center
  participant "TF-A" as TFA #CE5756
  participant FWU #6b8724
  participant UEFI #0093a6
  participant OS #7773cf

  activate TFA
  TFA -> UEFI -- : platform boot
  activate UEFI

  loop over FW images accepted by UEFI
  UEFI -> FWU ++ : image accept
  FWU -> UEFI -- :
  end loop

  UEFI --> OS : ESRT
  UEFI -> OS --: OS boot
  activate OS

  loop over all un-accepted images in ESRT
  OS -> OS : execute image acceptance test if one exists
  end loop

  note over OS: image test fails
  OS -> UEFI ++: install FW revert capsule
  UEFI -> FWU ++: set previously working bank as active
  FWU -> UEFI --
  UEFI -> OS --
  OS -> UEFI ++: call ResetSystem()
  UEFI -> TFA : PSCI_SYSTEM_RESET

#. Platform boots with the new FW
#. From the TFA boot report [FWU]_, UEFI verifies that platform booted from the intended bank
#. UEFI accepts all images [FWU]_
#. OS loader obtains the ESRT from UEFI
#. OS boots
#. OS inspects the information in the ESRT
#. OS performs an image acceptance test for any un-accepted image
#. If any image tests fails, the OS install a "FW downgrade request" capsule, instructing UEFI to select the previously working FW bank, or imediately reboots.
#. OS requests a system reset
