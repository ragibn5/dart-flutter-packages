# WHITELABEL.md Process Verification

Results of following the whitelabel process on a fresh copy of `app_template`.

## Verdict: Flow works conceptually, but several issues found

### 🐛 Bug: `setup.sh` references wrong path for `firebase_setup.sh`

**File:** `scripts/setup.sh`, lines 247–248 and 263–266

The script references `./firebase_setup.sh`, but the file lives at `scripts/firebase_setup.sh`. When the user runs:

```bash
bash scripts/whitelabel.sh
```

from the project root, `./firebase_setup.sh` resolves to `<project_root>/firebase_setup.sh` — which does not exist. The firebase step will always print:

> ❌ Error: firebase_setup.sh not found in the current directory.

**Fix:** Change all `./firebase_setup.sh` references to `./scripts/firebase_setup.sh` in `setup.sh`.

---

### 📦 `package_rename` is a dead dependency

`pubspec.yaml` lists `package_rename: ^1.10.1` as a dev dependency, and `package_rename_config.yaml` exists at the project root. However, **neither** `WHITELABEL.md` **nor** `setup.sh` mention or use this tool. The setup script uses its own `replaceTextInFiles` + directory move instead.

This is misleading — a user might edit the `package_rename_config.yaml` expecting it to do something, or wonder whether they should run `fvm dart run package_rename`. Either remove the unused dependency, or document/implement its usage.

---

### 🔤 Typo: `nameSpace` should be `namespace`

**File:** `WHITELABEL.md`, line 56

> change the `nameSpace` to `com.ragib.fltemplate`

The actual Gradle property is `namespace` (all lowercase). `nameSpace` is not a valid property and will cause a build error if copied literally.

---

### 📝 Contradictory guidance for icon/splash commands

The manual steps in `WHITELABEL.md` say to run:

```bash
fvm dart run flutter_launcher_icons
```

But the `setup.sh` script's guide for the same step says:
> You do not have to run any commands separately, even if the doc mentions to run any.

This is confusing — whether you should run the command depends on which path (manual vs scripted) you're taking. The WHITELABEL.md could clarify that the commands are automatically prompted by the script, but are required if following the manual steps.

---

### 📄 Manual section order vs script order

`WHITELABEL.md` lists steps in this order:

1. Flavor setup
2. Dart package name
3. App Id
4. App name
5. Launcher icon
6. Splash screen
7. Firebase

The `setup.sh` follows a slightly different order:

1. Project cleanup
2. Dart package rename
3. Platform package rename
4. App name guide
5. Launcher icon guide
6. Splash icon guide
7. Firebase guide
8. Clean + pub get

Not a bug, but the manual section headers ("Set up app/project specific identifiers, resources & services" → sub-bullets) could be easier to navigate if they matched the script's sequence.
