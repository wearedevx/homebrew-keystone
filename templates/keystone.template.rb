class CLASS < Formula
  desc 'Securely share application secret with your team'
  homepage 'https://keytone.sh'
  head 'https://github.com/wearedevx/keystone.git', branch: '<%BRANCH%>'
  url 'https://github.com/wearedevx/keystone/archive/<%BRANCH%>.tar.gz'
  sha256 '<%CHECKSUM%>'
  version '<%BRANCH%>'

  depends_on 'git@2.34'
  depends_on 'gcc@11.2'
  depends_on 'make@4.3'
  depends_on 'openssl@1.1'
  depends_on 'go@1.17'
  depends_on 'libsodium@1.0'

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

    apiFlag = "-X '#{clientPkg}.ApiURL=<%KSAPI_URL%>'"
    authProxyFlag = "-X '#{authPkg}.authRedirectURL=<%AUTH_PROXY%>'"

    versionFlag = "-X '#{constantsPkg}.Version=<%VERSION%>'"

    ghClientIdFlag = "-X '#{authPkg}.githubClientId=<%GITHUB_CLIENT_ID%>'"
    ghClientSecretFlag = "-X '#{authPkg}.githubClientSecret=<%GITHUB_CLIENT_SECRET%>'"
    glClientIdFlag = "-X '#{authPkg}.gitlabClientId=<%GITLAB_CLIENT_ID%>'"
    glClientSecretFlag = "-X '#{authPkg}.gitlabClientSecret=<%GITLAB_CLIENT_SECRET%>'"

    Dir.chdir 'cli' do
      system(Formula['go@1.17'].bin + 'go', 'clean')
      system(Formula['go@1.17'].bin + 'go', 'get')

      system(Formula['go@1.17'].bin + 'go',
             'build',
             '-ldflags',
             "#{apiFlag} #{authProxyFlag} #{versionFlag} #{ghClientIdFlag} #{ghClientSecretFlag} #{glClientIdFlag} #{glClientSecretFlag}",
             '-o',
             'ks')
    end

    bin.install "cli/ks" => "ks"
  end
end

