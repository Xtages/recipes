#SCRIPT_DIR=$(dirname "${0}")
#RECIPES_BASE_PATH="$PWD"
#SCRIPTS_PATH="${RECIPES_BASE_PATH}/${SCRIPT_DIR}"/
#
#echo "reporting metric for docker"
#XTAGES_ORG="ad85be32aa233b7226d34a91cf66b044" XTAGES_PROJECT="6fa68232c5ec330744b2004ac7da774d" XTAGES_APP_ENV="staging" sh -x "${SCRIPTS_PATH}"/metrics.sh "docker" "1" "build=start"
#echo  "reported"
shopt -s nullglob
for file in *.sh
do
  basename "${file}"
done
