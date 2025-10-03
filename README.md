# MathWorksheetBeneratorForUEB

Math Worksheet Generator (simple text interface)

This repository contains a small, easy-to-run PowerShell script called `math_worksheet_tui.ps1` that helps teachers create printable math worksheets quickly. It uses a plain text menu (a TUI — text user interface) so you don't need to install extra software or learn programming.

Who this is for
- Teachers who want quick, repeatable math practice sheets.
- No programming experience needed—just a little familiarity with opening PowerShell and running a file.

What the script does (in plain language)
- Asks a few simple questions (for example: which operation, how many problems, and number ranges).
- Generates a text worksheet you can print or copy into a document.

Quick start (Windows, PowerShell)
1. Download or copy the repository folder to your computer. Make sure `math_worksheet_tui.ps1` is in the folder you open PowerShell in.
2. Open PowerShell (press Start, type "PowerShell" and open "PowerShell" or "pwsh").
3. If your system prevents running scripts, you'll see a message like "running scripts is disabled on this system". You can either (a) run the script once without changing system settings, or (b) allow scripts for your user account.

Run once without changing settings (recommended if you are unsure):
```pwsh
pwsh -NoProfile -ExecutionPolicy Bypass -File .\math_worksheet_tui.ps1
```

Allow scripts for your user account (only if you’re comfortable):
```pwsh
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Confirm:$false
# Then run:
pwsh -NoProfile -File .\math_worksheet_tui.ps1
```

What to expect when it runs
- A simple menu in the terminal asking what kind of worksheet you want (e.g. addition, subtraction), how many problems, and the number ranges.
- The script prints the worksheet in the terminal and may save a text file in the same folder.

Simple example (what you might see):
```
Math Worksheet Generator
1) Addition
2) Subtraction
Select operation: 1
How many problems? 20
Minimum number: 1
Maximum number: 12

--- Worksheet ---
1) 7 + 3 =
2) 4 + 9 = 
...
```

Troubleshooting
- "Running scripts is disabled": Use the one-time command above with `-ExecutionPolicy Bypass` to run the file without changing system settings. If you need to run scripts regularly, consider the `Set-ExecutionPolicy` command shown earlier.
- "Command not found" or "pwsh not recognized": Make sure you opened PowerShell (Windows PowerShell or PowerShell Core/pwsh). If your computer only has Windows PowerShell, replace `pwsh` with `powershell` in the commands.
- Files not saved: The script prints the worksheet in the terminal. Check the script folder for any newly created `.txt` files or copy the terminal output into a document for printing.

Privacy & safety
- No personal data is required to use this script. It runs locally on your computer and does not send anything to the internet.

If you'd like help
- If you want, paste the exact message you see in PowerShell and someone can help you with the next small step.

License
- See the `LICENSE` file in this repository for license details.

Optional dependency: liblouis (for braille translation)

This project can use `lou_translate` to convert worksheets into Unified English Braille (UEB). To enable that feature you must install the native liblouis library on your computer. The script will call the system library — installing liblouis is a one-time step.

Install liblouis (quick guide)
- Windows: download the liblouis binaries or use a package manager like Chocolatey. Example with Chocolatey (run in an elevated PowerShell prompt):

```pwsh
choco install liblouis
```

- macOS: with Homebrew:

```bash
brew install liblouis
```

- Ubuntu / Debian:

```bash
sudo apt update
sudo apt install liblouis-bin liblouis-dev
```

Notes
- The script expects the liblouis command-line tools or a matching Python wrapper (for example, the `python-louis` or `louis` packages) to be available. If you install a Python wrapper, install it into the Python environment you use to run any Python parts of this project.
- If liblouis is not installed, the braille translation option will be skipped or an error will appear when attempting to use `lou_translate`.

