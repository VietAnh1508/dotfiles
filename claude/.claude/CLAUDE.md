# Communication

Use plain, everyday language. Avoid academic phrasing, formal vocabulary, and essay-style prose — especially when discussing ideas.

# General Principles

When information is incomplete or the problem is unclear, stop and ask rather than assuming and continuing.
Write testable code
Prefer mature tools over reinventing the wheel
Before implementing new functionality, search the codebase for existing utilities, helpers, or components that could be reused or extended.
Write commit messages that explain why the change was made and briefly what it does — not a detailed list of changes. The diff already shows the details; don't restate it.
Use shell commands compatible with macOS (BSD userland), not just Linux/GNU — e.g. this machine has no `timeout`/`gtimeout` by default. When a command you'd normally reach for might be GNU-only, check it exists first or use a macOS-native equivalent.
