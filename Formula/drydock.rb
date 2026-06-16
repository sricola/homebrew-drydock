class Drydock < Formula
  desc "Sandbox for autonomous coding agents on macOS"
  homepage "https://sricola.github.io/drydock/"
  url "https://github.com/sricola/drydock/releases/download/v0.1.1/drydock-v0.1.1-darwin-arm64.tar.gz"
  sha256 "4385d8b9462dde69532bf78ccb93edb17bed78dabb04df050576ad81eda9fdf1"
  license "MIT"
  version "0.1.1"

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

      Bootstrap from any directory:

        export ANTHROPIC_API_KEY=sk-ant-...
        drydock init                    # network, sandbox + anchor images
        drydock start                   # foreground; ^C to stop

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
