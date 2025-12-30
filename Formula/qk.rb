class Qk < Formula
  desc "QK CLI - A powerful command-line tool built with ZX and Commander.js"
  homepage "https://github.com/choufeng/qk"
  url "https://github.com/choufeng/qk/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "91c566f6a558771a41fb49a478048a819939ded69ba62fbcdad1e220ba93b0f8"
  license "MIT"

  depends_on "bun"

  def install
    libexec.install Dir["*"]
    (bin/"qk").write_env_script libexec/"cli.mjs", PATH: "#{Formula["bun"].opt_bin}:$PATH"
    chmod 0755, bin/"qk"
  end

  test do
    system bin/"qk", "--version"
  end
end
