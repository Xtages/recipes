S3_LOGS_BUCKET="xtages-infra-logs-${XTAGES_ENV}"
STATUS_CODE=$1
S3_URI="s3://${S3_LOGS_BUCKET}/logs/us-east-1/${XTAGES_ORG_HASH}/${XTAGES_PROJECT}/${XTAGES_APP_ENV}/${XTAGES_BUILD_ID}"

shopt -s nullglob
for file in *.log
do
  mv "${file}" "${STATUS_CODE}_${file}"
  aws s3 mv "${STATUS_CODE}_${file}" "${S3_URI}/${STATUS_CODE}_${file}"
done

