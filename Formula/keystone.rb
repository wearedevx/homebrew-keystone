class Keystone < Formula
  desc 'Securely share application secret with your team'
  homepage 'https://keytone.sh'
  head 'https://github.com/wearedevx/keystone.git', branch: '0.1.58'
  url 'https://github.com/wearedevx/keystone/archive/0.1.58.tar.gz'
  sha256 '4478025017ac2eacc30f130f3d6396fbd69c505ac6cfa087efc5da2b7b6dc3bb'
  version '0.1.58'

  depends_on 'git'
  depends_on 'gcc'
  depends_on 'make'
  depends_on 'openssl'
  depends_on 'go'
  depends_on 'libsodium'

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

    system 'ls', "#{prefix}/include"

    packagePrefix = "github.com/wearedevx/keystone/cli"
    clientPkg = "#{packagePrefix}/pkg/client"
    constantsPkg = "#{packagePrefix}/pkg/constants"
    authPkg = "#{packagePrefix}/pkg/client/auth"

    apiFlag = "-X '#{clientPkg}.ApiURL=https://v0-1-58---keystone-server-esk4nrfqlq-oa.a.run.app'"
    authProxyFlag = "-X '#{authPkg}.authRedirectURL=https://europe-west6-keystone-245200.cloudfunctions.net/auth-proxy'"

    versionFlag = "-X '#{constantsPkg}.Version=0.1.58'"

    ghClientIdFlag = "-X '#{authPkg}.githubClientId=60165e42468cf5e34aa8'"
    ghClientSecretFlag = "-X '#{authPkg}.githubClientSecret=016a30fed8fe9029b22272650af6aa18b3dcf590'"
    glClientIdFlag = "-X '#{authPkg}.gitlabClientId=d372c2f3eebd9c498b41886667609fbdcf149254bcb618ddc199047cbbc46b78'"
    glClientSecretFlag = "-X '#{authPkg}.gitlabClientSecret=ffe9317fd42d32ea7db24c79f9ee25a3e30637b886f3bc99f951710c8cdc3650'"

    Dir.chdir 'cli' do
      system(Formula['go'].bin + 'go',
             'build',
             '-ldflags',
             "#{apiFlag} #{authProxyFlag} #{versionFlag} #{ghClientIdFlag} #{ghClientSecretFlag} #{glClientIdFlag} #{glClientSecretFlag}",
             '-o',
             'ks')
    end

    bin.install "cli/ks" => "ks"
  end
end

