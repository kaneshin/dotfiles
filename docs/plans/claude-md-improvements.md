# CLAUDE.md Improvement Plan

## Current State

- **File**: `bundle/.claude/CLAUDE.md` (symlinked to `~/.claude/CLAUDE.md`)
- **Purpose**: Global instructions applied to every Claude Code session across all projects
- **Score after this session's improvements**: 76/100 (Grade B)
- **Previous score (before this session)**: 52/100 (Grade C)

---

## Scoring Criteria

| Criterion | Weight | What it measures |
|-----------|--------|-----------------|
| Commands/workflows | 20 | Are key commands present, accurate, and copy-paste ready? |
| Architecture clarity | 20 | Is the file's scope and structure clear? Does it orient Claude? |
| Non-obvious patterns | 15 | Does it capture user-specific conventions that aren't general knowledge? |
| Conciseness | 15 | Is it tight? No fluff, no repetition? |
| Currency | 15 | Does it reflect the current toolchain and codebase? |
| Actionability | 15 | Can Claude act on instructions without ambiguity or follow-up? |

---

## Section-by-Section Assessment (Post-Improvement State)

### Role and Expertise (lines 5–7)
**Strengths:** Sets context quickly. "Senior engineer at a fast-moving startup" gives Claude a useful decision-making frame.
**Improvement opportunity:** Could be tightened to one sentence. The second sentence ("responsible for critical technical decisions…") restates the first.

### Design Principles — KISS / YAGNI (lines 9–25)
**Strengths:** Clear named principles with practical bullet points.
**Improvement opportunity:** Each principle has a 3-bullet list where 1–2 bullets would suffice. The explanatory bullets ("The result is more readable…", "Reduce code bloat…") are consequences, not instructions — Claude doesn't need to be told why KISS is good.

### General Architecture Guidelines (lines 27–33)
**Strengths:** Compact. "Easy to debug and test locally" is actionable.
**Improvement opportunity:** "Use progressive enhancement" is ambiguous in a non-frontend context. Either scope it to UI work or remove it. "Keeps deployment lightweight" has a subject–verb agreement issue.

### Development Workflow (lines 35–52)
**Strengths:** Clear numbered steps. Both Standard and UI workflows cover the full loop. UI workflow is now framework-agnostic (good — was Remix-specific before).
**Improvement opportunity:** Step 2 in Standard Workflow mentions `/plan` but that's a skill name, not a slash command — it could confuse new sessions. The UI workflow could name Playwright's specific `browser_snapshot` tool to make it more concrete.

### TDD & Commit Discipline (lines 56–96)
**Strengths:** Well-structured. Tidy First distinction (structural vs behavioral changes) is genuinely non-obvious and valuable. Commit gate (all tests passing, no warnings) is concrete.
**Improvement opportunity:** The external Kent Beck link is a fragile dependency — if the URL 404s, the instruction becomes a dead reference. The core principles could be inlined in 2–3 sentences and the link kept as "further reading" only.

---

## Completed Improvements (This Session)

1. **Deduplication** — Removed the repetition between Kent Beck section and Design Principles. Previously both sections said "write simple code / don't over-engineer" in different words.
2. **Scope declaration** — Added implicit global-file framing. File now reads as "all projects" guidance rather than appearing to be project-specific.
3. **UI workflow generalization** — Removed the "Implement in Remix route" instruction that was project-specific. Now reads "Implement the component/page in the appropriate framework route."

---

## Open Improvement Areas (Ranked by Impact)

### 1. Trim KISS/YAGNI bullet lists (Low effort, Medium impact)
Each principle currently has 3 bullets where 1–2 would suffice. Remove consequence-explaining bullets; keep only the instructional ones. Saves ~6 lines.

**Example change:**
```diff
 ### KISS (Keep It Simple, Stupid)
-Apply KISS by choosing simple, maintainable solutions over clever complexity
-- Encourage Claude to write simple, straightforward solutions
-- Avoid over-design and unnecessary complexity
-- The result is more readable and maintainable code
+- Prefer simple, straightforward solutions over clever complexity
+- Avoid over-design
```

### 2. Add personal language/tool preferences (Medium effort, High impact)
The file has no mention of preferred languages, test frameworks, or style conventions. This is the most common gap in global CLAUDE.md files — without it, Claude defaults to its training priors rather than user preference.

**Example addition (after Architecture Guidelines):**
```markdown
## Personal Preferences
- Language defaults: Go for CLIs/services, TypeScript for web, Python for scripts
- Test framework: Use the project's existing framework; prefer table-driven tests
- Naming: snake_case for files, camelCase for JS/TS, no abbreviations
```

### 3. Fix the Kent Beck external link dependency (Low effort, Medium impact)
The link to a raw GitHub file is fragile. Inline the 2–3 key principles and demote the link to "reference."

### 4. Clarify "progressive enhancement" scope (Low effort, Low impact)
Either scope it to UI contexts or replace with a clearer equivalent for backend/CLI work (e.g., "Build incrementally; ship the simplest thing that works first").

### 5. Add preferred Claude model hints (Low effort, Low impact)
For AI-assisted work within the dotfiles repo, noting a preferred model (e.g., "use Sonnet for routine edits, Opus for architecture decisions") can reduce friction.

---

## Notes for Next Session

- Run the `claude-md-improver` skill to re-score after any changes: it will catch regressions
- The project-root `./CLAUDE.md` (the dotfiles repo itself) was created this session and scores 82/100 — it needs only minor additions (`--verbose` flag, `DOTFILES_DEBUG=1` env var)
- Don't add project-specific content to `bundle/.claude/CLAUDE.md` — it is global and affects all Claude Code sessions
