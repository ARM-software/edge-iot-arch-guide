<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->

# Hardware design options for Secure Storage

## Table of Contents
- [Introduction](#introduction)
- [Hardware options](#hardware-options)
  - [Storage in normal world only](#storage-in-normal-world-only)
  - [Storage in eMMC/RPMB](#storage-in-emmcrpmb)
  - [Storage in external TPM](#storage-in-external-tpm)
  - [Storage in Flash/EEPROM](#storage-in-flasheeprom)
  - [Storage via Secure Element](#storage-via-secure-element)
- [Conclusions](#conclusions)
- [References](#references)

## Introduction  
  
1. [SystemReady][SystemReady] specifies the APIs firmware must expose to an OS in order to support Secure Boot use cases,
with specific requirements in the [BBSR] specification; however, it cannot enforce that the APIs are actually implemented in a secure manner.
2. [PSA][PSA] certification specifies a number of runtime security features that should be supported. It also attempts to verify they have been implemented in a secure manner.
   - At Level 2 and above this involves a full code audit of everything below the security API
   - The API is only specified if you wish to gain the additional [PSA Level2 API](https://arm-software.github.io/psa-api/) certification.
3. This means your hardware choice is wide and not fixed but certain choices will restrict what security level certifications you could achieve

## Hardware options
### Storage in normal world only

In the simplest scenario, as shown in Figure 1, a single storage medium is used, connecting to every firmware and software component. EFI variables reside in a file on that medium, and U-Boot is compiled to access that file.

From a SystemReady perspective, standard interfaces are used, ensuring interoperability between software modules. However, this implementation does not provides security by design, therefore it does not meet BBSR and PSA requirements.

![Storage normal world](images/storage_normal_world_500px.jpg)

_figure 1: Storage in normal world diagram_

### Storage in eMMC/RPMB

In this design option, the storage has two partitions: one hosting the root filesystem (rootfs) and the other hosting the EFI variables. The partition hosting the variables is hidden from the normal world. The downside is that access to this storage is managed through Linux, making an OTP essential to store the keys that lock and unlock access to the RPMB. While this design is more secure than the first option and would meet BBSR and PSA Level 1 requirements due to the presence of secure storage, it would not meet PSA Level 2. This is because the entire software stack involved in accessing the secure storage would be subject to auditing, which is simply too much to audit. Additionally, every firmware or software update would require a new audit, making it impractical to achieve PSA Level 2.

In terms of the PSA API certified, it could apply if fTPM or trusted sources were used.

A tempting alternative to using OTP to store the keys is for TF-A to encrypt the bootloader, assuming the keys are protected. However, this approach introduces a new level of risk, as the key in the bootloader would cover a group of devices rather than having unique keys for each device. This approach may not even comply with PSA Level 1.

![Storage eMMC RPMB](images/storage_emmc_500px.jpg)

_figure 2: Storage in eMMC/RPMB diagram_

### Storage in external TPM

In the scenario described in Figure 3, all secure services, including secure storage, are handled by the TPM. However, since the TPM is not embedded within the SoC, there is a risk that the bus connecting the TPM to the SoC could be snooped. This risk can be mitigated if the bus uses locking mechanisms and encrypted communications, which would require an OTP to store the encryption keys for the bus communication.

Another challenge arises when using a Linux OS. Each application that needs to access the TPM would require an unlocking key, which is impractical.

Despite these challenges, this design could fulfill BBSR requirements and achieve PSA Level 3 because the audit would be limited to the API handling bus communications between the SoC and the TPM—a manageable amount of code to audit. However, this design would not comply with the PSA API, as it relies on an external TPM.

![Storage external TPM](images/storage_tpm_500px.jpg)

_figure 3: Storage in external TPM diagram_


### Storage in Flash/EEPROM
At the next level, a Flash or EEPROM accessible only from the secure world can be managed similarly, with an OTP used to store the keys for locking and encrypting the bus connecting the SoC to the Flash/EEPROM.

In this scenario, BBSR requirements could be fulfilled and PSA Level 2 certification could be achieved, as code auditing would be limited to the trusted world and Flash access. This is practical because the bootloader and trusted firmware are relatively static components that are not frequently updated, meaning changes to the OS would not invalidate PSA certification.

Unlike the previous scenario, the PSA API could be used if trusted services are implemented.

![Storage flash](images/storage_flash_500px.jpg)

_figure 4: Storage in Flash/EEPROM diagram_

### Storage via Secure element

The final design option, shown in Figure 5, involves using an internal secure element within the SoC to provide secure services. Since this uses an internal element, there is no risk of bus snooping, and there is no need to lock or encrypt communications with the secure Flash. While an OTP can still be used to store keys, it is not strictly necessary for protecting the bus connecting to the Flash. However, it can still be useful for decrypting other software components, such as the first-stage bootloaders.

This solution could fulfill BBSR requirements.
In terms of PSA certification, achieving Level 2 is straightforward, and Level 3 is also attainable, as the secure services are well-contained within the enclave. Additionally, this design would support the use of PSA APIs.

As an alternative, the secure element could be replaced by an internal TPM within the SoC, though it would not be compliant with the PSA API.

![Storage secure element](images/storage_secure_element_500px.jpg)

_figure 5: Storage via secure element diagram_




## Conclusions

In conclusion, SystemReady ensures interoperability between software components but does not guarantee security, as it does not account for implementation. Security is evaluated through PSA levels, which measure the design at level 1 and implementation itself at level 2 and 3. The various design options discussed offer different levels of security at varying engineering costs, which must be carefully considered based on the product's specific needs. Table 1 provides a comparison of the options described in this document.


| Standard  | Normal World | eMMC/RPMB |   External TPM |  Flash/EEPROM | Secure Element |
|-----------|--------------|-----------|----------------|---------------|----------------|
| SystemReady Devicetree band    | ![yes](images/check.jpg)[^1]  | ![yes](images/check.jpg) |  ![yes](images/check.jpg) |   ![yes](images/check.jpg) |  ![yes](images/check.jpg) |
| PSA level      | ![no](images/cross.jpg)   | __1__ | __3__ | __2__ | __3__ |
| PSA API     | ![no](images/cross.jpg)    | __it may__ |  ![no](images/cross.jpg)    | __it may__ |  ![yes](images/check.jpg)   | 

_table 1: hardware options comparison_

[^1]: Storage in the normal world is not deemed secure and is therefore not compliant with BBSR.

## References

[SystemReady Devicetree] [SystemReady](https://www.arm.com/architecture/system-architectures/systemready-compliance-program/systemready-devicetree-band), November 2024, [Arm Limited](http://arm.com)

[PSA Certified] [PSA](https://www.psacertified.org/)

[PSA spec] [Platform Security Architecture](https://www.arm.com/architecture/security-features/platform-security), July 2024, [Arm Limited](http://arm.com)

[PSA API] [Platform Security Architecture APIs](https://arm-software.github.io/psa-api/), August 2023, [Arm Limited](http://arm.com)

[Trusted Services] [Trusted Services](https://www.trustedfirmware.org/projects/trusted-services/)

\[BBSR] [Base Boot Security Requirements (BBSR)](https://developer.arm.com/documentation/den0107/latest/), [Arm Limited](http://arm.com)

[SystemReady]: https://www.arm.com/architecture/system-architectures/systemready-compliance-program/systemready-devicetree-band
[PSA]: https://www.psacertified.org/
[BBSR]: https://developer.arm.com/documentation/den0107/latest/
