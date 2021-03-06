#!/bin/bash -xe



grunt docs
grunt bower
pushd HCCGo
npm install
popd
npm test

git config user.name "Automatic Publish"
git config user.email "djw8605@gmail.com"
git clone "${GH_HTTP}" hccgo-dev

cp -r docs/* hccgo-dev/
if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then  
  set +e
  openssl aes-256-cbc -K $encrypted_c3ed45c29343_key -iv $encrypted_c3ed45c29343_iv -in deploy-key.enc -out deploy-key -d
  ssl_out=$?
  set -e
  
  # Do all of the pushing 
  if [ "$ssl_out" -eq "0" ]; then
    echo "Pushing to github"  
    pushd hccgo-dev
    git remote add gh-token "${GH_REF}"
    chmod 600 ../deploy-key
    eval `ssh-agent -s`
    ssh-add ../deploy-key
    git config user.name "Automatic Publish"
    git config user.email "djw8605@gmail.com"
    set +e
    git diff --exit-code
    exit_code=$?
    set -e
    if [ "$exit_code" -ne "0" ]; then
      git add .
      git commit -m "${GIT_NAME}"
      git push gh-token master
    fi
    popd 
  fi
fi

