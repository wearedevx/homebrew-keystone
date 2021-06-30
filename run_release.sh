#/bin/sh

branch=$BRANCH
ksapi_url=$KS_API_URL

TMP_DIR="$(mktemp -d)"

wget "https://github.com/wearedevx/keystone/archive/${branch}.tar.gz" \
	-O "${TMP_DIR}/keystone.tar.gz"

sha256=$(sha256sum "${TMP_DIR}/keystone.tar.gz" | awk '{print $1}')

cp -f $PWD/templates/keystone.template.rb $PWD/Formula/keystone.rb

sed -i "s/<%BRANCH%>/${branch}/g" "$PWD/Formula/keystone.rb"
sed -i "s#<%KS_API_URL%>#${ksapi_url}#g" "$PWD/Formula/keystone.rb"
sed -i "s/<%CHECKSUM%>/${sha256}/g" "$PWD/Formula/keystone.rb"
sed -i "s/<%GITHUB_CLIENT_ID%>/${GITHUB_CLIENT_ID}/g" "$PWD/Formula/keystone.rb"
sed -i "s/<%GITHUB_CLIENT_SECRET%>/${GITHUB_CLIENT_SECRET}/g" "$PWD/Formula/keystone.rb"
sed -i "s/<%GITLAB_CLIENT_ID%>/${GITLAB_CLIENT_ID}/g" "$PWD/Formula/keystone.rb"
sed -i "s/<%GITLAB_CLIENT_SECRET%>/${GITLAB_CLIENT_SECRET}/g" "$PWD/Formula/keystone.rb"
