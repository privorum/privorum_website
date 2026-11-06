---
title: "Eleven open-source security tools: what we adopt, trial and skip"
description: "Eleven open-source security tools, from Gitleaks to garak, checked against a Go, React and AI agent stack: three to adopt, six to trial, two to skip."
date: 2026-11-06T17:00:00+01:00
tags: ["security", "ci", "llm", "agents"]
keywords: ["open source security tools for ci", "gitleaks vs trufflehog", "osv-scanner vs govulncheck", "semgrep custom rules", "garak prompt injection testing", "security tools for ai agents", "scan agent skills before install"]
series: "Security"
toc: true
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "security-audit"
---

A LinkedIn post listed eleven open-source security tools "to put between your code and production". We took it as a menu, not a checklist, and checked each tool against one of our products before installing any of them.

The result: three tools to adopt, six to trial and two to skip. This article is that assessment, and the order we will roll the tools out in. Nothing is installed yet, so it reports what we decided and why, not what the tools found.

## The verdicts at a glance

- **Adopt:** Gitleaks, OSV-Scanner, Semgrep.
- **Trial:** garak, Claude Code Security Review, Cloudflare's security-audit skill, Nuclei, NVIDIA SkillSpector, Strix.
- **Skip:** TruffleHog (apart from one history audit), zizmor.

The rule behind the order: tools that give the same answer on every run go first, and they can block a merge. AI reviewers and tools that attack a running system come after, and they advise. The attack tools only ever point at a test stack.

## The stack we checked them against

The product is NeverGoBlank, our AI career coaching platform. Its attack surface is larger than "a Go API":

- **A Go API** with JWT auth, PostgreSQL and a job queue. The classic web surface: static analysis, dependency scanning and scanning of the running service all apply.
- **A React front end** with a large npm dependency tree. Much of the code we ship there was written by someone else.
- **An agent service** with about a hundred tools. It reads text we do not control, such as job postings and CVs, and its write tools wait for the user's confirmation. Prompt injection and tool abuse are its main risks.
- **A desktop companion app** with a local API and an MCP server. Web pages it reads for the user are another path for injection.
- **Agent skills and prompts** kept in the repository and read by coding agents. A third-party skill is code we did not write.
- **GitLab CI, Docker images and Helm charts on Kubernetes.** Images carry their own CVEs, so scanning the source is not enough.

We already run gosec through golangci-lint, which blocks merges on Go code, govulncheck for Go dependencies, and npm audit. The agent service has an input sanitizer, the [confirmation step on write tools](/insights/confirmation-gated-write-tools-and-idempotency/), a rate limiter and an audit log.

The gaps fell into five groups: secret scanning, container image scanning, scanning of the running app, adversarial tests of the agent, and checks on the CI configuration itself. Some existing checks also reported findings without being able to fail a build.

## How the eleven tools group

We sorted the tools into four layers:

- **AI-assisted code review:** Cloudflare's security-audit skill, Claude Code Security Review, Strix. An agent reads or attacks the code and finds logic bugs that rules miss. The cost is tokens and false positives.
- **Static rules and secrets:** Semgrep, Gitleaks, TruffleHog. Deterministic scanners that are cheap to run on every merge request. The cost is tuning.
- **Supply chain:** OSV-Scanner, zizmor, NVIDIA SkillSpector. Someone else's code, from dependencies to CI config to agent skills, scanned before you trust it.
- **Runtime and LLM probing:** Nuclei, garak. They attack the running system and the model, and catch misconfiguration and jailbreaks. They need a target stack, and garak spends tokens.

## Adopt

### Gitleaks: secret scanning before the commit and in CI

Gitleaks scans git history and files for secrets: API keys, tokens, private keys. Local environment files with real credentials stay out of our repository only because of an ignore rule. One wrong rule and they are in a commit. Once a key has been pushed, deleting it from the history is not enough, because any clone may already hold it. It has to be rotated. Blocking it before the commit is far cheaper.

- **One config, two entry points.** A `.gitleaks.toml` at the repository root, used by a pre-commit hook and by a CI job that blocks the merge.
- **Diff only on merge requests, full history once.** `gitleaks git` with `--log-opts` limited to the merge request's commits keeps the job fast. One full-history scan covers the past.
- **Noise to expect.** Vendored code, test fixtures, recorded HTTP cassettes and `.env.example` files. Allowlist those paths, and never switch a rule off globally.

One thing to know before adopting it: Gitleaks is now feature complete. Its README says future releases will be security patches only, and its author is shifting focus to a new project, Betterleaks. A gate needs stable rules more than new features, so we still adopt it. If the security patches ever stop, the config is one small file to replace.

Effort: about two hours.

### OSV-Scanner: one dependency scan for every lockfile and image

OSV-Scanner, from Google, checks lockfiles against the OSV.dev vulnerability database. One tool covers Go modules, npm and other ecosystems, and `osv-scanner scan image` covers the OS packages in a built container image.

Our dependencies are spread over several Go modules and npm projects: the API, the agent service, the desktop app, its shell and the front end. govulncheck covers Go only.

- **The gate.** Fail on HIGH and CRITICAL findings that have a fix. OSV-Scanner itself fails on any finding, so a short script reads its JSON output and applies that rule. Accepted risks go in an `osv-scanner.toml` file, each with a reason and an expiry date, so the escape hatch is explicit and reviewed.
- **govulncheck, kept for now.** Our first draft kept govulncheck because it checks whether the code actually calls the vulnerable function, and we assumed OSV-Scanner does not. It does: its call analysis for Go is on by default. So the two overlap more than we thought. We keep govulncheck for now and will compare the two on our code.
- **Images, not only source.** Base images bring their own OS packages and their own CVEs. The scan runs on the image the build produces.

Effort: about two hours.

### Semgrep: project rules as code

gosec knows general Go mistakes. It does not know our rules, and several of those exist only as prose in our engineering guide, enforced by code review. Semgrep rules are written in YAML, in patterns that look like the code they match, so each prose rule can become a check:

- **No `fmt.Sprintf` into raw SQL**, such as `db.Raw(fmt.Sprintf(...))`. A SQL injection guard.
- **No `err.Error()` in user-facing JSON responses.** Internal details stay out of the API.
- **No ORM import in the handler and use-case layers.** The layering stays as designed.
- **Data in a separate database is read through its helper**, never through the default connection.
- **No `math/rand` in packages that create tokens.** gosec's G404 check already flags most `math/rand` calls, but a `//nolint:gosec` comment silences every gosec check on its line, and our code has several. A ban on the import in those packages is narrower and harder to wave through.

One more rule covers the front end, which gosec cannot see: **no `dangerouslySetInnerHTML` in React without a sanitizer**, as an XSS guard.

Each rule ships with a test file holding one match and one non-match, run with `semgrep --test`. Rules are code, so they get tests.

Effort: about a day.

## Trial

### garak: test the agent's prompt-injection defenses

garak, from NVIDIA, is an LLM vulnerability scanner. It sends probes for prompt injection, jailbreaks and data leakage to a model or to any REST endpoint, and reports which ones got through.

For this product it is a high-value trial. The agent reads text we do not control and can call write tools. It has an input sanitizer and a confirmation step, but no test attacks them to show what gets through. garak would give us that evidence.

- **Target:** the chat endpoint on an isolated test stack, never production.
- **Model:** the cheapest model that passes our [qualification gates](/insights/how-to-qualify-an-llm-router-model/), so the probes stay cheap. That tests our own defenses more than the production model's resistance, which is what we want to learn first.
- **Schedule:** nightly, not on every merge request. It is slow and costs tokens.
- **Follow-up:** every injection that works becomes a regression test against a stub model, which costs no tokens in CI. garak finds it once, and the test guards it from then on. It is the same split as [record and replay for LLM tests](/insights/record-and-replay-for-llm-tests/): the costly live run finds the case, and a fixed fixture keeps testing it.

Effort: about a day, plus a token budget.

### Claude Code Security Review: AI review on the merge request

Claude Code Security Review, from Anthropic, is a GitHub Action. It reviews a pull request's changed files with Claude, posts findings as comments and filters out low-impact categories. Rules miss logic bugs such as a missing authorization check, access to another user's records by ID (IDOR), or a way around plan limits. A reviewer that reads the code can find them.

Our CI is GitLab, so the action does not run as published. The repository also ships its review prompt as a Claude Code project command, `security-review.md`. The plan is a GitLab job that runs Claude Code headless with that command on the merge request's diff, and posts the result as a note through the GitLab API.

- **Scope:** only merge requests that touch handlers, middleware, the agent service, or the desktop app's local API and MCP server. Tokens go where authorization lives.
- **Trusted changes only.** The README warns that the action is not hardened against prompt injection and should only review trusted pull requests. A diff can carry instructions aimed at the reviewer, so the job will run only on merge requests from our own team.
- **Gate:** advisory. LLM findings inform, and deterministic tools block.

Effort: about half a day to adapt.

### Cloudflare's security-audit skill: a deep audit before a release

Cloudflare's security-audit skill is an MIT-licensed skill that turns a coding agent into a security auditor. It works in phases, and the agent that checks a finding is never the agent that found it. That check should keep the noise low. It also means a full run starts many agent sessions, so we expect it to be costly.

That fits a deep audit before a release, not every commit. The skill writes its report outside the repository. We will file a dated summary of each run with our private audit records, and turn the findings into tickets.

### Nuclei: scan what is running

Nuclei, from ProjectDiscovery, runs YAML templates against live services to find exposed admin paths, misconfigured headers, known CVEs and the technologies in use.

- **Target:** the local test stack in CI. Production only on an explicit, scheduled decision by the owner.
- **Templates:** the misconfiguration, exposures, exposed-panels and technologies sets, plus one custom template that asserts our security headers. No templates tagged intrusive, and no fuzzing templates.

The effort is low. The risk is that it is an active scan: pointed at the wrong host, it is an attack.

### NVIDIA SkillSpector: scan agent skills before installing them

SkillSpector scans agent skills for Claude Code, Codex and MCP before you install them. It takes a Git URL, an archive, a directory or a single `SKILL.md`, looks for malicious patterns, prompt injection and supply-chain risks, and returns a risk score with a verdict: safe, caution or do not install.

We keep skills and prompts in the repository and install third-party ones. A skill is a set of instructions an agent follows with your permissions, so one line in it can send data out. SkillSpector becomes a review step before we adopt any third-party skill. It runs on demand, so it does not need to be a CI job.

### Strix: AI pentesting, later

Strix runs AI agents that attack a running app and confirm what they find with proofs of concept. It needs Docker and an LLM provider.

It overlaps with Nuclei, garak and the AI review, but goes deeper: it can chain findings into multi-step attacks, the kind a single-request check misses. Of the eleven, we expect it to cost the most to set up and run. We will try it after the cheaper layers are in place, against an isolated stack only.

## Skip

### TruffleHog: one history audit, then Gitleaks

TruffleHog overlaps with Gitleaks. Its distinctive feature is verification: it checks whether a key it found still works by calling the provider's API with it. That is worth doing once, on the full history, to learn whether any old leak is still live. Because verification calls real provider APIs, run it deliberately. As the everyday gate, Gitleaks is enough.

### zizmor: it audits GitHub Actions, and our CI is GitLab

zizmor finds security problems in GitHub Actions workflows and actions, and also audits Dependabot and pre-commit configs. We have no workflows and no Dependabot config, so most of what it checks does not exist here. We will revisit it if our releases move to GitHub Actions, or once a pre-commit config for the Gitleaks hook exists.

The risk it targets applies to any CI, because the pipeline is a supply-chain entry point. Two fixes apply to GitLab today:

- **Pin CI images by digest.** A tag like `alpine:latest` can change between two runs.
- **Avoid `go run module@latest` in CI.** With a version suffix, Go ignores the project's `go.mod` and vendor directory and fetches whatever is newest. Pin the tool with a `tool` directive in `go.mod` (Go 1.24 and later) and run it with `go tool`.

## The rollout order

- **First, about a day:** Gitleaks as a pre-commit hook and a blocking CI job. OSV-Scanner on every lockfile and on the built image, blocking on fixable HIGH and CRITICAL findings. The existing dependency checks made to block.
- **Second, one to two days:** Semgrep with the six rules above, locally and in CI. SkillSpector as a documented review step.
- **Third, two to three days plus tokens:** garak and Nuclei nightly against the test stack, AI review on merge requests as advice, and the Cloudflare skill before releases.
- **Later:** Strix, and the one-off TruffleHog history audit.

The order follows risk closed per hour of work. A blocking check for secrets and one for known-vulnerable dependencies take hours, not days, and each closes a whole class of mistake.

## A tool counts only once it has fired on purpose

Installing a scanner does not mean it runs, or that it would catch anything. We have [built things that were never wired](/insights/built-but-never-wired/) before. So each tool counts as adopted only after a test makes it fire:

- **Gitleaks:** commit a fake key on a throwaway branch. The CI job must fail.
- **OSV-Scanner:** pin a known-vulnerable version in a test lockfile. The job must fail.
- **Semgrep:** each rule's match and non-match test passes `semgrep --test`.
- **garak:** a known-bad probe against a deliberately weakened stub shows up in the report.
- **Nuclei:** remove one security header in a local build. The custom template must report it.

Every gate will be listed in one test plan, so there is one place to see them all.

## Security tools can cause incidents too

- **Point active scanners at test stacks by default.** Nuclei, Strix and garak attack what they target. Production takes an explicit decision, never a default.
- **Cap the token spend.** garak, Strix and AI reviews get a budget per run and the cheapest model that works, and their cost is tracked like any other LLM call, which is [harder than it looks](/insights/llm-cost-tracking-wrong-both-directions/).
- **Block only on findings you would fix.** Start with high-confidence, fixable findings, and make everything else advice with an owner. A gate people learn to bypass is worse than no gate.
- **Keep scanner reports private.** Unless redacted, Gitleaks and TruffleHog output contains the secrets they found. Run Gitleaks with `--redact`, and never publish either report as a CI artifact.
- **Check the link before you install.** Two of the eleven tools reached us as shortened links. Security tools run with broad access, so install from the canonical repository.

## Checklist

- Do you scan for secrets before the commit, and again in CI?
- Does every lockfile you ship, and every image you build, get a dependency scan that can fail the build?
- Are your project's security rules written as code, or only as prose?
- Does your agent's prompt-injection defense have a test that attacks it?
- Do your active scanners point at a test stack unless someone decides otherwise?
- Has each gate failed once, on purpose?
- Do you scan third-party agent skills before installing them?

## The eleven repositories

- [Gitleaks](https://github.com/gitleaks/gitleaks)
- [OSV-Scanner](https://github.com/google/osv-scanner)
- [Semgrep](https://github.com/semgrep/semgrep)
- [garak](https://github.com/NVIDIA/garak)
- [Claude Code Security Review](https://github.com/anthropics/claude-code-security-review)
- [Cloudflare security-audit skill](https://github.com/cloudflare/security-audit-skill)
- [Nuclei](https://github.com/projectdiscovery/nuclei)
- [NVIDIA SkillSpector](https://github.com/NVIDIA/SkillSpector)
- [Strix](https://github.com/usestrix/strix)
- [TruffleHog](https://github.com/trufflesecurity/trufflehog)
- [zizmor](https://github.com/zizmorcore/zizmor)

If you want a second look at your pipeline's security gates or your agent's injection defenses before they meet production, [get in touch](/contact/).
