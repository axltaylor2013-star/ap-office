---
name: python-project-scaffold
description: Scaffold and build standard Python projects. Use when creating new Python scripts, tools, or applications. Enforces consistent structure with README, requirements.txt, error handling, CLI arguments, and clean commented code.
---

# Python Project Scaffold

## Project Structure

```
project-name/
├── README.md
├── requirements.txt
├── main.py (or project_name.py)
└── utils/ (if needed)
```

## Standards

1. **README.md** — Description, install instructions, usage, examples
2. **requirements.txt** — Pin major versions (e.g., `requests>=2.28`)
3. **CLI arguments** — Use `argparse` for any script that takes input
4. **Error handling** — Try/except around I/O, API calls, file ops. Print helpful messages.
5. **Comments** — Docstrings on functions, inline comments for non-obvious logic
6. **Shebang** — `#!/usr/bin/env python3` on main scripts
7. **Main guard** — Always use `if __name__ == "__main__":`

## Scaffold Script

Run `scripts/scaffold.py <project-name>` to generate a new project folder with all boilerplate files pre-populated.

```bash
python scripts/scaffold.py my-tool
# Creates my-tool/ with README.md, requirements.txt, main.py
```

## README Template

```markdown
# Project Name

Brief description.

## Install

\`\`\`bash
pip install -r requirements.txt
\`\`\`

## Usage

\`\`\`bash
python main.py --input data.csv --output results.json
\`\`\`

## Examples

\`\`\`bash
python main.py --help
python main.py --input sample.csv
\`\`\`
```
