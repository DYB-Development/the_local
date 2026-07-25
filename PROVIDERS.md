# Becoming a provider

`the_local` has two sides. The **consuming-app** side (`bundle exec the_local
install`, or `bin/rails g the_local:install` in a Rails app) installs the locals
of a project's direct dependencies into `.claude/agents/` — by reading each
dependency's committed `.md` straight from its gem path on disk. This document
covers the **provider** side: how a gem contributes those locals.

A provider commits **three files** — `the_local/agents/<gem>-{info,install,develop}.md`
at its gem root — and ships no Ruby of its own. Those files are authored by
`rake the_local:author`, which reads the gem's current code and writes the locals
from it.

## Author from code, commit the `.md`

The committed trio is the entire contract. The host install **reads those files
straight from your gem's path on disk and copies them verbatim** into
`.claude/agents/` — no provider code is loaded in the host. If the files aren't
committed (and, for a packaged gem, in the gemspec's `files`), the gem contributes
nothing; if they are, it contributes everything, with no install-time wiring.

The locals are **black-box docs**: they carry your gem's public interface — how to
use it, when, where, and what commands to run — and never reference its internals.
Someone reads a local the way they read API docs for a service whose source they
can't see. The creators derive every fact from the **code as it is now**, not from
a README or any document that could be stale.

## The common command interface

Every provider exposes the same three locals, so a host agent always finds the
same shape no matter which gem it's delegating to:

| Facet | Purpose | Tools |
|---|---|---|
| **`info`** | Read-only. Explains what the gem offers. Makes no changes. | `Read` |
| **`install`** | Adds the gem to a host and sets it up — the exact, gem-specific steps. | `Bash, Read, Edit` |
| **`develop`** | The proactive domain worker the host routes real work to. | `Read, Write, Edit, Grep` |

## Adopting it

1. **Wire the tooling.** In a Rails-engine gem, run `bin/rails g the_local:provider`;
   it adds `gem "the_local"` to the Gemfile and `require "the_local/rake"` to the
   Rakefile (which exposes `rake the_local:author` and `rake the_local:check`). A
   plain gem does those two edits by hand.
2. **Author the trio.** Run `rake the_local:author`. It runs the_local's creators
   against the gem's current code — one facet at a time — and writes the three
   files into `the_local/agents/`. The creators live inside the_local; nothing is
   installed into the gem.
3. **Check and commit.** Read the written trio and fix anything the author got
   wrong, run `rake the_local:check` to confirm the format, then `git add the_local`.
   For a packaged gem, make sure `the_local/**/*` is in the gemspec's `files`.
4. **Keep them current.** After a change to the gem, if you changed its public
   interface, re-run `rake the_local:author` and commit the refresh. An
   internal-only change needs nothing — the black-box locals don't describe
   internals.

`the_local` is its own first provider and uses exactly this wiring;
`test/the_local/dogfood_test.rb` asserts its committed trio holds the format.
