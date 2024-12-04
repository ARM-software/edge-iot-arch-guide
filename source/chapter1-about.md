<!--SPDX-License-Identifier: CC-BY-SA-4.0-->

# About This Document

## Introduction

Description and aim of this document ....

Comments or change requests can be sent to: [xxx@yyyy.xxx]().

## Guiding Principles

This section explains the goals and guiding principles behind the document:

- **Principle 1:** description  
- **Principle 2:** description  
- **Principle 3:** description  


## Scope

describe what's acceptable and what it is not

## Conventions Used in this Document

The key terms "MUST," "SHALL," "SHOULD," and others are to be interpreted per [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119). Deprecated features are indicated with warnings.

### Typographic Conventions

- *Italic:* Used for identifiers like UEFI tables, variables, protocols, and functions.  
- `Monospace:` Used for file paths and Devicetree nodes.

## Cross References

References are cited using section signs, e.g., :UEFI:`6.1` refers to UEFI specification section 6.1.

## Terms and Abbreviations

### Generic Terms

- **EFI Loaded Image:** Executable image run under UEFI using boot-time services.  
- **Logical Unit (LU):** Independent storage areas within a device.  
- **SoC:** System on a Chip.  
- **SPI:** Serial Peripheral Interface.  
- **UEFI:** Unified Extensible Firmware Interface.  
- **UEFI Boot Services:** Functions provided during the UEFI boot process.  
- **UEFI Runtime Services:** Functions provided after `ExitBootServices()` call.

### Architecture-Specific Terms

#### AARCH32

- **AArch32:** Refers to all 32-bit versions of the Arm architecture.

#### AARCH64

- **A64:** 64-bit Arm instruction set used in AArch64 state.  
- **AArch64 State:** Uses 64-bit registers and program counter.  
- **EL0-EL3:** Exception levels ranging from user applications (EL0) to secure monitor code (EL3).
