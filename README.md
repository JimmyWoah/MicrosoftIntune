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

## Struttura del repository

`Structure
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
└─ README.md`
`Structure

---

### ✅ Convenzioni
- Ogni remediation dovrebbe includere **Detect.ps1** e **Remediate.ps1**
- Ogni cartella contenuto ha un **README.md** con:
  - scopo
  - prerequisiti
  - come usare in Intune
  - note / rollback / limiti
- Dove possibile: logging chiaro e idempotenza (rieseguibile senza effetti collaterali)

### ⚠️ Avvertenze
- **Usa questi script a tuo rischio.**
- Testa sempre su gruppo pilota / lab prima della produzione.
- Verifica contesto di esecuzione (SYSTEM vs utente), permessi, impatti (riavvii, uninstall, registro, servizi).
- Alcuni script possono essere distruttivi: leggi sempre l’header.

### 🤝 Contributi
Issue e Pull Request benvenute (fix, miglioramenti, nuove remediation/detection, documentazione).

### 📜 Licenza
Vedi file `LICENSE`.

---
