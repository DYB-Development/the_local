## [Unreleased]

- A provider gem ships **no Ruby and no guide**. Its committed
  `the_local/agents/<gem>-{info,install,develop}.md` are authored by
  `rake the_local:author`, which runs the_local's creators against the gem's
  current code — one local at a time — and writes each from it. The creators live
  inside the_local and are never installed into a host.
- A provider now declares its public interface in **`the_local/interface.yml`**:
  the `scope` line, the entry points assigned to `install` and `develop`, and the
  `sources` that define them. `rake the_local:author` refuses to run without it.
  Deciding what is public is a human's call, made once and committed, instead of a
  judgment the creators re-make on every run.
- The three locals **never overlap**: `install` hooks the gem into a consumer,
  `develop` covers using it from consuming code, `info` is the read-only catchall.
  One entry point belongs to exactly one local.
- `rake the_local:check` enforces that contract in both directions — every declared
  entry point documented by its own local, nothing undeclared documented anywhere,
  nothing documented by a local it wasn't declared for — on top of the existing
  front-matter and section checks.
- Locals are **black-box docs**: they carry the gem's public interface (how, when,
  where, what commands) and never reference its internals or send a reader into the
  provider's source. Their facts come from the code, not from a README that could
  be stale.
- The deterministic renderer is removed — no `the_local/guide.md`, no
  `rake the_local:build`, no `ProviderBuild`/`Builder`. Install is unchanged: it
  copies committed files off disk verbatim.
- `the_local:provider` wires the dependency and the Rakefile hook only; it no
  longer scaffolds a guide. `the_local` is its own first provider, with a committed
  manifest its locals are checked against.

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
