# ros-apt-template

1. Generate GPG key without passphrase
1. Upload GPG private key to `${{ secrets.GPG_PRIVATE_KEY }}`
1. Edit `conf/distributions`
1. Add `.deb` files to `debs/[codename]/*.deb`
