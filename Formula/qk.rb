class Qk < Formula
  desc "QK CLI - A powerful command-line tool built with ZX and Commander.js"
  homepage "https://github.com/choufeng/qk"
  url "https://github.com/choufeng/qk/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "91c566f6a558771a41fb49a478048a819939ded69ba62fbcdad1e220ba93b0f8"
  license "MIT"

  def install
    libexec.install Dir["*"]
    
    # Use absolute path to bun if available
    bun_path = which("bun") || "#{Dir.home}/.bun/bin/bun"
    raise "bun not found. Please install bun: curl -fsSL https://bun.sh/install | bash" unless File.exist?(bun_path)
    
    cd libexec do
      system bun_path, "install", "--production"
    end
    (bin/"qk").write_env_script libexec/"cli.mjs", PATH: "#{File.dirname(bun_path)}:$PATH"
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
