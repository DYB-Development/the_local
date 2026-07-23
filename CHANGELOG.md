## [Unreleased]

- A provider gem now ships **no Ruby**. Instead of a `TheLocal.register` block,
  a `Reference` loader, and a companion, a provider writes one file —
  `the_local/guide.md` at the gem root — and `the_local` renders the standard
  `info` / `install` / `develop` locals from it. The gem name comes from the
  gemspec. `TheLocal.register` and `Collector` are removed.
- The committed locals move out of the require path to `the_local/agents/` at the
  gem root. Install still discovers a provider's older `lib/**/the_local/agents/`
  layout as a fallback until it is rebuilt.
- `the_local:provider` scaffolds only `the_local/guide.md` and the Rakefile hook;
  it no longer writes a companion, a reference loader, an entrypoint `require`, or
  takes a gem-name argument. `the_local` is its own first guide-based provider.

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
