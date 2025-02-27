<!--SPDX-License-Identifier: CC-BY-SA-4.0-->

# About This Document

## Introduction

For over two decades, building software stacks for embedded devices has been a standard practice. However, evolving demands for interoperability across operating systems, richer software stacks, and adherence to stricter security regulations have introduced new complexities that many vendors find overwhelming. Recognizing these challenges, the System Architecture Advisory Committee, under Arm's SystemReady initiative, began in February 2024 to explore ways to make existing specifications and technologies more accessible.

One key insight from the recent [Linaro Connect](https://www.linaro.org/connect/) 2024 event highlighted the critical need for consistent documentation to guide developers through the vast landscape of available resources. This document addresses that need by offering guidance on designing interoperable systems based on Arm’s SystemReady and PSA specification collections. It aims to serve as a collaborative resource for vendors and developers, focusing on design strategies and implementation options.

Note that this document does not include code; its purpose is to provide design options always according to industry standards in embedded systems.

Comments or change requests can be sent to: [SystemArchAC chair](mailto:sac-rich-iot-edge-chair@arm.causewaynow.com)

## Guiding Principles

This section explains the goals and guiding principles behind the document:

- **Upon existing principles driving SystemReady:** Design options provided will be following guiding principles behind SystemReady, i.e. interoperability between platforms and OSes.
- **Architcture specific:** Only Arm based systems will be targetted in this document
- **Neutral point of view:**  All content must be written from a neutral point of view and without a commercial or promotional bias.  
- **Design for common Edge IoT systems:** Topics and design options will be targeting devices intended to be used as Edge IoT devices, not embdeded servers or servers.

## Scope

This document is a collection of unrelated design options, i.e. this document is not intended to be read from cover to cover. Each chapter addresses a separate topic that may not relate to others. The chapters present various alternatives, enabling designers to make informed decisions about which option best fits their business needs while understanding the potential implications of their choices.

While SystemReady focuses on the critical point of interoperability between platforms and operating systems, the scope of this document includes design options at any layer within the software stack. However, these options are considered only when this interoperability boundary is crossed, such as when upper software stack layers depend on services provided by the platform in the lower layers.

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
