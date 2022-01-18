require 'open3'

class CLASS < Formula
  desc 'Securely share application secret with your team'
  homepage 'https://keytone.sh'
  head 'https://github.com/wearedevx/keystone.git', branch: '<%BRANCH%>'
  url 'https://github.com/wearedevx/keystone/archive/<%BRANCH%>.tar.gz'
  sha256 '<%CHECKSUM%>'
  version '<%BRANCH%>'

  depends_on 'git'
  depends_on 'gcc@11'
  depends_on 'make'
  depends_on 'openssl@1.1'
  depends_on 'go@1.16'
  depends_on 'libsodium'

  def install_themis
    system 'git', 'clone', '--depth', '1', '--branch', '0.13.13', 'https://github.com/cossacklabs/themis.git'
    Dir.chdir 'themis' do
      ENV['ENGINE'] = 'openssl'
      ENV['ENGINE_INCLUDE_PATH'] = Formula['openssl@1.1'].include
      ENV['ENGINE_LIB_PATH'] = Formula['openssl@1.1'].lib
      ENV['PREFIX'] = prefix
      system 'make', 'install'
    end
  end

  def install_completions
     ENV["SHELL_COMPLETIONS_DIR"] = buildpath

     stdout, stderr, status = Open3.capture3('./ks', 'completion', 'zsh')
     File.open("_ks.zsh", "w") { |f| f.write(stdout) }
     stdout, stderr, status = Open3.capture3('./ks', 'completion', 'bash')
     File.open("_ks.sh", "w") { |f| f.write(stdout) }
     stdout, stderr, status = Open3.capture3('./ks', 'completion', 'fish')
     File.open("ks.fish", "w") { |f| f.write(stdout) }

     zsh_completion.install "_ks.zsh" => "_ks"
     bash_completion.install "_ks.sh" 
     fish_completion.install "ks.fish" 
  end

  def install_manpages
     man.mkpath
     system('mkdir', 'man')
     system('./ks', 'documentation', '-t', 'man', '-d', 'man')

     man1.install Dir['man/*']
  end
  
  def install
    install_themis()

    ENV['CGO_ENABLED'] = '1'
    ENV['CGO_LDFLAGS'] = "-L#{prefix}/lib"
    ENV['CGO_CFLAGS'] = "-I#{prefix}/include"

    packagePrefix = "github.com/wearedevx/keystone/cli"
    clientPkg = "#{packagePrefix}/pkg/client"
    constantsPkg = "#{packagePrefix}/pkg/constants"
    authPkg = "#{packagePrefix}/pkg/client/auth"

    apiFlag = "-X '#{clientPkg}.ApiURL=<%KSAPI_URL%>'"
    authProxyFlag = "-X '#{authPkg}.authRedirectURL=<%AUTH_PROXY%>'"

    versionFlag = "-X '#{constantsPkg}.Version=<%VERSION%>'"

    ghClientIdFlag = "-X '#{authPkg}.githubClientId=<%GITHUB_CLIENT_ID%>'"
    ghClientSecretFlag = "-X '#{authPkg}.githubClientSecret=<%GITHUB_CLIENT_SECRET%>'"
    glClientIdFlag = "-X '#{authPkg}.gitlabClientId=<%GITLAB_CLIENT_ID%>'"
    glClientSecretFlag = "-X '#{authPkg}.gitlabClientSecret=<%GITLAB_CLIENT_SECRET%>'"

    Dir.chdir 'cli' do
      system(Formula['go@1.16'].bin + 'go', 'clean')
      system(Formula['go@1.16'].bin + 'go', 'get')

      system(Formula['go@1.16'].bin + 'go',
             'build',
             '-ldflags',
             "#{apiFlag} #{authProxyFlag} #{versionFlag} #{ghClientIdFlag} #{ghClientSecretFlag} #{glClientIdFlag} #{glClientSecretFlag}",
             '-o',
             'ks')

      install_completions()
      install_manpages()
    end

    bin.install "cli/ks" => "ks"
    
  end
end

