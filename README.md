# homebrew-drydock

Homebrew tap for [drydock](https://sricola.github.io/drydock/) — a sandbox
for autonomous coding agents on macOS.

```bash
brew tap sricola/drydock
brew install drydock
```

Then bootstrap (one time):

```bash
brew install --cask container
container system start --enable-kernel-install
export ANTHROPIC_API_KEY=sk-ant-...
drydock init
drydock start
```

drydock is **Apple silicon + macOS only**. The formula pulls a pre-built
arm64 binary from the [drydock release page](https://github.com/sricola/drydock/releases);
no Go toolchain required.

## What you get

- `brokerd` — the broker daemon
- `drydock` — the operator CLI (`init`, `start`, `submit`, `status`, `tasks`,
  `pending`, `review`, `approve`, `deny`, `kill`, `logs`)
- `share/drydock/image/` — build contexts for the per-task agent VM and
  the minimal anchor container
- `share/drydock/config/egress.yaml` — the default egress allowlist

The `drydock` binary discovers `share/drydock/image` relative to itself, so
`drydock init` works from any directory once brewed.

## Links

- [drydock project](https://github.com/sricola/drydock)
- [Threat model](https://github.com/sricola/drydock/blob/main/THREAT_MODEL.md)
- [Site](https://sricola.github.io/drydock/)

## License

The formula itself is MIT, matching drydock.
