## [Unreleased]

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
