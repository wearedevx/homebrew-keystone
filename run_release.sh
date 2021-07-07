#/bin/sh

TMP_DIR="$(mktemp -d)"

wget "https://github.com/wearedevx/keystone/archive/${BRANCH}.tar.gz" \
	-O "${TMP_DIR}/keystone.tar.gz"

sha256=$(sha256sum "${TMP_DIR}/keystone.tar.gz" | awk '{print $1}')

if [ "$KSAPI_URL" == "" ]; then
	echo 'No valid API Url'
	exit 1
fi

if [ "$BRANCH" == "" ]; then
	echo 'Invalid branch'
	exit 1
fi

if [ "$GITHUB_CLIENT_ID" == '' ]; then
	echo 'Invalid Github client id'
	exit 1
fi

if [ "$GITHUB_CLIENT_SECRET" == '' ]; then
	echo 'Invalid Github client secret'
	exit 1
fi

if [ "$GITLAB_CLIENT_ID" == '' ]; then
	echo 'Invalid GitLab client id'
	exit 1
fi

if [ "$GITLAB_CLIENT_SECRET" == '' ]; then
	echo 'Invalid GitLaab client secret'
	exit 1
fi

function apply_template() {
	if [[ -z "$SED" ]]; then
		SED=sed		 
	fi

	suffix=$1
	if [ "$suffix" != "" ]; then
		suffix="@${suffix}"
	fi

	target="$PWD/Formula/keystone${suffix}.rb"

	cp -f $PWD/templates/keystone.template.rb $target

	$SED -i "s/<%BRANCH%>/${BRANCH}/g" $target
	$SED -i "s/<%VERSION%>/${VERSION}/g" $target

	$SED -i "s#<%KSAPI_URL%>#${KSAPI_URL}#g" $target
	$SED -i "s#<%AUTH_PROXY%>#${AUTH_PROXY}#g" $target

	$SED -i "s/<%CHECKSUM%>/${sha256}/g" $target
	$SED -i "s/<%GITHUB_CLIENT_ID%>/${GITHUB_CLIENT_ID}/g" $target
	$SED -i "s/<%GITHUB_CLIENT_SECRET%>/${GITHUB_CLIENT_SECRET}/g" $target
	$SED -i "s/<%GITLAB_CLIENT_ID%>/${GITLAB_CLIENT_ID}/g" $target
	$SED -i "s/<%GITLAB_CLIENT_SECRET%>/${GITLAB_CLIENT_SECRET}/g" $target
}

# Latest
# Only if it is not a develop release
if [ "$BRANCH" != "develop" ]; then
	apply_template ""
fi

# Versioned
# So that a user can install a specific
# keystone version
apply_template $BRANCH
