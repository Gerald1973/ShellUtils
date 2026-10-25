# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project overview

ShellUtils is a personal collection of standalone shell utilities (Debian/Linux). There is no build system, no test suite and no package manager: each script is independent and run directly.

## Layout

| Directory | Content |
|-----------|---------|
| `add_and_remove/` | Install/remove services (e.g. PostgreSQL 16) |
| `build/` | Build-from-source scripts (OpenCubicPlayer, VICE...) |
| `dosboxx/` | DOSBox-X launchers, `.desktop` files and icons for old games |
| `file/` | File and directory manipulation (chmod, rename, PDF extract, fonts...); `file/python/` holds Python helpers |
| `git/` | Git helpers (backup, status of all projects, closest branch by tag) |
| `hardware/` | System diagnostics, USB camera hub reset (with `systemd/` unit) |
| `install/` | Software installers (e.g. Docker) |
| `languagetemplate/` | Project generators (e.g. Java/Maven) |
| `video/` | ffmpeg-based tools (convert, cut, compile with NVIDIA) |
| root | Misc scripts (`url_info.sh`, `transcript_from_vdo.sh`, `gpggithub.sh`, ...) |

## Conventions

- Scripts start with a shebang, preferably `#!/usr/bin/env bash` (recent commits switched to an explicit bash shebang; keep it for new scripts).
- Scripts must be executable (`chmod +x`).
- Scripts with arguments should print a usage message (heredoc) when called with the wrong number of parameters, as in `file/chmodr.sh`.
- Quote variable expansions (`"${var}"`) in new code.
- Script names are lowercase with underscores, versions in build scripts go in the filename (`build_vice_3.9.sh`).
- Comments and usage messages are written in English or French; follow the language of the file being edited.
- Prefer small, self-contained scripts over shared libraries; do not introduce dependencies between scripts.

## Working rules

- Many scripts install packages, modify system files or run `sudo`. Never execute them to "test" without explicit user approval; use `bash -n script.sh` for syntax checks and `shellcheck` if available.
- Do not commit generated output (e.g. `hardware/diagnostic-performance.txt`) unless asked.
- Do not run `git commit` or `git push` unless asked. Commit messages in this repo are short and in English (e.g. "Doom added.").
- Update `README.md` or the relevant sub-directory README (e.g. `dosboxx/README.md`) when adding a notable script.
- The comments and the code needs to be in english us.
