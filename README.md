<div align="center">

# CarbonCraft

[![Carbon](https://img.shields.io/badge/@carbon%2Freact-v11-0f62fe?logo=ibm&logoColor=white)](https://carbondesignsystem.com)
[![Next.js](https://img.shields.io/badge/Next.js-15-000000?logo=nextdotjs&logoColor=white)](https://nextjs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178c6?logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

Claude Code plugin for building IBM Carbon Design System web UIs with Next.js 15 and TypeScript.

## Highlights

- **10 specialised skills** covering the full Carbon frontend lifecycle — from Biome tooling setup through OpenShift deployment
- **4 specialist agents** — architect, component generator, WCAG 2.1 AA reviewer, and design token advisor — each with a narrowly scoped role and the right model/effort budget
- **Biome auto-lint hook** runs `biome check --apply` on every `.ts`/`.tsx` write without a manual step
- **Server-shell/client-island enforced** — every skill and agent knows Carbon components are client-only and never places them in Server Components
- **Component generation in an isolated git worktree** — partial implementations never pollute the working tree

## Table of Contents

- [Installation](#installation)
- [Skill Architecture](#skill-architecture)
- [Specialist Agents](#specialist-agents)
- [Automation](#automation)
- [Skill Composition](#skill-composition)
- [Contributing](#contributing)
- [License](#license)

## Installation

Requires Claude Code v2.1.142 or later and Node.js 20+.

```bash
claude plugin install ./carboncraft
```

Test locally without installing:

```bash
claude --plugin-dir ./carboncraft
```

### TypeScript LSP

The plugin configures `typescript-language-server` for real-time type checking on `.ts` and `.tsx` files. Install it once globally:

```bash
npm install -g typescript-language-server typescript
```

---

## Skill Architecture

Skills are organised in three layers. Lower layers do not depend on higher ones — start at the foundation and build upward.

```
Layer 1 — Foundation
  webcraft-tooling-setup          Biome, pre-commit, detect-secrets, Storybook

Layer 2 — Framework
  webcraft-nextjs-architecture    App Router, server/client boundary, streaming, tsconfig

Layer 3 — Design System + Features
  webcraft-carbon-setup           @carbon/react install, SCSS barrel import, Theme provider
    webcraft-carbon-chat-ui       Streaming chat UI with Carbon + SSE
    webcraft-carbon-dashboard     DataTable, Carbon Charts, metrics tiles
    webcraft-forms-validation     TextInput, Select, Zod + React Hook Form
  webcraft-state-management       Zustand stores + TanStack Query
  webcraft-otel-frontend          OpenTelemetry Web SDK, RUM, web vitals
  webcraft-testing-setup          Vitest, Playwright, Carbon component testing patterns
  webcraft-openshift-deploy       Dockerfile, Helm, liveness probes, next output: standalone
```

### All skills

| Skill | Triggers on |
|-------|-------------|
| `webcraft-tooling-setup` | "set up Biome", "configure pre-commit", "lint TypeScript", "Biome Next.js" |
| `webcraft-nextjs-architecture` | "scaffold Next.js", "App Router structure", "server components", "streaming UI" |
| `webcraft-carbon-setup` | "set up Carbon", "add Carbon to Next.js", "Carbon SCSS", "Carbon tokens" |
| `webcraft-carbon-chat-ui` | "Carbon chat UI", "streaming chat", "chat island", "SSE chat" |
| `webcraft-carbon-dashboard` | "Carbon dashboard", "data table", "metrics panel", "Carbon charts" |
| `webcraft-forms-validation` | "Carbon form", "form validation", "TextInput validation", "form errors" |
| `webcraft-state-management` | "Zustand store", "TanStack Query", "client state", "server state" |
| `webcraft-otel-frontend` | "OpenTelemetry frontend", "RUM", "trace frontend", "web vitals" |
| `webcraft-testing-setup` | "set up Vitest", "Carbon testing", "component tests", "Playwright E2E" |
| `webcraft-openshift-deploy` | "deploy to OpenShift", "Dockerfile Next.js", "Helm chart", "health probe" |

**Auto-invocation** — Claude selects the skill based on your request. **Explicit invocation:**

```bash
/carboncraft:webcraft-carbon-setup
/carboncraft:webcraft-nextjs-architecture
/carboncraft:webcraft-carbon-dashboard
```

---

## Specialist Agents

| Agent | Model | Effort | Role |
|-------|-------|--------|------|
| `ui-architect` | Sonnet | High | Plans component hierarchy, server/client boundaries, and Carbon layout patterns. Returns a written implementation plan — no code. |
| `component-generator` | Sonnet | Medium | Implements Carbon components and pages to production quality in an isolated git worktree. |
| `accessibility-reviewer` | Sonnet | Medium | Audits for WCAG 2.1 AA: keyboard navigation, focus management, ARIA, and colour contrast. Read-only — reports findings only. |
| `design-token-advisor` | Haiku | Low | Answers token lookup questions: spacing, colour, theme values, SCSS namespaces. Read-only. |

**Agent delegation:**

```
"Ask the ui-architect to plan the settings page layout"
"Have the component-generator build the DataTable island"
"Get the accessibility-reviewer to audit ChatIsland.tsx"
"What Carbon token should I use for the card background?"
```

---

## Automation

### Biome PostToolUse hook

After every `.ts` or `.tsx` file write or edit, the plugin runs:

```bash
biome check --apply <file>
```

Requires `@biomejs/biome` in the project (via `webcraft-tooling-setup`) or `biome` available globally.

### Background monitors

Two monitors activate lazily when their corresponding skill is first invoked:

| Monitor | Activates on | Streams |
|---------|-------------|---------|
| `next-dev-log` | `webcraft-nextjs-architecture` | Next.js build trace from `.next/trace` |
| `carbon-build-log` | `webcraft-carbon-setup` | SCSS build output from `logs/build.log` |

To populate the build monitor:

```bash
npm run build 2>&1 | tee logs/build.log
```

---

## Skill Composition

When starting a new Carbon web project, invoke skills in this order:

1. `webcraft-tooling-setup` — Biome, pre-commit, Storybook
2. `webcraft-nextjs-architecture` — App Router scaffold, tsconfig, providers
3. `webcraft-carbon-setup` — `@carbon/react`, SCSS barrel import, Theme provider
4. Feature skills as needed: `webcraft-carbon-chat-ui`, `webcraft-carbon-dashboard`, `webcraft-forms-validation`
5. `webcraft-testing-setup` — Vitest unit tests, Playwright E2E, Carbon-specific test patterns
6. Cross-cutting: `webcraft-state-management`, `webcraft-otel-frontend`
7. `webcraft-openshift-deploy` — when ready to ship

---

## Contributing

Contributions are welcome. To propose a change:

1. Open an issue first for anything beyond a typo fix — describe the gap or improvement
2. Create a branch from `main` and make your changes
3. Validate the plugin before opening a PR:

```bash
claude plugin validate .
```

4. Test that all skills and agents load cleanly:

```bash
claude --plugin-dir .
# Inside the session:
/plugin list
/agents
/carboncraft:webcraft-carbon-setup
```

5. Open a pull request with a clear description of what changed and why

Skill content lives in `skills/<name>/SKILL.md` and `skills/<name>/references/*.md`. Agent definitions are in `agents/<name>.md`. All frontmatter fields are validated by `claude plugin validate`.

---

## License

[MIT](LICENSE) © 2026 Joseph Searle
