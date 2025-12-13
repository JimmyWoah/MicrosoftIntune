# MicrosoftIntune
### Practical scripts for Microsoft Intune (Microsoft Endpoint Manager)

---

## EN English

## About me and why this exists
I'm **Simone Termine, a Secure Modern Workplace & Cloud Engineer** working on Modern Workplace scenarios (Intune, Entra ID, AVD, etc.).  
I created this repo as a single place to keep:
- "battle-tested" scripts used in real projects
- ready-to-use examples for Proactive Remediations, Win32 packaging, detection/remediation
- operational notes and mini-guides to avoid reinventing the wheel

> This is not an official Microsoft repository.

---

## Repository structure

```Structure
MicrosoftIntune/
├─ scripts/
│  ├─ 00-Devices/
│  │  └─ Remediations/
│  │     └─ <ScriptName>/
│  │        ├─ Detect.ps1
│  │        ├─ Remediate.ps1
│  │        └─ README.md
│  ├─ 01-Apps/
│  │  └─ Win32/
│  │     └─ <AppName>/
│  │        ├─ Install.ps1
│  │        ├─ Uninstall.ps1
│  │        ├─ Detection.ps1
│  │        └─ README.md
│  └─ _Templates/
│     ├─ Remediation.Detect.ps1
│     ├─ Remediation.Remediate.ps1
│     └─ Win32.Detection.ps1
├─ docs/
│  ├─ win32-packaging.md
│  └─ remediations.md
├─ .gitattributes
├─ .gitignore
├─ LICENSE
└─ README.md
```

---

### ✅ Conventions
- Each remediation should include **Detect.ps1** and **Remediate.ps1**
- Each remediation should include a **README.md** with:
  - purpose
  - prerequisites
  - how to use it in Intune
  - notes/rollback/limitations
- Whenever possible: clear logging and idempotent behavior (safe to run multiple times)

### ⚠️ Warnings
**Use these scripts at your own risk.**

- Always test in a lab/tenant or pilot group before production.
- Double-check execution context (SYSTEM vs user), permissions, and impact (reboots, uninstall, registry/service changes).
- Some scripts may be destructive. Always read the script header first.


### 🤝 Contributing
Issues and Pull Requests are welcome (fixes, improvements, new remediations/detections, documentation).

### 📜 License
See `LICENSE` file.

---
