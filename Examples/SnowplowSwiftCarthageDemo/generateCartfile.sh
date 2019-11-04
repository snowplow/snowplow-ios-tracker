parent=$(dirname "$(dirname `pwd`)")
branch=$(git rev-parse --abbrev-ref HEAD)

cat >./Cartfile <<EOF
git "file://${parent}" "${branch}"
EOF
