class Drydock < Formula
  desc "Sandbox for autonomous coding agents on macOS"
  homepage "https://sricola.github.io/drydock/"
  url "https://github.com/sricola/drydock/releases/download/v0.2.0/drydock-v0.2.0-darwin-arm64.tar.gz"
  sha256 "376ae3bd5bca3a29595738c1b321277e1f41ab4ae476c8457fa4cafafac3c2fa"
  license "MIT"
  version "0.2.0"

  # Apple silicon only — drydock targets Apple's `container` runtime which is
  # arm64-native and ships only on macOS today.
  depends_on macos: :sonoma
  depends_on arch: :arm64

  depends_on "squid"

  def install
    bin.install "bin/brokerd", "bin/drydock"
    # Image build contexts + default config. The drydock binary auto-discovers
    # this path via `<bin>/../share/drydock/{image,config}` relative to itself
    # (see findImageDir in cmd/drydock/init.go), so `drydock init` works from
    # any directory once brewed.
    (share/"drydock").install "share/drydock/image", "share/drydock/config"
  end

  def caveats
    <<~EOS
      drydock needs Apple's `container` runtime installed and started:

        brew install --cask container
        container system start --enable-kernel-install

      Bootstrap from any directory. Use an API key — or run on your existing
      Claude Pro/Max or ChatGPT subscription (no key):

        export ANTHROPIC_API_KEY=sk-ant-...   # Claude Code (API key)
        export OPENAI_API_KEY=sk-...          # OpenAI Codex (API key)
        # …or, instead of a key, reuse a subscription:
        #   drydock auth claude   # Claude Pro/Max → anthropic_auth: subscription
        #   drydock auth codex    # ChatGPT plan   → openai_auth: subscription
        drydock init                    # seeds ~/.drydock/{config,egress}.yaml,
                                        # creates the network, builds the images
        drydock start                   # foreground; ^C to stop

      All operator config lives in ~/.drydock/. Edit and re-run `drydock start`.
      API keys stay in your shell env; subscription tokens live host-side in
      ~/.drydock/ (mode 0600). Neither ever enters the sandbox VM.

      Pick the agent per task with `drydock submit --agent claude|codex`
      (default `claude`; override with `default_agent` in the config).

      For PR/MR pushes, install whichever vendor CLI matches your repos and
      run its auth login first:

        brew install gh     # GitHub
        brew install glab   # GitLab
        # Gitea / Forgejo: see https://gitea.com/gitea/tea

      Threat model + the precise security claims:
        https://github.com/sricola/drydock/blob/main/THREAT_MODEL.md
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/drydock version")
    assert_match "drydock", shell_output("#{bin}/drydock help 2>&1")
    # Smoke: drydock status when brokerd isn't running exits non-zero with a
    # clear "brokerd down" line — confirms socket discovery is wired.
    output = shell_output("#{bin}/drydock status 2>&1", 0)
    assert_match "brokerd", output
  end
end
