class Keystone < Formula
  desc 'Securely share application secret with your team'
  homepage 'https://keytone.sh'
  head 'https://github.com/wearedevx/keystone.git', branch: 'develop'
  head 'https://github.com/wearedevx/keystone.git', branch: 'develop', using: 'git'
  sha256 '4dbe8faff569b8992ee091a207367604db468648503e5e6679a4c89e0918d525'

  depends_on 'openssl'

  def install_themis
    system 'git', 'clone', 'https://github.com/cossacklabs/themis.git'
    Dir.chdir 'themis'

    ENV['ENGINE'] = 'openssl'
    ENV['ENGINE_INCLUDE_PATH'] = Formula['openssl'].include
    ENV['ENGINE_LIB_PATH'] = Formula['openssl'].lib
    ENV['PREFIX'] = prefix
    system 'make', 'install'

    Dir.chdir '..'
  end
  
  def install
    install_themis()

    ENV['CGO_ENABLED'] = '1'

    system 'go build -ldflags "-X github.com/wearedevx/keystone/cli/pkg/client.ApiURL=http://localhost:9000" -o ks'
    bin.install "ks" => "ks"
  end
end

