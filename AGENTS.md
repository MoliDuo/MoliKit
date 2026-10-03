# AGENTS.md

<!-- prettier-ignore-start -->
<!-- moli-rules:start -->
## Moli rules (copied verbatim from MoliSpec; do not edit)

These rules apply to every Moli repository. The full standards live in the private repo `MoliDuo/MoliSpec` (`standards/`).

**Naming**
- Product name `MoliFoo` (repo, package, file and identifier names, no spaces). User-facing name is `Moli Foo` (one space): window titles, app name, UI text, README title, Release titles.

**Deploy and CI**
- Deploy only after CI passes. Merging to `main` deploys to production (server apps), so run the check entry (`npm run check` or the stack's equivalent) locally before opening the PR, and watch CI and the deploy after it merges.
- Keep the CI names fixed: workflows `ci` / `deploy` / `release` / `codeql`; jobs `check`, `gitleaks`, `build`, `integration`, `ci-gate`.
- Never delete or skip tests, or loosen lint rules, to make a check pass.

**Git**
- Conventional Commits (`feat(scope): subject`).
- Never push to `main` directly. Every change, however small, goes on a new branch and is merged through a PR with auto-merge on. Before starting, update local `main` (`git switch main && git pull`) and branch from it; if a push is rejected or the branch is behind, pull the latest `main` and merge or rebase it in.
- Never force-push `main`. Roll back with `git revert`.

**Secrets and private information**
- Never commit secrets, `.env` files, keys, or internal information (server addresses, hostnames, Tailscale addresses, personal emails). Use obviously fake values in tests and examples (`test-token`, `example.com`, `192.0.2.1`).
- Never print secret values in logs, chat, or commits. Never store secrets in the OS keychain. Runtime secrets live in the server `.env` (mode 600); build and release secrets live in GitHub organization secrets.
- Do not copy a shared (organization-level) secret into repository-level secrets unless the administrator has said so.

**Login, data, config**
- Sign-in is Authelia only. Do not build your own accounts, passwords or registration pages.
- Database and settings schemas only add; never delete or rename an existing field in one step. Migrations must keep the previous app version working.
- Clients are offline-first and the server is authoritative. Settings are read in the order defined in the config standard; do not invent a second source.
- Use Singapore time (`Asia/Singapore`, UTC+8) for every time: UI, logs, docs, containers (`TZ=Asia/Singapore`). Store and send times as ISO 8601 with `+08:00` or as integer milliseconds; never a time without its offset.
- Server apps expose `GET /healthz` returning `{"ok": true, "version": "<commit sha>"}`, run as non-root, take config from environment variables, and publish no host ports.

**Working with the user**
- Do only what was asked. Do not publish, delete, or change shared settings (GitHub org, server, DNS) without being asked.
- Reply to the user in Chinese, briefly.
<!-- moli-rules:end -->
<!-- prettier-ignore-end -->

## About this project

MoliKit holds the pieces that every Moli repository shares and that may be public: composite GitHub Actions (`actions/*`). Other repositories pin them by commit sha. Anything private or internal (server names, user lists, the standards text) stays in MoliSpec, never here: this repository is public.

## Run and test

- Check (same as CI): `./scripts/check.sh` (needs Docker and Python with PyYAML)
- The actions cannot run locally. Change them on a branch, open a pull request, and read the ci run; a caller repository tests a new version through its own pull request.

## Do not touch

- The names of the actions, their inputs and outputs: callers depend on them. Add, do not rename.
- Never put a server address, user name, hostname, or secret in this repository. Callers pass such values in.
