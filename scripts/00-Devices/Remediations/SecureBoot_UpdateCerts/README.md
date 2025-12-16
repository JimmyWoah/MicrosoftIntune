# Intune Proactive Remediations: Secure Boot “Windows UEFI CA 2023” (rollout + reboot tracking)

This repo contains a pair of PowerShell scripts (Detection + Remediation) to manage, via **Intune Proactive Remediations**, the Secure Boot certificate/key updates related to **Windows UEFI CA 2023** using the registry trigger `AvailableUpdates=0x5944`.

Additionally, the Detection script is intentionally **strict** about one stage: if the device is **reboot pending** (`AvailableUpdates=0x4100`), it stays **Non-Compliant** until the reboot is completed.

---

## Repository contents

- `SecureBootCerts_Detect.ps1`  
  Determines device compliance (including reboot-required tracking).
- `SecureBootCerts_Remediate.ps1`  
  Sets `AvailableUpdates=0x5944` only when needed, with guardrails to avoid loops and unnecessary resets.

---

## Prerequisites

- Windows device booting in UEFI with Secure Boot available.
- Scripts executed as **SYSTEM** via Intune Proactive Remediations.
- PowerShell 5.1 compatible (avoid PS7-only operators such as `??`).

---

## Key concepts

### Registry keys used

- Update trigger:
  - `HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot`
    - `AvailableUpdates` (REG_DWORD)

- Status / error:
  - `HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing`
    - `UEFICA2023Status` (REG_SZ)
    - `UEFICA2023Error` (REG_DWORD)

---

## Detection script: how it works (step-by-step)

The Detection script returns **Compliant** (`exit 0`) or **Non-Compliant** (`exit 1`).

Evaluation order:

1) Reads:
   - `AvailableUpdates`
   - `UEFICA2023Status`
   - `UEFICA2023Error`

2) **Reboot required**: if `AvailableUpdates == 0x4100`  
   - Output: `Non-Compliant: Reboot required ...`
   - `exit 1`  
   Purpose: keep the device “red” until the reboot is actually performed (operational tracking).

3) **Servicing error**: if `UEFICA2023Error != 0`  
   - Output: `Non-Compliant: UEFICA2023Error=...`
   - `exit 1`

4) **In progress or completed**: if `UEFICA2023Status` is `In Progress` or `Updated`  
   - Output: `Compliant: UEFICA2023Status=...`
   - `exit 0`

5) **Firmware DB fallback**: if status is missing/unhelpful, it checks the UEFI Secure Boot DB for the string `Windows UEFI CA 2023` via:
   - `Get-SecureBootUEFI db`
   - If found: `Compliant`, `exit 0`

6) Otherwise:
   - Output: `Non-Compliant: Not updated or not in progress`
   - `exit 1`

### Important note about Intune UI
Intune typically shows:
- **Pre-remediation detection output**
- (if non-compliant) it runs remediation
- **Post-remediation detection output**

If a device is in the `0x4100` stage, it’s normal to see:
- Pre: `Non-Compliant: Reboot required...`
- Post: `Non-Compliant: Reboot required...`
because nothing changes until the device reboots.

---

## Remediation script: how it works (step-by-step)

Remediation runs **only** when Detection returns `exit 1`.

Goal: set `AvailableUpdates=0x5944` and (optionally) trigger the scheduled task, without “hammering” the device.

Main guardrails:

1) Reads `AvailableUpdates` early and logs its value.

2) If `AvailableUpdates == 0x4100` (reboot pending)  
   - Does **nothing**
   - Recommended output: `OK: Reboot required ... No registry changes.`
   - `exit 0`  
   Reason: at this stage you don’t want to re-set `0x5944`. You just need a reboot.

3) Reads `UEFICA2023Status` and `UEFICA2023Error`.

4) If `UEFICA2023Error != 0`  
   - Does not keep forcing
   - Exits cleanly (`exit 0`) or hard-fails (`exit 1`) depending on your operational choice.

5) If status is `In Progress` or `Updated`  
   - Does nothing
   - `exit 0`

6) If `AvailableUpdates` indicates progress already (non-zero and not `0x5944`)  
   - Does not reset
   - `exit 0`

7) Otherwise:
   - Sets `HKLM...\SecureBoot\AvailableUpdates` to `0x5944`
   - (Optional) triggers the scheduled task:
     - `\Microsoft\Windows\PI\Secure-Boot-Update`

---

## Intune setup (Proactive Remediations)

1) Intune admin center  
   `Devices` → `Scripts and remediations` → `Create` → `Create script package`

2) Upload:
   - Detection: `SecureBootCerts_Detect.ps1`
   - Remediation: `SecureBootCerts_Remediate.ps1`

3) Recommended options:
   - **Run this script using the logged-on credentials**: `No`
   - **Run script in 64-bit PowerShell**: `Yes`
   - **Enforce script signature check**: `No`
   - Schedule: at least daily (tune based on your maintenance/reboot strategy)

4) Assign to a pilot group first, then expand.

---

## How to interpret Intune status

- **Detection status: With issues** + output `Reboot required (0x4100)`  
  Means: rollout has progressed to the reboot-required stage; device must reboot.

- **Remediation status: Recurred** while still at `0x4100`  
  Means: the device keeps being detected as non-compliant at each run (because reboot hasn’t happened yet).  
  Remediation may still run, but it should be a **no-op** (by design).

---

## Quick troubleshooting

### “Get-SecureBootUEFI failed”
Possible causes:
- Device not in UEFI/Secure Boot not available
- Cmdlet not accessible in the current context (verify SYSTEM + 64-bit execution)

### `UEFICA2023Error` is non-zero
The script should not keep forcing. Open a troubleshooting track (UEFI/firmware, prerequisites, servicing state).

### Where to check Intune client logs
On the client:
- `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\agentexecutor.log`

---

## Operational safety notes

- Always start with a **pilot**.
- Avoid repeatedly forcing the trigger; guardrails are there to prevent resets/loops.
- If you want compliance to turn green automatically, you need a **reboot strategy** (maintenance windows, user notifications, etc.).

---

## Microsoft references

- Registry key updates for Secure Boot (Windows devices with IT-managed updates)  
  https://support.microsoft.com/en-us/topic/registry-key-updates-for-secure-boot-windows-devices-with-it-managed-updates-a7be69c9-4634-42e1-9ca1-df06f43f360d

- Secure Boot db/dbx variable update events (events and troubleshooting)  
  https://support.microsoft.com/en-us/topic/secure-boot-db-and-dbx-variable-update-events-37e47cf8-608b-4a87-8175-bdead630eb69

---
