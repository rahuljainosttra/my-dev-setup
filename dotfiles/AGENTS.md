# Global Agent Instructions

These instructions provide universal guidelines for AI coding assistants working across all projects and repositories on this machine.

---

## 1. Core Principles & Mindset

- **Pragmatic & Context-Aware**: Inspect existing project structure, dependencies, formatting, and idioms before introducing new patterns or libraries.
- **Safety First**: Never execute destructive commands (`rm -rf`, force push, database drops) without explicit confirmation.
- **Minimal Footprint**: Avoid modifying files unrelated to the task. Keep diffs focused and clean.
- **Verify Assumptions**: When in doubt about requirements or architecture, verify in the codebase or ask clarifying questions rather than guessing.

---

## 2. File Operations & Scripting Rules

- **Use Built-in Tools First**: Use built-in tools (`read_file`, `write_file`, `edit_file`, glob, grep search) for code exploration and targeted edits.
- **No Unnecessary Scripts**: Never write a script just to read, move, or patch a file.
- **Prefer One-Liners**: Prefer one-line CLI tools/commands over multi-line scripts for simple structured edits.
- **When to Use Scripting**: Use Python, Node, or Bash when a task requires exact math, bulk data parsing, API calls, or schema validation.
- **Cleanup Temporary Scripts**: Delete temporary scripts immediately after running them unless explicitly asked to save them in `~/trioptima/codebase/my-dev-setup/ai-scripts`.
- **Reusable Utilities**: Store vetted, reusable scripts in `~/trioptima/codebase/my-dev-setup/ai-scripts` and add that path to your auto-allow list (to eliminate repetitive permission prompts).

---

## 3. Code Quality & Standards

- **Read Before Writing**: Inspect existing patterns, linting configs, and test suites in the repository before authoring new code.
- **Testing**: Whenever modifying or adding features, run existing test suites and add unit/integration tests covering edge cases.
- **Error Handling**: Favor explicit error handling over swallowing exceptions or failing silently.
- **Documentation**: Document public APIs, non-obvious logic, and important architectural decisions concisely.

---

## 4. Tooling & Environment

- **CLI Tools**:
  - Use `rg` (ripgrep) for searching file contents.
  - Use `find` or `fd` for finding file names and directory trees.
  - Use `git` for inspecting repository history and changes (`git status`, `git diff`, `git log`).
- **Environment & Runtimes**:
  - Respect project-local runtime managers (e.g., `mise`, `asdf`, `.venv`, `nvm`).

---

## 5. Git & Commits

- Never commit secrets, credentials, API keys, or large binary artifacts.
