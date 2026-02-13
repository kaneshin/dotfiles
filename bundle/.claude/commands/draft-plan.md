---
name: draft-plan
description: Create a detailed implementation plan in plan.md based on research findings. Do not implement yet.
---

## Planning Phase

You are entering the **planning phase**. Based on your research (check `research.md` if available), create a comprehensive implementation plan.

### Instructions

1. **Review research** — Read `research.md` if it exists in the current directory. Understand the codebase context before planning.

2. **Create the plan** — Write a detailed implementation plan to `plan.md` in the current working directory, structured as follows:

   - **Goal**: Clear statement of what we're building or changing
   - **Approach**: High-level strategy and rationale
   - **Phases**: Break the work into sequential phases, each containing:
     - Description of what the phase accomplishes
     - Specific files to create or modify (with paths)
     - Code snippets or pseudocode showing the approach
     - Dependencies on other phases
   - **Trade-offs**: Alternatives considered and why this approach was chosen
   - **Risks**: Potential issues and mitigation strategies
   - **Testing strategy**: How to verify the implementation works

3. **Be specific** — Include actual file paths, function names, and code snippets. The plan should be concrete enough that implementation is straightforward.

4. **Do NOT implement anything** — This phase is planning only. No code changes.

### Important

- Each phase should be a checkable task (use `- [ ]` checkboxes).
- Keep phases small and incremental — prefer many small steps over few large ones.
- The plan is a living document. It will be reviewed and annotated before implementation begins.
