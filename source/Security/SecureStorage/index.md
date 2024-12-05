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

## Introduction  
  
1. [SystemReady][SystemReady] specifies the API’s firmware must expose to and OS in order to support Secure Boot usecases, however it does not enforce that the API’s are actually implemented in a secure manner.​
2. [PSA][PSA] certification specifies a number of runtime security features that should be supported, It also attempts to verify they have been implemented in a secure manner.​
   - At Level 2 and above this involves a full code audit of everything below the security API​
   - The API is only specified if you wish to gain the additional PSA Level2 API certification.​
3. This means your hardware choice is wide and not fixed but certain choices will restrict what security level certifications you could achieve​

## Hardware options
### Storage in normal world only

In the most simple scenario, as shown in figure 1, a single storage medium is used connecting to everysingle firmware and software component, which where EFI variables live on a file within that media and u-boot is compiled to use that file.
From a systemReady perspective, standard interfaces are used therefore ensuring interoperability between sofware modules, however this implementation choice is secure, hence failing to meet PSA requirements.

| Standard  | Compliancy | 
|-----------|-----|
| SystemReady Devicetree band    | ![yes](images/check.jpg)  | 
| PSA level      | ![no](images/cross.jpg)   | 
| PSA API     | ![no](images/cross.jpg)    | 


![Storage normal world](images/storage_normal_world.jpg)

_figure 1: Storage in normal world diagram_

### Storage in eMMC/RPMB
In this design option, the actual storage has two partitions, one hosting the rootfs and the other hosting the efi variables, in such a way that the one hosting variables is hidden from the normal-world. The downside to this, is the access to this storage is done through Linux, therefore an OTP is essential to hold the keys locking and unlocking the access to RPMB. this is certainly more secure as the first option and it would be passing PSA level 1 as some sort of secure storage is present but it definetly won't achieve PSA level 2 as this configuration implies all the software stack is related to the access to the secure storage so the whole software stack is subject to audition, which is very time consuming and everytime a firmware of software update happens another audit should be carried out, making it simply impractical to achieve PSA level 2. In terms of PSA API it could apply if fTPM or Trusted sources were used.  

An alternative to having to use OTP to store the keys is to include the keys into the bootloader and encrypt it. That would posing a different attack surface.

| Standard  | Compliancy | 
|-----------|-----|
| SystemReady Devicetree band    | ![yes](images/check.jpg)   | 
| PSA level      | __1__ | 
| PSA API     | __?__  | 

### Storage in external TPM

| Standard  | Compliancy | 
|-----------|-----|
| SystemReady Devicetree band    | ![yes](images/check.jpg)   | 
| PSA level      | __3__  | 
| PSA API     | ![no](images/cross.jpg)    | 

### Storage in Flash/EEPROM

| Standard  | Compliancy | 
|-----------|-----|
| SystemReady Devicetree band    | ![yes](images/check.jpg)   | 
| PSA level      | __2__  | 
| PSA API     | __?__  | 

### Storage via Secure element

| Standard  | Compliancy | 
|-----------|-----|
| SystemReady Devicetree band    | ![yes](images/check.jpg)   | 
| PSA level      | __3__  | 
| PSA API     | ![yes](images/check.jpg)   | 


## Conclusions

[SystemReady]: https://www.arm.com/architecture/system-architectures/systemready-compliance-program/systemready-devicetree-band
[PSA]: https://www.psacertified.org/
