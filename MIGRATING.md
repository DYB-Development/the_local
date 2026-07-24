# Migrating a provider gem to the guide-based model

This is a **deterministic runbook** for converting one provider gem from the old
`TheLocal.register` layout to the new guide-based one (the_local ≥ the version on
`main` after PR #72). Follow it top to bottom, **one gem at a time**. Every step
ends with a **VERIFY** gate; if a gate's actual output does not match the stated
expectation, **STOP** and resolve it before continuing — do not proceed on a
failed gate.

Do not batch gems. Do not skip verification. Do not invent steps.

---

## Two entry points

**Already on the guide model** (the gem has `the_local/guide.md` and no
`lib/**/the_local.rb`)? Its locals are rendering from the generic template and
the host agent is not routing to them. Branch first, update the engine, then skip
to **Step 6 — Author the locals' metadata** and run Steps 7-9:

```bash
git checkout main && git pull --ff-only
git checkout -b chore/author-the-locals
bundle update the_local
bundle exec ruby -e 'require "the_local/guide"; puts "ok"'   # => ok
```

If that prints `LoadError` instead of `ok`, the bundled the_local predates
authored metadata — **STOP** and point the Gemfile at the_local `main`. Step 6's
VERIFY needs it.

**Still on the register model** (the gem has `lib/<path>/the_local.rb`)? Start at
the Preconditions and run the whole runbook top to bottom.

Either way you finish at the same place: an authored guide, a rebuilt trio, a
green drift test.

---

## What the migration changes

| Old (register-based) | New (guide-based) |
|---|---|
| `lib/<path>/the_local.rb` — `Companion.register!` block | *(deleted)* |
| `lib/<path>/reference.rb` — `Reference` loader | *(deleted)* |
| `lib/<path>/reference/guide.md` — the knowledge | **moved to** `the_local/guide.md` (gem root) |
| `c.agent description:`/`body:`/`scope:` — the authored metadata | **re-authored as** front matter in `the_local/guide.md` (Step 6) |
| `lib/<path>/the_local/agents/*.md` — committed locals | **rebuilt at** `the_local/agents/*.md` (gem root) |
| entrypoint `require`/`require_relative "<path>/the_local"` | *(deleted)* |
| Rakefile `require "<path>/the_local"` before `require "the_local/rake"` | *(deleted; keep the `the_local/rake` line)* |
| `test/**/companion_test.rb`, `test/**/reference_test.rb` | *(deleted; replaced by a drift test)* |

The gem carries **no Ruby** for the_local afterward — one `the_local/guide.md`
in, the rendered `the_local/agents/*.md` out.

`<path>` is the gem's lib subpath: `keystone_ui` for a plain gem,
`event_engine/subscribers` for a hyphenated gem. The commands below discover it;
never hardcode it.

---

## Preconditions (run once, at the gem root)

```bash
cd <the gem's root>                       # the directory containing *.gemspec
git checkout main && git pull --ff-only   # start clean
git checkout -b chore/the_local-guide-migration
```

**VERIFY** you are in a provider gem on a fresh branch:

```bash
ls *.gemspec                              # exactly one gemspec
git branch --show-current                 # chore/the_local-guide-migration
find lib -path '*/reference/guide.md'     # exactly one path — the old guide
```

- If there is **no** `*/reference/guide.md`, this gem is not an old-layout
  provider (or already migrated). **STOP.**
- If there are **two or more**, **STOP** and report — the runbook assumes one.

Update to the new the_local so `rake the_local:build` uses the guide-based engine:

```bash
bundle update the_local
```

**VERIFY** the new engine is present:

```bash
bundle exec ruby -e 'require "the_local/provider_build"; puts "ok"'   # => ok
```

If this prints an error instead of `ok`, the bundled the_local is too old.
**STOP** and fix the dependency (point the Gemfile at the_local `main`).

---

## Step 1 — Capture the current facts

```bash
GUIDE=$(find lib -path '*/reference/guide.md')          # lib/<path>/reference/guide.md
LIBPATH=$(dirname "$(dirname "$GUIDE")")                 # lib/<path>
GEM=$(basename ./*.gemspec .gemspec)                     # the gem name
echo "GUIDE=$GUIDE  LIBPATH=$LIBPATH  GEM=$GEM"
echo "-- committed locals today --"; ls "$LIBPATH/the_local/agents/"
```

**VERIFY** the three variables are non-empty and `$LIBPATH/the_local/agents/`
lists the current `.md` files.

**DECISION — worker facet.** Look at the listed filenames:

- If they are `<gem>-info.md`, `<gem>-install.md`, `<gem>-develop.md` → normal
  case, continue.
- If you see `<gem>-operate.md` (a CLI gem's worker) → the new model renders
  **`develop`**, not `operate`. The migration **renames the worker**: the old
  `operate` local disappears and a `develop` local replaces it. This is a
  deliberate, visible change. Note it for the PR description and continue — the
  old `-operate.md` is deleted in Step 3 and not rebuilt.

**GATE — is the guide actually finished?**

```bash
grep -nE '^[[:space:]]*TODO:' "$GUIDE" || echo "no TODO markers"
grep -cE '^### (Interface|Recipe|Install|Conventions)' "$GUIDE"   # expect 4
```

- If there are **any** line-leading `TODO:` markers, or fewer than **4**
  canonical sections, this gem's guide was never finished. The build gate will
  reject it. **STOP.** This is *authoring* work (write the gem's real interface),
  not mechanical migration — do it as a separate, deliberate task, then return.

---

## Step 2 — Move the guide to the gem root

```bash
mkdir -p the_local
git mv "$GUIDE" the_local/guide.md
```

**VERIFY**:

```bash
test -f the_local/guide.md && echo "moved"        # => moved
test -e "$GUIDE" && echo "STILL THERE — STOP" || echo "old path gone"
```

Expect `moved` and `old path gone`.

---

## Step 3 — Delete the old Ruby and rendered locals

Delete the companion Ruby **first** — that way the require-cleanup in Step 4 sees
only the two lines that actually need removing, not the soft guard *inside* the
companion.

```bash
git rm "$LIBPATH/the_local.rb" "$LIBPATH/reference.rb"
git rm -r "$LIBPATH/the_local/agents"
# reference/ dir held only the moved guide; remove it if now empty:
rmdir "$LIBPATH/reference" 2>/dev/null || true
# Delete the old drift/registration tests if the gem has them:
find test -name companion_test.rb -o -name reference_test.rb 2>/dev/null | xargs -r git rm
```

**VERIFY** the old artifacts are gone:

```bash
ls "$LIBPATH/the_local.rb" "$LIBPATH/reference.rb" 2>/dev/null \
  && echo "OLD RUBY REMAINS — STOP" || echo "old ruby gone"
find "$LIBPATH" -path '*the_local/agents*' -name '*.md' | grep . \
  && echo "OLD AGENTS REMAIN — STOP" || echo "old agents gone"
```

Expect `old ruby gone` and `old agents gone`.

---

## Step 4 — Remove the companion require from the entrypoint and Rakefile

With the companion file already deleted, the gem still *requires* it from two
places (its entrypoint and its Rakefile). Both requires must go. **Keep**
`require "the_local/rake"` in the Rakefile.

```bash
# Every line here is a companion require to delete (rake/builder are excluded):
grep -rn 'the_local"' lib Rakefile | grep -vE 'the_local/(rake|builder)"'
```

Edit each file the command prints, deleting the line that requires the companion
(`require "<path>/the_local"` or `require_relative "<path>/the_local"`), plus any
now-orphaned comment directly above it. Do **not** delete `require "the_local/rake"`.

**VERIFY** no companion require remains, and the rake require survives:

```bash
grep -rn 'the_local"' lib Rakefile | grep -vE 'the_local/(rake|builder)"' \
  && echo "COMPANION REQUIRE REMAINS — STOP" || echo "entrypoint clean"
grep -q 'require "the_local/rake"' Rakefile && echo "rake require kept"
```

Expect `entrypoint clean` and `rake require kept`.

---

## Step 5 — Make the gemspec ship `the_local/`

The committed locals now live at the gem root, so the gemspec must include them.
Check how this gem selects files:

```bash
grep -n 'spec.files' ./*.gemspec
```

- **`git ls-files`** based (ships every tracked file) → **no edit needed.** The
  root `the_local/` ships automatically. Skip to VERIFY.
- **`Dir[...]` / `Dir.chdir { Dir[...] }`** based (an explicit allowlist, e.g.
  `Dir["lib/**/*", "app/**/*"]` or `Dir["{app,config,db,lib}/**/*", ...]`) → the
  root `the_local/` is **not** matched. Edit the glob to add `"the_local/**/*"`
  to the file list.

Example edit (keystone_ui-style):

```ruby
# before
spec.files = Dir["lib/**/*", "app/**/*"]
# after
spec.files = Dir["lib/**/*", "app/**/*", "the_local/**/*"]
```

**VERIFY** the gemspec now includes the guide (once it exists on disk it must be
selectable). After Step 7 builds the agents, this is re-checked; for now just
confirm the edit is syntactically valid:

```bash
ruby -e 'Gem::Specification.load(Dir["*.gemspec"].first)' && echo "gemspec loads"
```

Expect `gemspec loads`. If it errors, **STOP** and fix the syntax.

---

## Step 6 — Author the locals' metadata

The register block carried each local's `description` and `body` plus the
provider's `scope`. **Moving the guide does not carry them over.** Without this
step every local renders from a generic template — `"Use PROACTIVELY for any
<gem> work"` — which the host agent only matches if the user already named the
gem, i.e. exactly when no local was needed. The local never fires and the host
answers generically. `rake the_local:build` refuses a guide whose scope is
unauthored, so this step is not optional.

**Recover the old wording first.** If this gem had a register block, git history
holds text that was already authored against the real gem — recover and improve
it rather than inventing new wording:

```bash
git log --all --oneline -- "$LIBPATH/the_local.rb" | tail -1   # the commit that added it
git show <that-commit>:"$LIBPATH/the_local.rb"                 # scope, descriptions, bodies
```

For a gem that never had one, investigate before writing: its gemspec, README,
public API, tests, and real call sites in consuming projects.

Add front matter at the very top of `the_local/guide.md`, above the `## Title`
line:

```yaml
---
scope: <domain> — <the tasks this gem owns>
locals:
  info:
    description: >-
      Use to learn what <gem> offers — <its actual subjects>.
    body: >-
      What this local answers from, and that it changes nothing.
  install:
    description: >-
      Use to add <gem> to a project and set it up correctly.
    body: >-
      The steps it follows, and what it must NOT do (e.g. companion gems).
  develop:
    description: >-
      Use PROACTIVELY for <the real tasks, named> — MUST BE USED instead of
      <the thing people hand-roll>.
    body: >-
      The ceremony that must never be skipped, and what is out of scope.
---
```

Each field answers one question:

| Field | Question | Why it matters |
|---|---|---|
| `scope` | What user-visible tasks does this gem own? | The one line the host's `CLAUDE.md` delegation rule names. |
| `description` | What would someone actually ask for? | **The routing surface.** The host agent matches a task against it to decide whether to delegate. |
| `body` | What ceremony must never be skipped? What is out of scope? | A standing instruction. Facts buried at line 90 of the reference are not instructions. |

You author only these. The renderer owns which locals exist, their `tools`, the
front-matter keys and their order, and the file's structure — do not add a fourth
local, do not set `tools`, do not invent keys.

**GATE — is the `develop` description actually routable?** Read it and answer:
*would this match a request that never says the gem's name?*

- `"Use PROACTIVELY for any event_engine work"` → **broken.** Names only the gem.
- `"Use PROACTIVELY for any EventEngine work — defining events, choosing
  process_type, emitting, and keeping the committed schema in sync"` → routable.
  Names the tasks.

If yours reads like the first, rewrite it before continuing. **This is the whole
point of the step**; a guide that passes the build gate but fails this question
ships a local nobody reaches.

**VERIFY** the front matter parses and is complete:

```bash
bundle exec ruby -r the_local/guide -e '
  g = TheLocal::Guide.new(File.read("the_local/guide.md"))
  abort "UNAUTHORED SCOPE — STOP" if g.scope.to_s.strip.empty?
  %w[info install develop].each do |n|
    abort "#{n}: no description — STOP" if g.local(n)["description"].to_s.strip.empty?
  end
  abort "TODO markers remain — STOP" if g.scope.include?("TODO")
  puts "authored"
'
```

Expect `authored`. Anything else — fix it before Step 7.

---

## Step 7 — Build the committed locals

```bash
bundle exec rake the_local:build
```

**VERIFY** exactly the standard trio is rendered at the root, and the old worker
name is gone:

```bash
ls the_local/agents/                          # <gem>-info.md <gem>-install.md <gem>-develop.md
ls the_local/agents/*-operate.md 2>/dev/null && echo "OPERATE STILL PRESENT — STOP" || echo "no operate file"
```

- Expect three files: `<gem>-info.md`, `<gem>-install.md`, `<gem>-develop.md`.
- If `rake the_local:build` **fails** with `incomplete guide(s)` → the guide has
  a `TODO:` or is missing a section. Return to Step 1's GATE. **STOP.**

**VERIFY the build is idempotent** (a second build produces no diff):

```bash
bundle exec rake the_local:build
git status --short the_local/agents/          # expect NO output
```

Any output here means the build is non-deterministic — **STOP** and report.

---

## Step 8 — Add a drift test

Create a test that fails if a future edit to the guide isn't rebuilt. Adapt the
path and test framework to the gem (Minitest shown; the gem root is the dir with
the gemspec).

```ruby
# test/the_local_drift_test.rb   (or spec/the_local_drift_spec.rb)
# frozen_string_literal: true

require "test_helper"
require "the_local/provider_build"

class TheLocalDriftTest < Minitest::Test
  def test_committed_agents_match_the_rendered_build
    gem_root = File.expand_path("..", __dir__)
    TheLocal::ProviderBuild.new(gem_root).agents.each do |agent|
      assert_equal agent.to_markdown, File.read(agent.source_path)
    end
  end
end
```

Adjust `File.expand_path("..", __dir__)` so it resolves to the gem root from the
test file's location (one `..` per directory level of the test file below root).

**VERIFY** the gem's whole suite passes:

```bash
bundle exec rake test        # or: bundle exec rspec
```

Expect **0 failures, 0 errors**. If the drift test fails, the committed agents
don't match the build — re-run Step 7. If other tests fail because they
referenced the deleted companion/reference, delete or rewrite those assertions
(they tested removed code).

---

## Step 9 — Lint, review, commit, PR

```bash
bundle exec rubocop            # if the gem uses it — expect clean
git status --short             # review every add/delete/modify
git diff --stat main
```

**VERIFY** the diff contains only: the guide move, deleted companion/reference/old
agents, the entrypoint + Rakefile edits, the gemspec edit (unless git-ls-files),
the new `the_local/agents/*.md`, and the drift test. Anything else — **STOP** and
explain it before committing.

Commit in small, honest steps, then open a PR against the gem's `main`:

```bash
git add -A
git commit -m "Migrate to the guide-based the_local provider model"
git push -u origin chore/the_local-guide-migration
gh pr create --base main --title "Migrate to the guide-based the_local provider model" --body "…"
```

In the PR body, state plainly:
- The gem now ships no Ruby for the_local; one `the_local/guide.md` renders the
  locals.
- **If this was an `operate` gem:** the worker local is renamed `operate` →
  `develop`. Hosts that installed `<gem>-operate.md` keep a stale copy until they
  re-run `the_local install`; note that a host re-sync is needed.

---

## The six gems and their specifics (ground truth)

Verified against the repos on disk. Use this to sanity-check what each gem's run
should look like — but still run every VERIFY gate; do not skip them.

**Check which entry point each gem needs before starting it** — a gem migrated
before the authoring step existed has an unauthored guide and needs Step 6
onward, not the whole runbook:

```bash
test -f the_local/guide.md && ! ls lib/**/the_local.rb >/dev/null 2>&1 \
  && echo "already migrated — start at Step 6" || echo "register model — start at Preconditions"
```

| Gem | lib `<path>` | Worker | gemspec `files` | gemspec edit? | Old comp/ref tests | Notes |
|---|---|---|---|---|---|---|
| `citizen` | `citizen` | develop | `Dir.chdir { Dir["{app,config,db,lib}/**/*", …] }` | **yes** — add `"the_local/**/*"` | none | clean |
| `cs133` | `cs133` | develop | `git ls-files` | **no** | none | clean |
| `dash_kit` | `dash_kit` | develop | `Dir.chdir { Dir["{app,config,db,lib}/**/*", …] }` | **yes** | none | clean |
| `event_engine` | `event_engine` | develop | `Dir.chdir { Dir["{app,config,db,lib}/**/*", …] }` | **yes** | **companion_test + reference_test** — delete both | **already migrated (PR #238) with an unauthored guide — start at Step 6.** Its old register block holds the authored text to recover. |
| `event_engine-subscribers` | `event_engine/subscribers` | **operate** | `Dir.chdir { Dir["{app,config,db,lib}/**/*", …] }` | **yes** | none | **guide is all `TODO:` — unfinished scaffold. Step 1 GATE will STOP you: finish the guide first (authoring), or skip this gem.** |
| `keystone_ui` | `keystone_ui` | develop | `Dir["lib/**/*", "app/**/*"]` | **yes** | **companion_test + reference_test** — delete both | clean |

---

## Fail-safe summary

Stop and get help the moment any of these is true:

- A VERIFY gate's output doesn't match its stated expectation.
- The guide has `TODO:` markers or fewer than 4 canonical sections.
- `rake the_local:build` reports `incomplete guide(s)` or `unauthored scope`.
- A `develop` description names only the gem ("any `<gem>` work") — it will not route.
- A second build produces a diff (non-idempotent).
- The final `git diff --stat` shows files outside the expected set.
- The gem's test suite has failures you can't trace to deleted companion/reference code.
