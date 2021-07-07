class Keystone < Formula
  desc 'Securely share application secret with your team'
  homepage 'https://keytone.sh'
  head 'https://github.com/wearedevx/keystone.git', branch: ''
  url 'https://github.com/wearedevx/keystone/archive/.tar.gz'
  sha256 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  version ''

  depends_on 'openssl'
  depends_on 'go'

  def install_themis
    system 'git', 'clone', 'https://github.com/cossacklabs/themis.git'
    Dir.chdir 'themis' do
      ENV['ENGINE'] = 'openssl'
      ENV['ENGINE_INCLUDE_PATH'] = Formula['openssl'].include
      ENV['ENGINE_LIB_PATH'] = Formula['openssl'].lib
      ENV['PREFIX'] = prefix
      system 'make', 'install'
    end
  end
  
  def install
    install_themis()

    ENV['CGO_ENABLED'] = '1'
    ENV['CGO_LDFLAGS'] = "-L#{prefix}/lib"
    ENV['CGO_CFLAGS'] = "-I#{prefix}/include"
    ENV['KS_API_URL'] = "https://v0-1-6---keystone-server-esk4nrfqlq-oa.a.run.app"

    system 'ls', "#{prefix}/include"

    packagePrefix = "github.com/wearedevx/keystone/cli"
    clientPkg = "#{packagePrefix}/pkg/client"
    authPkg = "#{packagePrefix}/pkg/client/auth"

    apiFlag = "-X '#{clientPkg}.ApiURL=https://v0-1-6---keystone-server-esk4nrfqlq-oa.a.run.app'"
    ghClientIdFlag = "-X '#{authPkg}.githubClientId=d253d9fe1adf31b932e9'"
    ghClientSecretFlag = "-X '#{authPkg}.githubClientSecret=3b58f72d1f255330ac9079061e6bbb5649ca02c1'"
    glClientIdFlag = "-X '#{authPkg}.gitlabClientId=d372c2f3eebd9c498b41886667609fbdcf149254bcb618ddc199047cbbc46b78'"
    glClientSecretFlag = "-X '#{authPkg}.gitlabClientSecret=ffe9317fd42d32ea7db24c79f9ee25a3e30637b886f3bc99f951710c8cdc3650'"

    Dir.chdir 'cli' do
      system(Formula['go'].bin + 'go',
             'build',
             '-ldflags',
             "#{apiFlag} #{ghClientIdFlag} #{ghClientSecretFlag} #{glClientIdFlag} #{glClientSecretFlag}",
             '-o',
             'ks')
    end

    bin.install "cli/ks" => "ks"
  end
end

