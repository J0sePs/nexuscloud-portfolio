# Contributing to NexusCloud Portfolio

Thanks for considering a contribution.

## Team roles (simulated)

| Nickname | Name | Role |
|---|---|---|
| A-LEAD | Alex Rivera | Tech Lead / Platform Engineer |
| B-DEV | Bruno Torres | Backend Developer |
| C-SEC | Carla Chen | Security & DevSecOps Engineer |
| D-OPS | Daniela Reyes | Site Reliability Engineer |

## Branching strategy

Trunk-based development with short-lived branches:
<type>/<nickname>/<ticket>-<short-description>

Examples:
- `feat/b-dev/NEX-42-rate-limiting`
- `fix/c-sec/NEX-51-jwt-validation`
- `docs/a-lead/NEX-30-adr-opentofu`

## Commit convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>(<scope>): <subject> [<ticket>]
```

Types: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`, `ci`, `security`.

## Pull Request process

1. Create a branch following the naming convention
2. Open a PR early as Draft
3. Ensure CI passes (green checks)
4. Request reviews per CODEOWNERS
5. Squash and merge when approved

## Local development

See `docs/07-local-lab-setup.md` for the full setup.
