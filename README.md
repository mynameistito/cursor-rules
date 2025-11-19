# Cursor Rules

![Sync Cursor Rules (Production)](https://github.com/mynameistito/cursor-rules/actions/workflows/sync-cursor-rules.yml/badge.svg)

<!-- DESCRIPTION START -->
A comprehensive collection of coding standards, workflow guidelines, and best practices for modern web development with Cursor IDE. This repository provides AI-powered rules that enforce consistent patterns across your projects.
<!-- DESCRIPTION END -->

<!-- OVERVIEW START -->
## 📋 Overview

This repository contains structured rules (`.mdc` files) that guide Cursor's AI assistant to follow your team's coding standards automatically. These rules cover everything from package management to deployment strategies, ensuring consistency and quality across your codebase.

<!-- OVERVIEW END -->

<!-- REPOS USING RULES START -->
## 📦 Repos Using These Rules


- [mynameistito/cursor-rules-test-1](https://github.com/mynameistito/cursor-rules-test-1)
- [mynameistito/cursor-rules-test-2](https://github.com/mynameistito/cursor-rules-test-2)
- [KillzoneGaming/kzg-servers-connect](https://github.com/KillzoneGaming/kzg-servers-connect)
- [KillzoneGaming/kzg-workshop-map-puller](https://github.com/KillzoneGaming/kzg-workshop-map-puller)
- [KillzoneGaming/kzg-website-nextjs](https://github.com/KillzoneGaming/kzg-website-nextjs)
- [KillzoneGaming/kzg-discord-oidc-worker](https://github.com/KillzoneGaming/kzg-discord-oidc-worker)
- [KillzoneGaming/kzg-vip-confirmation-email-worker](https://github.com/KillzoneGaming/kzg-vip-confirmation-email-worker)
- [KillzoneGaming/kzg-discord-servers-webhook](https://github.com/KillzoneGaming/kzg-discord-servers-webhook)
- [KillzoneGaming/kzg-surf-maps-discord-bot](https://github.com/KillzoneGaming/kzg-surf-maps-discord-bot)
<!-- REPOS USING RULES END -->

<!-- WHAT'S INCLUDED START -->
## 🎯 What's Included

<!-- CORE STANDARDS START -->

### Core Standards

- **Master Coding Guidelines** (`general.mdc`) - React 19, Next.js, Ultracite (Biome), Bun, TSDoc, and agent-optimized patterns
- **Bun & Biome Workflow** (`bun.mdc`) - Strict Bun package management, native testing, and Biome linting
- **Next.js & React** (`react-nextjs.mdc`) - App Router patterns, Server Components, Shadcn UI, and state management
- **Git Standards** (`git.mdc`) - Conventional Commits and atomic change practices
- **Cloudflare** (`cloudflare.mdc`) - Workers deployment, Edge runtime constraints, and R2 storage
- **Drizzle ORM** (`drizzle.mdc`) - Schema definitions, migrations, and D1 best practices
<!-- CORE STANDARDS START -->

<!-- ADVANCED FEATURES START -->
### Advanced Features

- **Rule Architect** (`rule-architect.mdc`) - Automatic detection and suggestion of new project-specific rules
- **Global Rule Manager** (`global-rule-manager.mdc`) - Centralized rule management and synchronization from GitHub
- **Planning Agent** (`plan.mdc`) - Structured planning workflows with sequential thinking and research tools
- **PRD & Task Management** (`prd-file-structure-and-taskmanagement.mdc`) - Project requirements, design docs, and master task list management
<!-- ADVANCED FEATURES END -->

<!-- QUICK START START -->
## 🚀 Quick Start

### Setup in Your Project

1. **Clone this repository** into your project's `.cursor/rules` directory:

```bash
mkdir -p .cursor
git clone https://github.com/mynameistito/cursor-rules.git .cursor/rules
```

2. **Add to `.gitignore`** (to prevent nested repo issues):

```gitignore
# Cursor Rules (Managed via Global Sync)
.cursor/rules/
```

3. **Resync Context** in Cursor IDE to load the rules.

### Bootstrap Script

For automated setup, use the bootstrap workflow defined in the rules:

```bash
# This will create local context directories and sync rules
# Follow the prompts in your terminal
```

<!-- REPOSITORY STRUCTURE START -->
## 📁 Repository Structure

```
./
├── .cursor/
│   ├── commands/
│   │   ├── build.md
│   │   ├── commit.md
│   │   ├── issues.md
│   │   └── planning-agent.md
│   ├── rules/
│   │   ├── bun.mdc
│   │   ├── cloudflare - Copy.mdc
│   │   ├── cloudflare.mdc
│   │   ├── drizzle.mdc
│   │   ├── general.mdc
│   │   ├── git.mdc
│   │   ├── global-rule-manager.mdc
│   │   ├── plan.mdc
│   │   ├── prd-file-structure-and-taskmanagement.mdc
│   │   ├── react-nextjs.mdc
│   │   └── rule-architect.mdc
│   └── worktrees.json
├── scripts/
│   ├── auto-push-cursor-rules.ps1
│   ├── update-repos.sh
│   └── update-structure.sh*
├── .gitattributes
├── .gitignore
├── LICENSE
└── README.md
```
<!-- REPOSITORY STRUCTURE END -->

<!-- RULE FORMAT START -->
## 🛠️ Rule Format

Rules are written in Markdown with frontmatter metadata:

```markdown
---
description: Brief description of what this rule enforces
globs: **/*.ts, **/*.tsx    # Files this rule applies to
alwaysApply: true           # Whether to apply globally
---
# Rule Title

**Trigger:** When this rule should activate

## 1. Standard
*   **Requirement:** Description
*   **Example:** Code example
```
<!-- RULE FORMAT END -->

<!-- KEY STANDARDS START -->
## 🎨 Key Standards Enforced

### Package Management
- ✅ Bun as the exclusive package manager
- ✅ `bun.lockb` as single source of truth
- ✅ `bunx` for CLI tools (never `npx`)

### Code Quality
- ✅ Biome for linting and formatting
- ✅ No `any` types (use `unknown` + Zod)
- ✅ Named exports only (no default exports)
- ✅ TSDoc documentation standards

### React/Next.js
- ✅ Server Components by default
- ✅ Shadcn UI components
- ✅ TanStack Query for client data fetching
- ✅ Server Actions for mutations

### Git Workflow
- ✅ Conventional Commits format
- ✅ Atomic changes
- ✅ Pre-commit linting checks
<!-- KEY STANDARDS END -->

<!-- CUSTOMIZATION START -->
## 🔧 Customization

### Creating Project-Specific Rules

The Rule Architect will automatically detect patterns and suggest new rules. You can also manually create rules:

1. Create a new `.mdc` file in `.cursor/rules/`
2. Follow the rule template format
3. Specify appropriate `globs` for file targeting
4. Set `alwaysApply: false` for contextual rules

### Example: Adding a Payment Module Rule

```markdown
---
description: Payment processing standards for Stripe integration
globs: src/payment/**/*.ts
alwaysApply: false
---
# Payment Standards

**Trigger:** When working with payment-related code

## 1. Error Handling
*   **Requirement:** All Stripe calls must be wrapped in try/catch
*   **Logging:** Use structured logging to Datadog
```
<!-- CUSTOMIZATION END -->

<!-- RULE CATERGORIES START -->
## 📚 Rule Categories

| Rule | Scope | Always Applied |
|------|-------|----------------|
| `general.mdc` | Master coding standards, React 19, TypeScript | ✅ Yes |
| `bun.mdc` | Package management, scripts, testing | ✅ Yes |
| `react-nextjs.mdc` | React/Next.js components, App Router | ✅ Yes |
| `git.mdc` | Commit messages, version control | ❌ No |
| `cloudflare.mdc` | Cloudflare Workers, Edge runtime | ❌ No |
| `drizzle.mdc` | Database schemas, migrations, D1 | ❌ No |
| `rule-architect.mdc` | Rule detection and suggestion | ✅ Yes |
| `global-rule-manager.mdc` | Rule synchronization and bootstrap | ✅ Yes |
| `plan.mdc` | Planning workflows and task management | ❌ No |
| `prd-file-structure-and-taskmanagement.mdc` | PRD, design docs, task lists | ❌ No |
<!-- RULE CATERGORIES END -->

<!-- CONTRIBUTING START -->
## 🤝 Contributing

1. **Fork** this repository
2. **Create** a feature branch
3. **Add/Update** rules following the established format
4. **Test** rules in a sample project
5. **Submit** a pull request with clear description

<!-- RULE CONTRIBTUION GUIDELINES START -->
### Rule Contribution Guidelines

- Use descriptive, kebab-case filenames
- Include comprehensive examples
- Specify precise `globs` patterns
- Document the "why" not just the "what"
- Add TSDoc examples for complex patterns
<!-- RULE CONTRIBTUION GUIDELINES END -->
<!-- CONTRIBUTING END -->

<!-- LICENSE START -->

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

<!-- LICENSE END -->

<!-- RELATED RESOURCES START -->

## 🔗 Related Resources

- [Cursor IDE Documentation](https://cursor.sh/docs)
- [Bun Documentation](https://bun.sh/docs)
- [Next.js App Router](https://nextjs.org/docs/app)
- [Biome Documentation](https://biomejs.dev)
- [ultracite](https://ultracite.ai)

<!-- RELATED RESOURCES END -->

<!-- TIPS START -->

## 💡 Tips

- **Resync Context** after updating rules to ensure Cursor picks up changes
- Use **specific globs** to avoid rule conflicts
- **Test rules** in a small project before applying globally
- Keep rules **focused** - one rule file per concern area

<!-- TIPS END -->
---

**Maintained by:** [My Name is Tito](https://github.com/mynameistito)  


