class Qk < Formula
  desc "QK CLI - A powerful command-line tool built with ZX and Commander.js"
  homepage "https://github.com/choufeng/qk"
  url "https://github.com/choufeng/qk/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "91c566f6a558771a41fb49a478048a819939ded69ba62fbcdad1e220ba93b0f8"
  license "MIT"

  def install
    libexec.install Dir["*"]
    
    # Check if bun is available in system PATH
    bun_path = which("bun")
    if bun_path
      cd libexec do
        system bun_path, "install", "--production"
      end
    else
      # If bun is not available, assume dependencies are pre-installed
      # User needs to have bun installed in their PATH
      ohai "Warning: bun not found during install. Dependencies may not be installed."
    end
    
    # Create wrapper script that will use bun from user's PATH
    (bin/"qk").write <<~EOS
      #!/bin/bash
      if command -v bun &> /dev/null; then
        exec bun "#{libexec}/cli.mjs" "$@"
      else
        echo "Error: bun not found. Please install bun: curl -fsSL https://bun.sh/install | bash"
        exit 1
      fi
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
