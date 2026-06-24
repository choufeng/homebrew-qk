class Qk < Formula
  desc "Powerful command-line tool built with ZX and Commander.js"
  homepage "https://github.com/choufeng/qk"
  url "https://github.com/choufeng/qk/archive/refs/tags/v2.4.1.tar.gz"
  sha256 "d3dbcc27793101197b9e244e87387405d2582e9b34acef69293584185126e741"
  license "MIT"

  def install
    libexec.install Dir["*"]

    # Create wrapper script that will use bun from user's PATH
    (bin/"qk").write <<~EOS
      #!/bin/bash
      set -e

      LIBEXEC="#{libexec}"

      # Check if bun is available
      if ! command -v bun &> /dev/null; then
        echo "Error: bun not found. Please install bun: curl -fsSL https://bun.sh/install | bash"
        exit 1
      fi

      # Auto-install dependencies if node_modules doesn't exist
      if [ ! -d "$LIBEXEC/node_modules" ]; then
        echo "Installing dependencies..."
        (cd "$LIBEXEC" && bun install --production)
      fi

      exec bun "$LIBEXEC/cli.mjs" "$@"
    EOS
    chmod 0755, bin/"qk"
  end

  def caveats
    <<~EOS
      This formula requires bun to be installed.
      Install bun with: curl -fsSL https://bun.sh/install | bash
    EOS
  end

  test do
    system bin/"qk", "--version"
  end
end
