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

Menu options (added features)

The script now offers numbered options 1 through 13 including:

1. Addition
1. Subtraction
1. Mixed Addition/Subtraction
1. Multiplication (standard)
1. Multiplication (fixed first factor, e.g., 2×N)
1. Multiplication X×Y (choose max for each factor)
1. Division (no remainders — produces only whole-number quotients)
1. Mixed Multiplication/Division (half multiplication, half division)
1. Convert existing worksheets to individual BRF files (requires liblouis)
1. Convert existing worksheets to a single combined BRF file (requires liblouis)
1. Generate AND convert to individual BRF files
1. Generate AND convert to single combined BRF
1. Exit


Symbols used

- Multiplication uses the multiplication cross '×' (U+00D7) and division uses '÷' (U+00F7). Subtraction uses the Unicode minus '−' (U+2212). These symbols improve Braille translation compatibility with liblouis / lou_translate.


Running on other shells

This repository includes equivalent interactive scripts for other shells:

- `math_worksheet_tui.sh` — bash (Linux, Git Bash on Windows)
- `math_worksheet_tui.zsh` — zsh (macOS)

Usage for bash/zsh

1. Make the script executable (Linux/macOS):

```bash
chmod +x ./math_worksheet_tui.sh
chmod +x ./math_worksheet_tui.zsh
```

1. Run the desired script:

```bash
./math_worksheet_tui.sh
# or
./math_worksheet_tui.zsh
```

The bash and zsh scripts use the same numbered menu (1..13) and the same generation features as the PowerShell script.

Full menu (what you'll see)

1. Addition
2. Subtraction
3. Mixed Addition/Subtraction
4. Multiplication (standard)
5. Multiplication (fixed first factor, e.g., 2×N)
6. Multiplication X×Y (choose max for each factor)
7. Division (no remainders — produces only whole-number quotients)
8. Mixed Multiplication/Division (half multiplication, half division)
9. Convert existing worksheets to individual BRF files (requires liblouis)
10. Convert existing worksheets to a single combined BRF file (requires liblouis)
11. Generate AND convert to individual BRF files
12. Generate AND convert to single combined BRF
13. Exit

Symbols used

- Multiplication uses the multiplication cross '×' (U+00D7) and division uses '÷' (U+00F7). Subtraction uses the Unicode minus '−' (U+2212). These symbols improve Braille translation compatibility with liblouis / lou_translate.

Braille conversion (lou_translate) — bash/zsh notes

Both `math_worksheet_tui.sh` and `math_worksheet_tui.zsh` can now call the `lou_translate` tool to produce BRF files. The scripts attempt to auto-detect `lou_translate` (from your PATH) and the liblouis table file. You can also override the locations with environment variables:

- `LOU_TRANSLATE_PATH` — full path to the `lou_translate` executable (for example `C:\liblouis\bin\lou_translate.exe` on Windows or `/usr/bin/lou_translate` on Linux)
- `LIBLOUIS_TABLE` — full path to the liblouis table file (for example: `/usr/share/liblouis/tables/en-ueb-g2.ctb`)

Examples

- Temporarily set the environment variables and run the bash script (Linux/macOS):

```bash
export LOU_TRANSLATE_PATH=/usr/bin/lou_translate
export LIBLOUIS_TABLE=/usr/share/liblouis/tables/en-ueb-g2.ctb
./math_worksheet_tui.sh
```

- On Windows PowerShell (one-time for the session):

```powershell
$env:LOU_TRANSLATE_PATH = 'C:\liblouis\bin\lou_translate.exe'
$env:LIBLOUIS_TABLE = 'C:\liblouis\share\liblouis\tables\en-ueb-g2.ctb'
# then run Git Bash or WSL script as needed
```

What the scripts do when converting

- Option 9 will convert each `.txt` worksheet in the `math_worksheets` folder into a separate `.brf` file.
- Option 10 will combine all `.txt` worksheets into one `.brf` file (a form feed is added between worksheets).
- Options 11 and 12 are "generate then convert" flows: the script prompts for generation settings, creates worksheets, then runs the chosen conversion step.

Troubleshooting

- If you see "lou_translate not found", either install liblouis (platform package managers are listed below) or set `LOU_TRANSLATE_PATH` to the correct executable.
- If a table file cannot be found, set `LIBLOUIS_TABLE` to the correct `.ctb` (or `.tbl`) file. Common locations are `/usr/share/liblouis/tables/` or `/usr/local/share/liblouis/tables/` on Unix-like systems.

Troubleshooting (PowerShell / Windows)

- "Running scripts is disabled": Use the one-time command shown earlier with `-ExecutionPolicy Bypass` to run the file without changing system settings.
- "pwsh not recognized": Use `powershell` if PowerShell Core (`pwsh`) isn't installed.

Privacy & safety

- No personal data is required to use this script. It runs locally on your computer and does not send anything to the internet.

If you'd like help

- If you want, paste the exact message you see in PowerShell or the shell and someone can help you with the next small step.

License

- See the `LICENSE` file in this repository for license details.

Optional dependency: liblouis (for braille translation)

This project can use `lou_translate` to convert worksheets into Unified English Braille (UEB). To enable that feature you must install the native liblouis library on your computer. Installing liblouis is a one-time step.

Install liblouis (quick guide)

- Windows: use a package manager like Chocolatey or download prebuilt binaries. Example (elevated PowerShell):

```powershell
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

- The scripts call `lou_translate --forward <table>` to perform the conversion. If you installed liblouis and still see errors, confirm `lou_translate` is on your PATH or set the `LOU_TRANSLATE_PATH` and `LIBLOUIS_TABLE` environment variables as shown above.
- If liblouis is not installed, the braille translation option will be skipped or an error will appear when attempting to use `lou_translate`.

