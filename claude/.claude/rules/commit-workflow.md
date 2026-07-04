When asked to commit and push:

1. **Scope check (parent):** Review staged files against the current task. If any staged file is unrelated, ask the user whether to unstage it before proceeding.
2. **Gather context (parent):** Collect `git diff --staged` and `git log --oneline -5`.
3. **Delegate to Haiku:** Spawn a subagent with `model: "haiku"`, passing the diff, log, and task summary. The subagent writes the commit message following Conventional Commits, then runs `git commit` and `git push`.

The commit message body should explain *why* the change was made and what problem it solves — not describe what changed (the diff already shows that).

Use a subagent rather than switching the main session model — model switching invalidates the prompt cache.
