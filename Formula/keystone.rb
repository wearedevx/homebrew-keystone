class Keystone < Formula
  desc 'Securely share application secret with your team'
  homepage 'https://keytone.sh'
  head 'https://github.com/wearedevx/keystone.git', branch: 'develop'
  url 'https://github.com/wearedevx/keystone/develop.tar.gz'
  sha256 '941bde4159a7c019fddfc4480bb3c9be6d1d46c526bf70a86791ec1fc555f836'
  version 'develop'

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
    ENV['KS_API_URL'] = "https://develop---keystone-server-esk4nrfqlq-oa.a.run.app"

    system 'ls', "#{prefix}/include"

    Dir.chdir 'cli' do
      system(Formula['go'].bin + 'go',
             'build',
             '-ldflags' ,
             "-X github.com/wearedevx/keystone/cli/pkg/client.ApiURL=#{ENV['KS_API_URL']}",
             "-X github.com/wearedevx/keystone/cli/pkg/client/auth.githubClientId=d253d9fe1adf31b932e9",
             "-X github.com/wearedevx/keystone/cli/pkg/client/auth.githubClientSecret=3b58f72d1f255330ac9079061e6bbb5649ca02c1",
             "-X github.com/wearedevx/keystone/cli/pkg/client/auth.gitlabClientId=d372c2f3eebd9c498b41886667609fbdcf149254bcb618ddc199047cbbc46b78",
             "-X github.com/wearedevx/keystone/cli/pkg/client/auth.gitlabClientSecret=ffe9317fd42d32ea7db24c79f9ee25a3e30637b886f3bc99f951710c8cdc3650",
             '-o',
             'ks')
    end

    bin.install "cli/ks" => "ks"
  end
end

