require 'open3'

class KeystoneDevelop < Formula
  desc 'Securely share application secret with your team'
  homepage 'https://keytone.sh'
  head 'https://github.com/wearedevx/keystone.git', branch: 'develop'
  url 'https://github.com/wearedevx/keystone/archive/develop.tar.gz'
  sha256 'eb74a17c5c5921023639808930126b6ea6abe960a35a2e8647c1fb2c832bfb71'
  version 'develop'

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

    apiFlag = "-X '#{clientPkg}.ApiURL=https://develop---keystone-server-esk4nrfqlq-oa.a.run.app'"
    authProxyFlag = "-X '#{authPkg}.authRedirectURL=https://europe-west6-keystone-245200.cloudfunctions.net/auth-proxy'"

    versionFlag = "-X '#{constantsPkg}.Version=develop'"

    ghClientIdFlag = "-X '#{authPkg}.githubClientId=60165e42468cf5e34aa8'"
    ghClientSecretFlag = "-X '#{authPkg}.githubClientSecret=016a30fed8fe9029b22272650af6aa18b3dcf590'"
    glClientIdFlag = "-X '#{authPkg}.gitlabClientId=d372c2f3eebd9c498b41886667609fbdcf149254bcb618ddc199047cbbc46b78'"
    glClientSecretFlag = "-X '#{authPkg}.gitlabClientSecret=ffe9317fd42d32ea7db24c79f9ee25a3e30637b886f3bc99f951710c8cdc3650'"

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

