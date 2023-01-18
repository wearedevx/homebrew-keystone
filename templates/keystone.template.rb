# frozen_string_literal: true

require "open3"

class CLASS < Formula
  desc "Securely share application secret with your team"
  homepage "https://keystone.sh"
  url "https://github.com/wearedevx/keystone/archive/<%BRANCH%>.tar.gz"
  # sha256 "<%CHECKSUM%>"
  head "https://github.com/wearedevx/keystone.git", branch: "<%BRANCH%>"

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

    api_flag = "-X '#{client_pkg}.ApiURL=<%KSAPI_URL%>'"
    auth_proxy_flag = "-X '#{auth_pkg}.authRedirectURL=<%AUTH_PROXY%>'"

    version_flag = "-X '#{constants_pkg}.Version=<%VERSION%>'"

    gh_client_id_flag =
      "-X '#{auth_pkg}.githubClientId=<%GITHUB_CLIENT_ID%>'"
    gh_client_secret_flag =
      "-X '#{auth_pkg}.githubClientSecret=<%GITHUB_CLIENT_SECRET%>'"
    gl_client_id_flag =
      "-X '#{auth_pkg}.gitlabClientId=<%GITLAB_CLIENT_ID%>'"
    gl_client_secret_flag =
      "-X '#{auth_pkg}.gitlabClientSecret=<%GITLAB_CLIENT_SECRET%>'"

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
