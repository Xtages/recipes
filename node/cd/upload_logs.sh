S3_LOGS_BUCKET="xtages-infra-logs-${XTAGES_ENV}"
SCRIPTS_PATH=$1
STATUS_CODE=$2
S3_URI="s3://${S3_LOGS_BUCKET}/logs/us-east-1/${XTAGES_ORG_HASH}/${XTAGES_PROJECT}/${XTAGES_APP_ENV}/${XTAGES_BUILD_ID}"

shopt -s nullglob
for file in "${SCRIPTS_PATH}"/*.log
do
  echo "moving ${file} to S3"
  RENAMED_FILE="$(dirname "${file}")/${STATUS_CODE}-$(basename "${file}")"
  mv "${file}" "${RENAMED_FILE}"
  aws s3 mv "${RENAMED_FILE}" "${S3_URI}/${STATUS_CODE}-$(basename "${file}")"
done

