# Becoming a provider

`the_local` has two sides. The **consuming-app** side (`bundle exec the_local
install`, or `bin/rails g the_local:install` in a Rails app) installs the locals
of a project's direct dependencies into `.claude/agents/` — by reading each
dependency's committed `.md` straight from its gem path on disk. This document
covers the **provider** side: how a gem contributes those locals.

A provider commits a manifest, `the_local/interface.yml`, and the three locals
authored from it at `the_local/agents/<gem>-{info,install,develop}.md`. It ships
no Ruby of its own.

## Declare the interface, author the locals

**The manifest is the one judgment call, and a human makes it.** It names the
gem's public entry points and assigns each to the local that owns it:

```yaml
scope: <one line: the user-visible work this gem owns>

install:
  - bin/rails g demo:install

develop:
  - Demo.emit

sources:
  - lib/generators/demo/install_generator.rb
  - lib/demo/emitter.rb
```

`rake the_local:author` then runs the_local's creators against that declaration
and the files under `sources:`, writing the three locals. The creators no longer
guess at what matters — they document what you declared, verified against the
code as it is now rather than against a README that may be stale.

`rake the_local:check` enforces the contract in both directions: every declared
entry point is documented by its own local, nothing undeclared appears anywhere,
and nothing appears in a local it wasn't declared for.

## What each local is for

The three never overlap. One entry point, one local.

| Local | Purpose | Tools |
|---|---|---|
| **`install`** | Hooking the gem into a consumer — the exact setup steps. | `Bash, Read, Edit` |
| **`develop`** | Using the gem — calling its entry points from consuming code. | `Read, Write, Edit, Grep` |
| **`info`** | Read-only catchall: what the gem is, and which of the other two to reach for. | `Read` |

They are step-by-step implementation guides, kept as short as the job allows.
Where a step takes a real decision, the local surfaces the question to the
developer rather than choosing. A local never sends its reader into the
provider's source.

## The committed files are the contract

The host install **reads them straight from your gem's path on disk and copies
them verbatim** into `.claude/agents/` — no provider code is loaded in the host.
If they aren't committed (and, for a packaged gem, in the gemspec's `files`), the
gem contributes nothing.

## Adopting it

1. **Wire the tooling.** In a Rails-engine gem, run `bin/rails g the_local:provider`;
   it adds `gem "the_local"` to the Gemfile and `require "the_local/rake"` to the
   Rakefile. A plain gem does those two edits by hand.
2. **Declare the interface.** Write `the_local/interface.yml`. Authoring refuses
   to run without it.
3. **Author.** Run `rake the_local:author`.
4. **Check and commit.** Fix what `rake the_local:check` reports, then
   `git add the_local`. For a packaged gem, make sure `the_local/**/*` is in the
   gemspec's `files`.
5. **Keep it current.** When the gem's public interface changes, update the
   manifest and re-author. An internal-only change needs nothing.

`the_local` is its own first provider and uses exactly this wiring;
`test/the_local/dogfood_test.rb` asserts its committed locals match its manifest.
