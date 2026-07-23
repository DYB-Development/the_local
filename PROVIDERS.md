# Becoming a provider

`the_local` has two sides. The **consuming-app** side (`bundle exec the_local
install`, or `bin/rails g the_local:install` in a Rails app) installs the locals
of a project's direct dependencies into `.claude/agents/` — by reading each
dependency's committed `.md` straight from its gem path on disk. This document
covers the **provider** side: how a gem contributes those locals.

A provider writes **one file** — `the_local/guide.md` at its gem root — and ships
no Ruby of its own. `the_local` reads the gem name from the gemspec and renders
the standard locals from the guide.

## Build at home, ship the committed `.md`

`the_local/guide.md` is the single source of truth. The provider **renders it to
committed `.md` files** with the gem-side `the_local:build` task and commits those
files to its own repo; the host install then **reads them straight from your
gem's path on disk and copies them verbatim** into `.claude/agents/`. No provider
code is loaded in the host — the committed, shipped `.md` is the entire contract.
If those files aren't committed (and, for a packaged gem, in the gemspec's
`files`), the gem contributes nothing; if they are, it contributes everything,
with no install-time wiring.

So the rendered output depends only on the provider gem version — every app that
installs the same version gets a byte-identical local. The committed `.md` is a
reviewable build artifact: it lands in the gem's own PR. Keep it in sync by
re-running `the_local:build` and committing the result whenever you change the
guide.

## The common command interface

`the_local` exists to give every gem the **same command interface to apps**, so
a host agent always finds the same shape no matter which gem it's delegating to.
Every provider exposes three locals, rendered from the one guide:

| Facet | Purpose | Tools |
|---|---|---|
| **`info`** | Read-only. Explains what the gem offers — its API and conventions. Makes no changes. | `Read` |
| **`install`** | Adds the gem to a host and sets it up **correctly** — the exact, gem-specific steps. | `Bash, Read, Edit` |
| **`develop`** | The proactive domain worker the host routes real work to. | `Read, Write, Edit, Grep` |

Each local embeds the guide verbatim as its knowledge — the guide is the single
source of truth, so the locals never drift from the docs.

## Adopting it — Rails-engine gems (generator)

If the gem has Rails available in development (e.g. a mountable engine), scaffold
the wiring with the generator:

```bash
bin/rails g the_local:provider
```

It creates and wires up just two things — the gem name comes from the gemspec:

```
the_local/guide.md   # the knowledge, with TODO markers to fill in
Rakefile             # + require "the_local/rake"  (rake the_local:build)
```

Then **fill in the guide** — this is the real work the generator can't do. Write
`the_local/guide.md` as the complete user-facing API. The bar is that a host
agent can do your gem's work *from the guide alone, without opening your source*:
surface the literal interface (exact signatures — arguments, required vs
optional, return) and a complete copy-paste recipe for the common task, not prose
about them. Its **Install** section must be the exact, correct steps for *this*
gem (for an engine: add the gem → `bundle install` → install + run migrations →
wire concerns / initializers), not a generic placeholder. Replace every `TODO:` —
`rake the_local:build` refuses a guide that keeps one.

Then **build and commit the locals**:

```bash
rake the_local:build
git add the_local
```

Rebuild whenever the guide changes — the host copies these bytes verbatim, so a
stale commit ships stale locals. Add a **drift test** asserting each committed
file equals the rendered build, so a forgotten rebuild fails CI. See
`test/the_local/dogfood_test.rb` — the_local is its own provider and uses exactly
this wiring.

## Adopting it — non-Rails gems (manual)

A plain gem has no `bin/rails`, so do the same two things by hand. `the_local` is
itself a non-Rails provider built this way — mirror its own wiring (`the_local/`
and the `Rakefile`):

1. Write `the_local/guide.md` — the knowledge, the single source of truth (the
   four sections: Interface, Recipe, Install, Conventions).
2. Add `require "the_local/rake"` to the `Rakefile`, and `gem "the_local"` to the
   Gemfile (a build-time tool, dev/test).
3. Build, commit, and **ship** the rendered locals — `rake the_local:build &&
   git add the_local` — and, for a packaged gem, make sure `the_local/**/*` is in
   the gemspec's `files`. These committed bytes are the whole contract — what the
   host reads from disk; rebuild and recommit on every change.
