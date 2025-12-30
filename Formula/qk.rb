class Qk < Formula
  desc "QK CLI - A powerful command-line tool built with ZX and Commander.js"
  homepage "https://github.com/choufeng/qk"
  url "https://github.com/choufeng/qk/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "91c566f6a558771a41fb49a478048a819939ded69ba62fbcdad1e220ba93b0f8"
  license "MIT"

  def install
    libexec.install Dir["*"]
    
    # Set PATH to include common bun installation locations
    ENV.prepend_path "PATH", "#{Dir.home}/.bun/bin"
    
    cd libexec do
      system "bun", "install", "--production"
    end
    (bin/"qk").write_env_script libexec/"cli.mjs", PATH: "#{Dir.home}/.bun/bin:$PATH"
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
