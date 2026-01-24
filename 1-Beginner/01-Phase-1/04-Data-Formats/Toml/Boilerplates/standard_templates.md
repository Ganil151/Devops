# ⚙️ TOML Boilerplates: Modern Tooling Configs

This directory contains standardized TOML templates used for modern Python and static site generator configurations.

## 1. Python `pyproject.toml` Blueprint
The modern PEP 518 standard for managing Python dependencies and build systems.

```toml
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "devops_automation_toolkit"
version = "0.1.0"
authors = [
  { name="Senior Platform Engineer", email="architect@example.com" },
]
description = "A collection of high-performance automation utilities"
readme = "README.md"
requires-python = ">=3.9"
classifiers = [
    "Programming Language :: Python :: 3",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
]

[project.urls]
"Homepage" = "https://github.com/organization/toolkit"
"Bug Tracker" = "https://github.com/organization/toolkit/issues"
```

## 2. Hugo Configuration Blueprint
Standard configuration for a Hugo-based documentation site.

```toml
baseURL = 'https://docs.example.com/'
languageCode = 'en-us'
title = 'Infrastructure Documentation'
theme = 'ananke'

[params]
  description = 'High-fidelity DevOps curriculum'
  footer_text = '© 2026 DevOps Mastery'
```
