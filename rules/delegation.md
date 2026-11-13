## Delegation

- Handle routine work yourself. Delegate only when work can proceed independently and one agent can't finish it in one pass. Do not use subagents to verify or double-check your own work.
- Run scouts and workers with the `delegate` skill and reviews with the `review` skill. Each role is its own agent in a herdr pane:
  - `scout`: read-only reconnaissance, `claude --agent scout` (Haiku); `agent-role scout --via grok|pi` for another model.
  - `worker`: implementation, `claude --agent worker` in its own worktree.
  - `reviewer`: read-only review from another model family, `agent-role reviewer` (Grok by default; `--via pi` for GLM).
- Models and read-only flags live in the agent files (`~/.claude/agents/`) and `agent-role`; role rules for Grok and Pi live in `~/.config/agent-roles/`. Outside herdr, say so instead of starting role agents.
- Packets are files with six brief fields: **Goal**, **Use** (non-inheritable context), **Own**, **Do not**, **Return**, **Stop if**. Read-only roles need only Goal, Use, Return, and Stop if. Workers write their results to files under `<repo-root>/context/runs/`; read-only roles' answers come from their transcripts (the Claude pane, `grok export`, or Pi's session `.jsonl`).
- Evaluate every reviewer finding against the code before acting on it.
- Give parallel workers separate worktrees and reconcile their results on the main thread before the next step. Remove the worktrees and branches a run created once its work is merged or reported.
- Never answer a trust or approval prompt in a role's pane. Leave it for me.
- If you were started as a scout, worker, or reviewer from a packet, follow the packet and skip this section.
