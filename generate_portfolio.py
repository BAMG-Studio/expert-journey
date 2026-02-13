#!/usr/bin/env python3
"""Generate a unified portfolio document from all project README files."""
import os
from pathlib import Path
from datetime import datetime

PROJECT_DIR = "docs/project"
OUTPUT_FILE = "docs/PORTFOLIO.md"

def get_project_dirs():
    """Get all project directories sorted by number."""
    base = Path(PROJECT_DIR)
    dirs = sorted([d for d in base.iterdir() if d.is_dir()])
    return dirs

def read_readme(project_dir):
    """Read README.md from a project directory."""
    readme = project_dir / "README.md"
    if readme.exists():
        return readme.read_text()
    return None

def generate_toc(projects):
    """Generate table of contents."""
    toc = "## Table of Contents\n\n"
    for i, (name, _) in enumerate(projects, 1):
        title = name.replace("-", " ").title()
        # Remove the number prefix
        parts = title.split(" ", 1)
        if parts[0].isdigit() and len(parts) > 1:
            title = parts[1]
        anchor = name.lower().replace(" ", "-")
        toc += f"{i}. [{title}](#{anchor})\n"
    return toc

def main():
    projects = []
    for d in get_project_dirs():
        content = read_readme(d)
        if content:
            projects.append((d.name, content))
    
    if not projects:
        print("No project README files found!")
        return
    
    # Build portfolio
    portfolio = f"""# DevSecOps & Cloud Security Portfolio

> **BAMG Studio** | Generated {datetime.utcnow().strftime('%Y-%m-%d')}
>
> Comprehensive documentation for 12 enterprise-grade security,
> DevOps, and ML engineering projects demonstrating expertise in
> AWS cloud architecture, security automation, and MLOps.

---

{generate_toc(projects)}
---

"""
    
    for name, content in projects:
        portfolio += f"\n\n---\n\n<!-- PROJECT: {name} -->\n\n{content}\n"
    
    # Write output
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, "w") as f:
        f.write(portfolio)
    
    print(f"Portfolio generated: {OUTPUT_FILE}")
    print(f"Total projects: {len(projects)}")
    print(f"Total size: {len(portfolio):,} characters")

if __name__ == "__main__":
    main()
