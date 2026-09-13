# AGENTS.md

This file defines the working rules for AI coding agents operating on this Roblox RPG project.

These instructions are project-level defaults. Follow them unless the user explicitly gives different instructions for a specific task.

---

# 1. Core Working Principles

## Build the correct solution

Prefer complete, maintainable solutions over temporary patches.

Do not implement the first solution that merely works. Understand the surrounding system enough to implement the change correctly.

At the same time, do not unnecessarily expand the scope of a task.

Do not refactor unrelated code unless the requested change genuinely requires it.

## Understand before editing

Before modifying a system:

1. Locate the relevant files.
2. Understand the existing execution flow.
3. Identify existing modules, utilities, services, controllers, remotes, and abstractions involved.
4. Follow dependencies when necessary.
5. Only then implement the change.

Do not assume how a system works based only on file names.

Read the implementation.

## Search before building

Before creating a new:

- ModuleScript
- service
- controller
- manager
- utility
- RemoteEvent
- RemoteFunction
- state system
- data structure
- abstraction

search the project for equivalent or related functionality.

Reuse or extend existing infrastructure whenever reasonable.

Never create duplicate systems simply because understanding the existing implementation requires more work.

---

# 2. Task Sizing

Adjust investigation and verification effort to the size of the task.

## Small tasks

Examples:

- changing a value
- adjusting text
- modifying a color
- fixing a simple condition
- small UI adjustments
- straightforward local changes

For small tasks:

- inspect the directly relevant code
- make the smallest correct change
- verify obvious integrations
- do not investigate unrelated systems

## Medium tasks

Examples:

- modifying an existing feature
- adding a new item behavior
- changing NPC behavior
- modifying inventory logic
- adding a UI interaction
- integrating with an existing system

For medium tasks:

- inspect the complete local execution path
- inspect related modules and dependencies
- check client/server interactions
- verify cleanup and edge cases
- preserve existing architecture

## Large tasks

Examples:

- new progression systems
- major inventory changes
- new combat systems
- large NPC systems
- major world mechanics
- persistence architecture
- major UI systems
- architectural changes

For large tasks:

- map the relevant architecture first
- identify affected systems
- identify data ownership
- identify client/server boundaries
- identify persistence implications
- identify failure and cleanup paths
- implement incrementally when practical
- perform a final integration review

Do not treat every task as large.

---

# 3. Context Discipline

Read enough context to understand the complete relevant execution path, but avoid loading unrelated parts of the project without reason.

Follow references when necessary, including:

- callers
- dependencies
- shared modules
- server/client counterparts
- RemoteEvents
- RemoteFunctions
- state systems
- data systems
- UI controllers

Do not scan the entire repository for a localized change unless the architecture makes it necessary.

Relevant context is more valuable than maximum context.

---

# 4. Existing Architecture Is Authoritative

The existing project architecture is the default source of truth.

Before introducing a new pattern, learn how the project currently handles similar problems.

Preserve established:

- naming conventions
- folder organization
- module boundaries
- service patterns
- controller patterns
- APIs
- remote organization
- state representation
- data structures

Do not introduce a new architectural style simply because you personally prefer it.

If the existing architecture has a serious limitation that affects the requested task, explain the issue before performing a major architectural replacement.

---

# 5. Roblox & Luau Rules

This is a Roblox project.

Use Luau and Roblox APIs appropriately.

Prefer Roblox-native mechanisms when they provide a clean solution.

Use appropriate Roblox services rather than recreating functionality unnecessarily.

Keep server, client, and shared responsibilities clearly separated.

Do not place server-authoritative behavior on the client for convenience.

Avoid unnecessary Instances.

Avoid unnecessary RemoteEvents and RemoteFunctions.

Do not repeatedly search the DataModel for objects when stable references can reasonably be maintained.

Use `WaitForChild` only when waiting is genuinely necessary.

Do not blindly replace direct indexing with `WaitForChild`.

Avoid infinite yields.

Respect Roblox object lifecycle behavior.

---

# 6. Server Authority & Security

Never trust the client with authoritative gameplay decisions.

Treat client requests as requests, not proof.

The server should validate security-sensitive actions including, when applicable:

- currency changes
- item ownership
- inventory modifications
- purchases
- rewards
- damage
- healing
- cooldowns
- target validity
- interaction distance
- quest completion
- progression
- equipment
- drops
- crafting
- trading
- permissions

Never allow the client to freely specify authoritative values such as:

- damage amount
- currency reward
- item reward
- experience reward
- arbitrary target
- arbitrary inventory contents

Validate remote arguments.

Consider exploiters intentionally sending:

- malformed values
- unexpected types
- nonexistent Instances
- Instances they do not own
- extreme numbers
- NaN values
- requests at excessive frequency
- requests in impossible game states

Do not add excessive validation where there is no meaningful trust boundary.

---

# 7. RPG Systems

When changing RPG gameplay, consider interactions with relevant systems.

Potential systems include:

- player progression
- levels
- experience
- stats
- equipment
- inventory
- items
- weapons
- armor
- accessories
- enemies
- bosses
- NPCs
- quests
- drops
- currencies
- shops
- crafting
- abilities
- status effects
- world progression
- unlocks
- persistence

Only investigate systems relevant to the requested task.

Do not modify unrelated systems merely because they appear in this list.

---

# 8. Items & Inventory

Item identity and ownership must remain consistent.

Avoid duplicating item definitions across unrelated scripts.

Prefer a canonical source for static item information when the existing architecture supports one.

When changing inventory behavior, consider:

- stacking
- quantities
- ownership
- equipping
- unequipping
- deletion
- rewards
- drops
- persistence
- duplicate requests
- death
- respawn
- reconnecting

Inventory changes with economic consequences must be server-authoritative.

Do not trust UI state as inventory state.

---

# 9. NPCs, Enemies & Bosses

NPC systems should have clear lifecycle ownership.

When implementing or modifying NPC behavior, consider:

- spawning
- targeting
- aggro
- movement
- attacks
- damage
- death
- rewards
- respawning
- cleanup
- player leaving
- target becoming invalid

Avoid expensive global searches every frame.

Avoid giving every NPC an unnecessary independent high-frequency loop when centralized or event-driven approaches would work better.

Do not optimize prematurely, but avoid obviously unscalable designs.

---

# 10. World & Interaction Systems

World interactions should validate that the player is actually allowed to perform them.

When relevant, consider:

- distance
- progression requirements
- ownership
- cooldown
- current state
- whether the target still exists
- whether the interaction can happen repeatedly

Client UI may indicate availability, but the server determines authoritative eligibility.

---

# 11. Data & Persistence

Persistent data is high-risk.

Be conservative when modifying:

- save schemas
- profile structures
- item identifiers
- progression fields
- currencies
- inventory representation

Do not rename, remove, or reinterpret persistent fields without considering existing player data.

When changing persistent structures, preserve backwards compatibility when practical.

Do not perform destructive migrations without explicit user approval.

Saving should never depend solely on the client.

Consider duplicate requests and session lifecycle.

Do not assume a data library or framework unless the project actually uses it.

Inspect the existing persistence implementation first.

---

# 12. UI

Follow the project's existing UI design system and implementation patterns.

Before creating a new UI component, inspect similar existing interfaces.

Reuse existing:

- components
- animations
- sounds
- spacing conventions
- typography
- colors
- interaction patterns

when appropriate.

UI should communicate server state, not become the authoritative source of gameplay state.

Avoid embedding important gameplay logic directly into UI scripts when it belongs in reusable systems.

Keep UI behavior responsive.

Do not create continuous RenderStepped updates for static UI.

---

# 13. Performance

Assume the game may contain many:

- players
- NPCs
- items
- effects
- interactions
- world objects

Avoid unnecessary per-frame work.

Prefer events over polling when practical.

Avoid repeatedly scanning large Workspace hierarchies.

Avoid unnecessary network traffic.

Do not send remote updates every frame unless the feature genuinely requires it.

Avoid recreating identical tables or Instances in hot paths without reason.

Consider whether code runs:

- once
- per player
- per NPC
- per item
- per frame

before introducing expensive operations.

Performance optimizations should remain readable and justified.

---

# 14. Lifecycle & Cleanup

Every temporary resource should have a clear cleanup path.

This includes:

- RBXScriptConnections
- tasks
- threads
- Instances
- constraints
- effects
- temporary state
- temporary UI
- animations
- sounds

When relevant, consider:

- player leaving
- character death
- character respawn
- NPC death
- cancellation
- interruption
- target destruction
- repeated activation

Avoid resource leaks and abandoned connections.

---

# 15. Concurrency & Race Conditions

Roblox gameplay is asynchronous.

Consider race conditions when multiple actions can happen close together.

Be especially careful around:

- inventory changes
- rewards
- purchases
- equipping
- saving
- NPC death
- drops
- cooldowns
- respawning
- repeated remote requests

Do not assume two callbacks cannot execute close together.

Use explicit state where necessary.

Avoid fragile timing-based correctness.

---

# 16. Testing & Verification

Use existing test infrastructure when appropriate.

Do not create meaningless tests merely to satisfy a testing rule.

For behavior that can reasonably be tested automatically, test it.

For Roblox behavior requiring Studio, perform static verification and identify what needs to be playtested.

For bug fixes:

1. Understand the reproduction case.
2. Identify the actual cause.
3. Fix the cause rather than hiding the symptom.
4. Check nearby execution paths for the same issue.

Never claim that Studio-specific behavior was successfully playtested unless it actually was.

---

# 17. Final Review

Before finishing a meaningful implementation, review the actual changes.

Look specifically for:

- incomplete integrations
- duplicated logic
- broken references
- regressions
- resource leaks
- race conditions
- missing validation
- client/server trust problems
- persistence compatibility problems
- unnecessary complexity
- unrelated changes

Fix issues discovered during this review before reporting completion.

---

# 18. Confusion Protocol

Do not ask the user to make routine implementation decisions.

Choose reasonable implementation details yourself when they follow existing project conventions.

Ask before proceeding when ambiguity would materially affect:

- architecture
- gameplay behavior
- persistent data
- security
- backwards compatibility
- destructive actions
- large scope expansion

When asking, explain the concrete alternatives and why the decision matters.

---

# 19. Safety

Do not perform destructive repository or project operations unless explicitly requested.

Do not:

- delete large systems
- rewrite unrelated systems
- remove persistent data
- perform destructive migrations
- reset project configuration
- discard user changes

without clear justification and user approval when appropriate.

Do not commit, push, create branches, open pull requests, or modify remote repositories unless explicitly requested.

Never discard existing user changes simply because they conflict with your preferred implementation.

---

# 20. Communication

Be concise but informative.

When finishing a task, explain:

- what changed
- important implementation decisions
- files or systems affected
- anything that requires Studio verification
- relevant limitations or follow-up concerns

Do not narrate every trivial action.

Do not produce unnecessary status reports.

Do not hide uncertainty.

Never claim something was verified when it was not.

---

# 21. Definition of Done

A task is complete when:

- the requested behavior is implemented
- the implementation follows existing architecture
- relevant integrations were considered
- server/client boundaries remain correct
- security-sensitive behavior is validated
- lifecycle and cleanup are handled
- obvious edge cases are addressed
- unnecessary unrelated changes were avoided
- the final diff was reviewed
- remaining Studio-only verification is clearly identified

A solution that merely works in the simplest case is not necessarily complete.

A solution also does not need to solve unrelated future problems.

Implement the requested feature completely, correctly, and within scope.

---

# 22. Project-Specific Knowledge

This section is intentionally reserved for project-specific information.

Update it as the project evolves.

Recommended information to document here:

- folder structure
- architecture overview
- major systems
- important modules
- remote organization
- data schema
- item architecture
- NPC architecture
- UI architecture
- naming conventions
- persistence system
- important invariants
- known technical constraints
- systems that should never be duplicated
