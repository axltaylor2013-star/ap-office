#!/usr/bin/env python3
"""Scaffold a new Python project with standard structure."""
import os, sys

def scaffold(name):
    os.makedirs(name, exist_ok=True)

    # README.md
    with open(os.path.join(name, "README.md"), "w") as f:
        f.write(f"""# {name}

Brief description of the project.

## Install

```bash
pip install -r requirements.txt
```

## Usage

```bash
python main.py --help
```

## Examples

```bash
python main.py --input data.csv
```
""")

    # requirements.txt
    with open(os.path.join(name, "requirements.txt"), "w") as f:
        f.write("# Add dependencies here\n")

    # main.py
    with open(os.path.join(name, "main.py"), "w") as f:
        f.write(f'''#!/usr/bin/env python3
"""{name} - Brief description."""
import argparse
import sys


def main(args):
    """Main entry point."""
    print(f"Running {name} with input: {{args.input}}")
    # TODO: Implement main logic


def parse_args():
    parser = argparse.ArgumentParser(description="{name}")
    parser.add_argument("--input", "-i", required=True, help="Input file path")
    parser.add_argument("--output", "-o", default=None, help="Output file path")
    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    return parser.parse_args()


if __name__ == "__main__":
    try:
        args = parse_args()
        main(args)
    except KeyboardInterrupt:
        print("\\nAborted.")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {{e}}", file=sys.stderr)
        sys.exit(1)
''')

    print(f"Scaffolded project: {name}/")
    print(f"  - README.md")
    print(f"  - requirements.txt")
    print(f"  - main.py")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: scaffold.py <project-name>")
        sys.exit(1)
    scaffold(sys.argv[1])
