#!/bin/bash

echo "--- dependencies"
. .expeditor/buildkite/cache_support.sh
install_cache_deps sudo

# echo "install github cli if not present"
# if ! command -v gh; then
#   echo "--- installing github cli"
#   sudo apt-get update
#   sudo apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl gnupg lsb-release
#   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
#   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
#   sudo apt-get update
#   sudo apt-get install -y --no-install-recommends gh
# fi

# echo "--- setting up github cli"
# gh config set prompt disabled
# gh config set git_protocol ssh

# echo "--- list secrets"
# gh secret list -a "actions"


echo "--- check if git is installed and configured"
git config --list


echo "--- setting up user"
export LANG=C.UTF-8 LANGUAGE=C.UTF-8
useradd -m -U --uid 2000 normal
echo "normal ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/normal

echo "--- updating rubygems"
gem update -N --system 3.3.3 --force

echo "--- system details"
uname -a
gem env
bundle --version
mount
df /tmp
echo ${TMPDIR:-unknown}

if [ -n "${CI_ENABLE_COVERAGE:-}" ]; then
  # Fetch token from vault ASAP so that long-running tests don't cause our vault token to expire
  echo "--- installing vault"
  export VAULT_VERSION=1.9.3
  export VAULT_HOME=$HOME/vault
  curl --create-dirs -sSLo $VAULT_HOME/vault.zip https://releases.hashicorp.com/vault/$VAULT_VERSION/vault_${VAULT_VERSION}_linux_amd64.zip
  unzip -o $VAULT_HOME/vault.zip -d $VAULT_HOME

  echo "--- fetching Sonar token from vault"
  export SONAR_TOKEN=$($VAULT_HOME/vault kv get -field token secret/inspec/sonar)
fi

echo "--- pull bundle cache"
pull_bundle

echo "--- bundle"
bundle config --local path vendor/bundle
bundle config set --local without deploy kitchen
bundle install --jobs=7 --retry=3

echo "--- push bundle cache"
push_bundle

echo "+++ bundle exec rake ${RAKE_TASK:-}"
# TODO: run this as non-root:
# chown -R normal:normal /home/normal /workdir
# su normal -c "bundle exec rake ${RAKE_TASK:-}"
# shellcheck disable=SC2086
bundle exec rake ${RAKE_TASK:-}
RAKE_EXIT=$?

# If coverage is enabled, then we need to pick up the coverage/coverage.json file
if [ -n "${CI_ENABLE_COVERAGE:-}" ]; then
  echo "--- installing sonarscanner"
  export SONAR_SCANNER_VERSION=4.6.2.2472
  export SONAR_SCANNER_HOME=$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux
  curl --create-dirs -sSLo $HOME/.sonar/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip
  unzip -o $HOME/.sonar/sonar-scanner.zip -d $HOME/.sonar/
  export PATH=$SONAR_SCANNER_HOME/bin:$PATH
  export SONAR_SCANNER_OPTS="-server"

  # Delete the vendor/ directory. I've tried to exclude it using sonar.exclusions,
  # but that appears to get ignored, and we end up analyzing the gemfile install
  # which blows our analysis.
  echo "--- deleting installed gems"
  rm -rf vendor/

  # See sonar-project.properties for additional settings
  echo "--- running sonarscanner"
  sonar-scanner \
  -Dsonar.sources=. \
  -Dsonar.host.url=https://sonarcloud.io
fi

exit $RAKE_EXIT
