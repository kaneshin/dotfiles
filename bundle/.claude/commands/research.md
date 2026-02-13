---
name: research
description: Deep-read a codebase area and write detailed findings to research.md. Use this before planning any implementation.
---

## Research Phase

You are entering the **research phase**. Your goal is to deeply understand the specified area of the codebase before any implementation work begins.

### Instructions

1. **Read deeply** — Thoroughly read and analyze the relevant files, modules, and their dependencies. Understand not just what the code does, but *how* and *why* it works that way.

2. **Trace the intricacies** — Follow the control flow, data flow, and integration points. Identify patterns, conventions, edge cases, and implicit assumptions in the code.

3. **Write findings** — Create or update `research.md` in the current working directory with a detailed report covering:
   - **Overview**: High-level summary of the area you explored
   - **Architecture**: How the components are structured and connected
   - **Key patterns**: Design patterns, conventions, and idioms used
   - **Dependencies**: Internal and external dependencies and their roles
   - **Edge cases & gotchas**: Non-obvious behavior, potential pitfalls
   - **Relevant context**: Configuration, environment, or deployment considerations

4. **Do NOT implement anything** — This phase is research only. No code changes.

### Important

- Be thorough. Read every relevant file in depth before writing the report.
- Include specific file paths and line references.
- If you discover something unexpected or concerning, call it out explicitly.
- The quality of this research directly determines the quality of the subsequent plan.
