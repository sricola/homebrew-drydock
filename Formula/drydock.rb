class Drydock < Formula
  desc "Sandbox for autonomous coding agents on macOS"
  homepage "https://sricola.github.io/drydock/"
  url "https://github.com/sricola/drydock/releases/download/v0.1.0/drydock-v0.1.0-darwin-arm64.tar.gz"
  sha256 "3a267ce6e9a9e655a69134332fa60abf17d6af7fb291fe5942ca32c7dfa6f012"
  license "MIT"
  version "0.1.0"

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
    assert_match "drydock", shell_output("#{bin}/drydock help 2>&1", 2)
  end
end
