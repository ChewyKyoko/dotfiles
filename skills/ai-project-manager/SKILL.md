---
name: ai-project-manager
description: Generate SPEC.md, ROADMAP.md, and TASKS.md into any project directory, manage phase-based execution with approval checkpoints, and keep task status validated. Use when asked to plan a project, create planning docs, derive tasks, coordinate phases, update task status, or run an AI-assisted project workflow.
---
license: MIT
metadata:
  author: ChewyKyoko (adapted from Chris Titus Tech's titus-ai)
  source: https://github.com/ChrisTitusTech/titus-ai

---

# ai-project-manager

Only generates planning docs into the **target project directory**, never the dotfiles repo root.

## Workflow

1. Inspect repository instructions, current changes, and the active branch.
2. Identify which planning documents exist. Locate them at the repo root first, then under `docs/`. If both exist, surface conflicts.
3. Determine missing requirements, unresolved decisions, dependencies, risks, and implementation impact.
4. If the user asked to create missing planning files, copy templates from `assets/project-docs/` into the **project working directory**. Adapt them — remove irrelevant sections instead of leaving placeholders.
5. Create a phase plan mapped to acceptance criteria with clear validation, rollback, and pause points.
6. Present the plan and stop if the user reserved implementation approval.
7. Execute one reviewable phase at a time once authorized.
8. Validate, inspect diff, summarize evidence, update task status only after exit criteria pass.
9. Hand off to `pr-readiness` when asked to prepare, review, or merge.

## Diagnostics

```bash
git status --short
git branch --show-current
ls SPEC.md ROADMAP.md TASKS.md 2>/dev/null
```

Read every applicable `AGENTS.md` and planning doc. Do not assume planning files are under `docs/`.

## Safety Rules

- Never write planning docs into the dotfiles repo root unless the working project *is* the dotfiles repo.
- Never rewrite project requirements unless asked.
- Never mark a task done without validation or a stated reason for skipping.
- Never ignore conflicts between SPEC, ROADMAP, TASKS, and code.
- Never cross a user approval or plan-only checkpoint.
- Never treat an agent's implementation report as validation evidence.
- Keep project-specific knowledge in project docs, not reusable skills.
- Prefer small reviewable phases over broad plans.

## Validation

- Plan maps to documented requirements.
- Each task has clear scope and acceptance criteria.
- Automated and manual validation are defined before implementation.
- Completed work updates task status.
- Final diff contains only the intended phase.
- Final summary lists changed files, checks run, skipped checks, and residual risk.
