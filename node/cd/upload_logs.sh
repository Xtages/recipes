S3_LOGS_BUCKET="xtages-infra-logs-${XTAGES_ENV}"

S3_URI="s3://${S3_LOGS_BUCKET}/logs/us-east-1/${XTAGES_ORG}/${XTAGES_PROJECT}/${XTAGES_APP_ENV}/${XTAGES_BUILD_ID}"

shopt -s nullglob
for file in *.log
do
  aws mv "${file}" "${S3_URI}"
done

