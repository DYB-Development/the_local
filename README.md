# TheLocal

Resident Claude Code expert subagents ("locals"), contributed by the gems an app
uses. Any gem or app declares the locals that know its conventions; `the_local`
aggregates the locals of an app's installed providers into its
`.claude/agents/`, plus a delegation rule so the app's agent actually uses them.

A "local" is a Claude Code subagent that knows one gem's conventions cold. The
host's orchestrating agent delegates that gem's work to it, so usage stays
consistent instead of drifting.

## Installation

Add it to your Gemfile:

```ruby
gem "the_local"
```

or install it directly with `gem install the_local`. To track an unreleased
change, point at the repo instead:

```ruby
gem "the_local", github: "DYB-Development/the_local"
```

The gem's core is Rails-free. `bundle exec the_local install` and the
`the_local:check`/`the_local:refresh` rake tasks work without Rails; a Rails host
can equivalently use the `bin/rails g the_local:install` / `the_local:provider`
generators.

Once installed, the locals themselves know the rest — the `the_local-info`,
`the_local-install`, and `the_local-develop` agents explain, set up, and drive
the_local, so this README stays short on purpose.

## Usage

There are two sides.

**Consuming app** — install the locals of the app's direct dependencies (and the
app's own) into `.claude/agents/`, and write the delegation trigger:

```bash
bundle exec the_local install
```

Install **copies each provider's committed `.md` verbatim** — no provider code is
loaded — so every app on the same gem version gets a byte-identical local. Re-run
it (or `rake the_local:refresh`) after a `bundle install`/`update` to re-sync.

**Provider gem** — contribute the locals an app installs. A gem commits three
files, `the_local/agents/<gem>-{info,install,develop}.md`, and ships no Ruby. They
are authored by `rake the_local:author`, which reads the gem's current code and
writes the locals from it — so the docs never drift from the source. Wire the
tooling with:

```bash
bin/rails g the_local:provider
```

See [PROVIDERS.md](PROVIDERS.md) for the full provider guide, including the
manual steps for non-Rails gems.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DYB-Development/the_local.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
