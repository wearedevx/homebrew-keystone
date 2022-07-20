require 'open3'

class KeystoneAT02 < Formula
  desc 'Securely share application secret with your team'
  homepage 'https://keytone.sh'
  head 'https://github.com/wearedevx/keystone.git', branch: '0.2.43'
  url 'https://github.com/wearedevx/keystone/archive/0.2.43.tar.gz'
  sha256 'a3d9c2d6a1d0ef1bbdb057d642cad35cc48e421fe43e96905acff0fd11f2dfbc'
  version '0.2.43'

  depends_on 'git'
  depends_on 'gcc@11'
  depends_on 'make'
  depends_on 'openssl@1.1'
  depends_on 'go@1.16'
  depends_on 'libsodium'

  bottle do
    root_url "https://www.github.com/wearedevx/keystone/releases/download/0.2.43"
    rebuild 1
    sha256 cellar: :any, big_sur: "ffe20ff29029525856d8cfa6dcb9b5929a73cb590f4cd408833eb037fa82d34f"
  end

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

    apiFlag = "-X '#{clientPkg}.ApiURL=https://v0-2-43---keystone-server-esk4nrfqlq-oa.a.run.app'"
    authProxyFlag = "-X '#{authPkg}.authRedirectURL=https://europe-west6-keystone-245200.cloudfunctions.net/auth-proxy'"

    versionFlag = "-X '#{constantsPkg}.Version=0.2.43'"

    ghClientIdFlag = "-X '#{authPkg}.githubClientId=ghcid'"
    ghClientSecretFlag = "-X '#{authPkg}.githubClientSecret=ghcs'"
    glClientIdFlag = "-X '#{authPkg}.gitlabClientId=glcid'"
    glClientSecretFlag = "-X '#{authPkg}.gitlabClientSecret=glcs'"

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

