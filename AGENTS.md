---
type: reference
tags:
  - project/hyprlandconfig
aliases:
- AGENTS
---
# AGENTS.md
Up: [[HyprlandConfig INDEX]]

#projects #hyprlandconfig

HyprlandConfig is the Borg desktop configuration project for CachyOS/Hyprland, focused on a fast AI-augmented workstation.

<!-- MCP_REGISTRY_RULES_START -->
## MCP Registry Rules

- Treat `/home/_johan/Documents/Borg/AI-Agents/_shared/mcp-registry.md` as the canonical MCP source of truth.
- Link it into active project roots as `MCP-REGISTRY.md` when practical.
- Core MCPs: Memory (`@modelcontextprotocol/server-memory`), Context7 (`@upstash/context7-mcp`), and GitNexus (`gitnexus mcp`) for active development repos.
- Enable Playwright MCP (`playwright-mcp`) only for UI/web/visual verification work.
- Use per-agent config templates from `/home/_johan/Documents/Borg/AI-Agents/<agent>/` instead of ad-hoc snippets.
- Use fully qualified MCP tool names in durable docs/skills when referencing connector tools.
- Keep secrets out of MCP config files; use environment variables or the agent auth flow.
- For Google-agent workflows, prefer Antigravity CLI (`agy`, installed via `https://antigravity.google/cli/install.sh`) over legacy Gemini CLI.
<!-- MCP_REGISTRY_RULES_END -->

<!-- BORG_KNOWLEDGE_WORKFLOW_START -->
## Borg Knowledge Vault & AI Workflow

- Treat `/home/_johan/Documents/Borg` as the durable cross-project memory layer. Start with `300 Entities/Projects/Portfolio - Condensed Knowledge.md`, `400 Resources/Tech/AI Knowledge Map.md`, `000 OS / Meta/AI Collaboration Protocol.md`, and `300 Entities/People/Johan - Working Profile.md`.
- Use the vault symlink `300 Entities/Projects/HyprlandConfig` and related notes `300 Entities/Projects/HyprlandConfig.md`, `400 Resources/Tech/Hyprland.md`, and `300 Entities/Projects/Sherlock.md` before making desktop workflow decisions.
- Keep repo-local docs authoritative for exact config paths, but mirror durable workstation knowledge back into the vault when it affects AI workflow, agent ergonomics, or cross-project tooling.
- If Beads is present, run `bd prime`, use `bd ready/show/update/close`, and do not create markdown TODOs for trackable work.
- Use GSD for planning, specs, execution, review, and verification when work needs structure beyond Beads task tracking.
- If GitNexus is present, use it before code edits: impact analysis before symbol changes, change detection before commits, and preserve embeddings when re-analyzing.
- Use RTK for noisy command output when available or when terminal output would obscure decisions.
- Before finishing, run the smallest meaningful quality gate, update docs/vault notes if knowledge changed, commit intentionally, and push when the branch scope is clear.
<!-- BORG_KNOWLEDGE_WORKFLOW_END -->
