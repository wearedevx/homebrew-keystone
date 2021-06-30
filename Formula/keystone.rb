class Keystone < Formula
  desc 'Securely share application secret with your team'
  homepage 'https://keytone.sh'
  head 'https://github.com/wearedevx/keystone.git', branch: 'develop'
  url 'https://github.com/wearedevx/keystone/develop.tar.gz'
  sha256 'c4c74dcaaf24401c73d688f0e53c47687080324f6ae60609d16a5dd1f7288da6'
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
      system Formula['go'].bin + 'go', 'build', '-ldflags' , "-X github.com/wearedevx/keystone/cli/pkg/client.ApiURL=#{ENV['KS_API_URL']}", '-o', 'ks'
    end

    bin.install "cli/ks" => "ks"
  end
end

