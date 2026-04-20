# AGENTS.md

HyprlandConfig is the Borg desktop configuration project for CachyOS/Hyprland, focused on a fast AI-augmented workstation.

<!-- BORG_KNOWLEDGE_WORKFLOW_START -->
## Borg Knowledge Vault & AI Workflow

- Treat `/home/_johan/Documents/Borg` as the durable cross-project memory layer. Start with `300 Entities/Projects/Portfolio - Condensed Knowledge.md`, `400 Resources/Tech/AI Knowledge Map.md`, `000 OS / Meta/AI Collaboration Protocol.md`, and `300 Entities/People/Johan - Working Profile.md`.
- Use the vault symlink `300 Entities/Projects/HyprlandConfig` and related notes `300 Entities/Projects/HyprlandConfig.md`, `400 Resources/Tech/Hyprland.md`, and `300 Entities/Projects/Sherlock.md` before making desktop workflow decisions.
- Keep repo-local docs authoritative for exact config paths, but mirror durable workstation knowledge back into the vault when it affects AI workflow, agent ergonomics, or cross-project tooling.
- If Beads is present, run `bd prime`, use `bd ready/show/update/close`, and do not create markdown TODOs for trackable work.
- If kspec is present, update specs before tasks, give every automation task full context/todos/acceptance criteria, and let `kspec agent dispatch` manage its own worktrees.
- If GitNexus is present, use it before code edits: impact analysis before symbol changes, change detection before commits, and preserve embeddings when re-analyzing.
- Use RTK for noisy command output when available or when terminal output would obscure decisions.
- Before finishing, run the smallest meaningful quality gate, update docs/vault notes if knowledge changed, commit intentionally, and push when the branch scope is clear.
<!-- BORG_KNOWLEDGE_WORKFLOW_END -->
