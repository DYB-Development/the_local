## [Unreleased]

- A provider gem ships **no Ruby and no guide**. Its committed
  `the_local/agents/<gem>-{info,install,develop}.md` are authored by the
  **creator agents** — `the_local-author-info` / `-install` / `-develop` — which
  read the gem's current code and write each local from it. `the_local-author-review`
  flags when a change moved the gem's public surface and made the locals stale.
- Locals are **black-box docs**: they carry the gem's public interface (how, when,
  where, what commands) and never reference its internals, and their facts come
  from the code, not from a README or guide that could be stale.
- The deterministic renderer is removed — no `the_local/guide.md`, no
  `rake the_local:build`, no `Interface`/`ProviderBuild`/`Builder`.
  `rake the_local:check` validates that a committed trio holds the fixed format
  (front-matter keys + sections). Install is unchanged: it copies committed files
  off disk verbatim.
- `the_local:provider` wires the dependency and the Rakefile hook only; it no
  longer scaffolds a guide. `the_local` is its own first provider, its trio
  authored to the black-box format.

## [0.3.0] - 2026-07-01

- Installing no longer writes a `develop_process_rules.md` into host apps. The
  `ProcessDocWriter`/`ProcessRules` machinery and its bundled doc are removed, so
  `Sync`/`refresh` only install locals and the delegation trigger — a gem's
  process conventions belong in its own guide, not propagated as a shared file.
- A gem no longer installs its own locals into its own repo: `refresh` excludes
  the gem being run from the direct-dependency set, so a provider working on
  itself doesn't copy its locals back into `.claude/agents/`.

## [0.2.0] - 2026-06-20

- `rake the_local:build` now refuses a guide that still holds line-leading
  `TODO:` placeholders or is missing a canonical section, so a provider can't
  ship a local that hasn't surfaced its gem's real interface (and would send
  host agents digging into source).
- Guides follow one canonical shape across every provider — **Interface**
  (exact signatures), **Recipe** (copy-paste common task), **Install**,
  **Conventions** — enforced at build and enumerated in the develop local's
  authoring spec, so the consuming agent meets the same structure everywhere.
  the_local's own guide models it with the `register` / `c.agent` signatures.
- Scaffolded facet bodies (`info` / `install` / worker) are now a standard role
  that defers to the guide and forbids reading source, identical across gems —
  so the consuming agent gets consistent behavior, with gem-specifics in the
  guide rather than hand-written per-provider bodies.
- Install instructions and the provider generator now use the published
  `gem "the_local"` instead of a `github:` git source, since the gem is on
  RubyGems.

## [0.1.0] - 2026-06-02

- Initial release.
- `TheLocal.register` API for gems and apps to contribute Claude Code locals,
  behind a soft `require "the_local"` guard so providers work standalone.
- Provider build model: `TheLocal::Builder` + `rake the_local:build` render each
  agent to a committed `.md`; the installer copies those files verbatim.
- `the_local:install` and `the_local:provider` Rails generators, plus a
  rake-only `the_local:refresh` to re-sync a host after bundle changes.
- Direct-dependency install scope and a registry-generated delegation trigger
  written into the host's `CLAUDE.md`/`AGENTS.md`.
- the_local dogfoods itself as a provider (`the_local-info`/`-install`/`-develop`)
  and propagates a canonical develop-process doc into every host.
