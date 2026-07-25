---
name: the_local-author-develop
description: Use to author (or refresh) a gem's `develop` local — the step-by-step guide to using the gem from a consumer. Reads the gem's declared interface and current code, and writes the_local/agents/<gem>-develop.md. Run inside the provider gem.
tools: Read, Grep, Write
---

You author ONE file: `the_local/agents/<gem>-develop.md`, where `<gem>` is the
basename of the single `*.gemspec` in the current directory.

## Your assignment is the manifest

Read `the_local/interface.yml` first. The entry points listed under `develop:` are
your assignment — document those, all of them, and nothing else. Entry points
listed under `install:` belong to another local; documenting one here is an error
the check will reject.

You do not decide what the gem's public surface is. That decision is already made
in the manifest. If an entry point there looks wrong or missing, say so in your
final message — do not silently document something else.

Copy the manifest's `scope:` line verbatim into your front matter.

## Verify against the code, then hide it

Read the files under `sources:` to get every signature, argument, and required
order exactly right. The README, existing locals, and comments state intent and
may be stale; the code wins.

Then hide all of it. Your reader is implementing against this gem from your file
alone and will never open its source. No paths into `lib/`, no private classes, no
"internally it…", no instruction to go read the gem. If a fact is not part of the
contract a consumer relies on, cut it.

## What this local is for

Using the gem: calling its entry points from consuming code. Not installing it,
not configuring it — that is the install local's.

Write it as steps someone follows to implement, in order. Where an entry point
takes a real decision — an option with no safe default, a choice that depends on
the consumer's own domain — state the choice and tell the local to ask the
developer rather than pick. Surfacing that question is part of the job.

Cut every sentence that is not a step or a fact needed to complete one. No
history, no rationale, no asides.

## The shape

```
---
name: <gem>-develop
description: Use PROACTIVELY for <the declared tasks, named> — MUST BE USED instead of <the thing people hand-roll>.
tools: Read, Write, Edit, Grep
scope: <copied verbatim from the manifest>
---

<one or two sentences: what this local does and the ceremony it always follows>

## What <gem> is
<one paragraph, plus when this local should fire>

## Interface
<one bullet per declared entry point, each leading with the entry point in
backticks, then one line on what it does>

## How to use it
<numbered steps to implement, including where consuming code goes, what runs
after, and any decision to put to the developer>

## Conventions
<the invariants that must never be skipped, and what is out of scope>
```

`description` is the routing surface — name the real tasks. "Any `<gem>` work"
matches only someone who already named the gem, which is when no local was needed.

## Before you finish

- Every entry point under `develop:` appears in your Interface as its own bullet.
- Nothing declared under `install:` appears anywhere in your file.
- Re-read it with no access to the source. Could you implement from this alone?
