# frozen_string_literal: true

require "open3"

class Keystone < Formula
  desc "Securely share application secret with your team"
  homepage "https://keystone.sh"
  url "https://github.com/wearedevx/keystone/archive/0.2.47.tar.gz"
  sha256 "2a1a6eaa3813f8fd86212ee7fc4089128058d308f21402ea110ce729530afc62"
  head "https://github.com/wearedevx/keystone.git", branch: "0.2.47"

  bottle do
    root_url "https://github.com/wearedevx/homebrew-keystone/releases/download/0.2.47"
    rebuild 1
    sha256 cellar: :any, monterey: "96d30793d2a9f945e4bb4bdfaa344648b9ea1e91f9bb1df1c5724f3789a89e96"
    sha256 cellar: :any, big_sur:  "e8009e7db079dd7c6c62469d072fa8bdd5629e47dab6ef702a526d3077957b71"
  end

  depends_on "gcc@11"
  depends_on "git"
  depends_on "go@1.16"
  depends_on "libsodium"
  depends_on "make"
  depends_on "openssl@1.1"
  depends_on "pkg-config"

  def install_themis
    system("git", "clone", "--depth", "1", "--branch", "0.13.13", "https://github.com/cossacklabs/themis.git")
    Dir.chdir("themis") do
      ENV["ENGINE"] = "openssl"
      ENV["ENGINE_INCLUDE_PATH"] = Formula["openssl@1.1"].include
      ENV["ENGINE_LIB_PATH"] = Formula["openssl@1.1"].lib
      ENV["PREFIX"] = prefix
      system("make", "install")
    end
  end

  def install_completions
    ENV["SHELL_COMPLETIONS_DIR"] = buildpath

    stdout, _stderr, _status = Open3.capture3("./ks", "completion", "zsh")
    File.write("_ks.zsh", stdout)
    stdout, _stderr, _status = Open3.capture3("./ks", "completion", "bash")
    File.write("_ks.sh", stdout)
    stdout, _stderr, _status = Open3.capture3("./ks", "completion", "fish")
    File.write("_ks.fish", stdout)

    zsh_completion.install("_ks.zsh" => "_ks")
    bash_completion.install("_ks.sh")
    fish_completion.install("_ks.fish")
  end

  def install_manpages
    man.mkpath
    mkdir("man")
    system("./ks", "documentation", "-t", "man", "-d", "man")

    man1.install(Dir["man/*"])
  end

  def install
    install_themis

    ENV["CGO_ENABLED"] = "1"
    ENV["CGO_LDFLAGS"] = "-L#{lib}"
    ENV["CGO_CFLAGS"] = "-I#{include}"

    package_prefix = "github.com/wearedevx/keystone/cli"
    client_pkg = "#{package_prefix}/pkg/client"
    constants_pkg = "#{package_prefix}/pkg/constants"
    auth_pkg = "#{package_prefix}/pkg/client/auth"

    api_flag = "-X '#{client_pkg}.ApiURL=https://v0-2-47---keystone-server-esk4nrfqlq-oa.a.run.app'"
    auth_proxy_flag = "-X '#{auth_pkg}.authRedirectURL=https://europe-west6-keystone-245200.cloudfunctions.net/auth-proxy'"

    version_flag = "-X '#{constants_pkg}.Version=0.2.47'"

    gh_client_id_flag =
      "-X '#{auth_pkg}.githubClientId=60165e42468cf5e34aa8'"
    gh_client_secret_flag =
      "-X '#{auth_pkg}.githubClientSecret=016a30fed8fe9029b22272650af6aa18b3dcf590'"
    gl_client_id_flag =
      "-X '#{auth_pkg}.gitlabClientId=d372c2f3eebd9c498b41886667609fbdcf149254bcb618ddc199047cbbc46b78'"
    gl_client_secret_flag =
      "-X '#{auth_pkg}.gitlabClientSecret=ffe9317fd42d32ea7db24c79f9ee25a3e30637b886f3bc99f951710c8cdc3650'"

    Dir.chdir("cli") do
      system("#{Formula["go@1.16"].bin}/go", "clean")
      system("#{Formula["go@1.16"].bin}/go", "get")

      system(
        "#{Formula["go@1.16"].bin}/go",
        "build",
        "-ldflags",
        "#{api_flag} #{auth_proxy_flag} #{version_flag} #{gh_client_id_flag} #{gh_client_secret_flag} #{gl_client_id_flag} #{gl_client_secret_flag}",
        "-o",
        "ks",
      )

      install_completions
      install_manpages
    end

    bin.install("cli/ks" => "ks")
  end
end
