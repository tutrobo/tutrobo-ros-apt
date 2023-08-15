#!/bin/bash

shopt -s nullglob

CODENAMES=$(scripts/conf.sh codenames)
SIGN_WITH=$(scripts/conf.sh sign_with)

for codename in $CODENAMES; do
  # generate apt repository
  reprepro --outdir $(pwd)/public export $codename
  for deb_path in debs/$codename/*.deb; do
    reprepro --outdir $(pwd)/public includedeb $codename $deb_path
  done

  # generate rosdep.yaml
  for apt_name in $(reprepro --list-format '${package}\n' list $codename); do
    rosdep_name=${apt_name#ros-humble-}
    rosdep_name=${rosdep_name//-/_}
    echo -e "$rosdep_name:\n  ubuntu: [$apt_name]"
  done > public/rosdep.yaml
done

# generate index.html
echo "<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css">
    <title>$GITHUB_REPO_NAME</title>
  </head>
  <body>
    <main class="container">
      <h1>$GITHUB_REPO_NAME</h1>
      <h2>Add a Repository</h2>
      <pre><code>sudo curl -sSL $GITHUB_PAGES_URL/$GITHUB_REPO_NAME.key -o /usr/share/keyrings/$GITHUB_REPO_NAME.gpg
echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/$GITHUB_REPO_NAME.gpg] $GITHUB_PAGES_URL \$(. /etc/os-release && echo \$UBUNTU_CODENAME) main\" | sudo tee /etc/apt/sources.list.d/$GITHUB_REPO_NAME.list > /dev/null
echo \"yaml $GITHUB_PAGES_URL/rosdep.yaml\" | sudo tee /etc/ros/rosdep/sources.list.d/99-$GITHUB_REPO_NAME.list > /dev/null
sudo apt update && rosdep update</code></pre>
      <h2>All Packages</h2>
      <pre><code>$(for codename in $CODENAMES; do reprepro list $codename; done)</code></pre>
    </main>
  </body>
</html>" > public/index.html

# export gpg public key
gpg -o public/$GITHUB_REPO_NAME.key --export $SIGN_WITH
