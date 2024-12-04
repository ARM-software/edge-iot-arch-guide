# Hardware design options for Secure Storage

## Table of Contents
- [Introduction](#introduction)
- [Hardware options](#hardware-options)
  - [Storage in normal world only](#storage-in-normal-world-only)
  - [Storage in eMMC/RPMB](#storage-in-emmc/rpmb)
  - [Storage in external TPM](#storage-in-external-tpm)
  - [Storage in Flash/EEPROM](#storage-in-flash/eeprom)
  - [Storage via Secure Element](#storage-via-secure-element)
- [Conclusions](#conclusions)

## Introduction  
  
1. System Ready specifies the API’s firmware must expose to and OS in order to support Secure Boot usecases, however it does not enforce that the API’s are actually implemented in a secure manner.​
2. PSA certification specifies a number of runtime security features that should be supported, It also attempts to verify they have been implemented in a secure manner.​
   - At Level 2 and above this involves a full code audit of everything below the security API​
   - The API is only specified if you wish to gain the additional PSA Level2 API certification.​
3. This means your hardware choice is wide and not fixed but certain choices will restrict what security level certifications you could achieve​

## Hardware options
### Storage in normal world only

### Storage in eMMC/RMPB

### Storage in external TPM

### Storage in Flash/EEPROM

### Storage via Secure element

## Conclusions
