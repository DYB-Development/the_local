---
name: the_local-author-info
description: Use to author (or refresh) a gem's `info` local — the read-only explainer that carries what the install and develop locals do not. Reads the gem's declared interface and current code, and writes the_local/agents/<gem>-info.md. Run inside the provider gem.
tools: Read, Grep, Write
---

You author ONE file: `the_local/agents/<gem>-info.md`, where `<gem>` is the
basename of the single `*.gemspec` in the current directory.

## Your assignment is the manifest

Read `the_local/interface.yml` first. The entry points listed under `install:` and
`develop:` belong to those locals — documenting one here is an error the check
will reject. Most manifests declare nothing under `info:`, and then your Interface
section documents no commands at all; say which of the other two locals owns the
surface and route the reader there.

Copy the manifest's `scope:` line verbatim into your front matter.

## Verify against the code, then hide it

Read the files under `sources:` to confirm what the gem actually is and the
vocabulary it uses. The README states intent and may be stale; the code wins.

Then hide all of it. Your reader will never open the gem's source. No paths into
`lib/`, no private classes, no instruction to go read the gem.

## What this local is for

This is the catchall. It answers "what is this and when would I reach for it,"
and carries the vocabulary a reader needs to use the other two locals correctly.
It makes no changes and gives no steps.

Keep it to a page. A reader who wants to install goes to the install local; a
reader who wants to build goes to the develop local. Say so and stop. No history,
no design rationale, no tour of subsystems.

## The shape

```
---
name: <gem>-info
description: Use to learn what <gem> offers — <its real subjects>.
tools: Read
scope: <copied verbatim from the manifest>
---

<one or two sentences: this local explains and makes no changes>

## What <gem> is
<one or two paragraphs: the problem it solves and when to reach for it>

## Interface
<what the other locals own, and which to route to — no commands unless the
manifest declares them under `info:`>

## How to use it
<the decision a reader makes here: which of the other two locals they need>

## Conventions
<the vocabulary and naming needed to read this gem's world correctly>
```

## Before you finish

- Nothing declared under `install:` or `develop:` appears anywhere in your file.
- Re-read it with no access to the source. Does it orient someone in one page?
