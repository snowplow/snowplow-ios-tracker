parent=$(dirname `pwd`)
cat >./Cartfile <<EOF
git "file://${parent}"
EOF
