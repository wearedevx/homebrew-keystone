class Keystone < Formula
  desc 'Securely share application secret with your team'
  homepage 'https://keytone.sh'
  head 'https://github.com/wearedevx/keystone.git', branch: 'develop'
<<<<<<< HEAD
  url 'https://github.com/wearedevx/keystone/develop.tar.gz'
  sha256 '9c219f33f7632182402d24cfecdf15130721baef26d69ac25378c54765d3041b'
=======
  # url 'https://github.com/wearedevx/keystone.git', branch: 'develop', using: 'git'
  sha256 '4dbe8faff569b8992ee091a207367604db468648503e5e6679a4c89e0918d525'
>>>>>>> 526a251b3a5c69c0cb76d60913bec8d2b60027d4

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
<<<<<<< HEAD
    ENV['KS_API_URL'] = "http://localhost:9001"

    system 'ls', "#{prefix}/include"

    Dir.chdir 'cli' do
      system Formula['go'].bin + 'go', 'build', '-ldflags' , "-X github.com/wearedevx/keystone/cli/pkg/client.ApiURL=#{ENV['KS_API_URL']}", '-o', 'ks'
    end

=======
    ENV['KS_API_URL'] = "https://develop---keystone-server-esk4nrfqlq-oa.a.run.app"

    system 'ls', "#{prefix}/include"

    Dir.chdir 'cli' do
      system Formula['go'].bin + 'go', 'build', '-ldflags' , "-X github.com/wearedevx/keystone/cli/pkg/client.ApiURL=#{ENV['KS_API_URL']}", '-o', 'ks'
    end

>>>>>>> 526a251b3a5c69c0cb76d60913bec8d2b60027d4
    bin.install "cli/ks" => "ks"
  end
end


