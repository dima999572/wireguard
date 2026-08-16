#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${B2_BUCKET:-}" ]]; then
  echo "ERROR: B2_BUCKET is required (example: export B2_BUCKET=immich-backup-df18)" >&2
  exit 1
fi

if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
  echo "ERROR: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are required." >&2
  exit 1
fi

AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-eu-central-1}"
B2_ENDPOINT="${B2_ENDPOINT:-https://s3.eu-central-003.backblazeb2.com}"
AWS_CLI_IMAGE="${AWS_CLI_IMAGE:-amazon/aws-cli:latest}"

run_aws() {
  docker run --rm \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_DEFAULT_REGION \
    "$AWS_CLI_IMAGE" "$@"
}

to_gib() {
  awk -v n="$1" 'BEGIN { printf "%.2f", n/1024/1024/1024 }'
}

to_gb() {
  awk -v n="$1" 'BEGIN { printf "%.2f", n/1000/1000/1000 }'
}

echo "B2 bucket: $B2_BUCKET"
echo "Endpoint : $B2_ENDPOINT"
echo

current_bytes="$(run_aws s3 ls "s3://$B2_BUCKET" --recursive --summarize --endpoint-url "$B2_ENDPOINT" | awk '/Total Size:/ {print $3}')"

all_versions_lines="$(run_aws s3api list-object-versions \
  --bucket "$B2_BUCKET" \
  --endpoint-url "$B2_ENDPOINT" \
  --query "sum(Versions[].Size)" \
  --output text)"

nonlatest_lines="$(run_aws s3api list-object-versions \
  --bucket "$B2_BUCKET" \
  --endpoint-url "$B2_ENDPOINT" \
  --query "sum(Versions[?IsLatest==\`false\`].Size)" \
  --output text)"

nonlatest_count_lines="$(run_aws s3api list-object-versions \
  --bucket "$B2_BUCKET" \
  --endpoint-url "$B2_ENDPOINT" \
  --query "length(Versions[?IsLatest==\`false\`])" \
  --output text)"

all_versions_bytes="$(echo "$all_versions_lines" | awk '{s+=$1} END{print s+0}')"
nonlatest_bytes="$(echo "$nonlatest_lines" | awk '{s+=$1} END{print s+0}')"
nonlatest_count="$(echo "$nonlatest_count_lines" | awk '{s+=$1} END{print s+0}')"

latest_by_versions="$(( all_versions_bytes - nonlatest_bytes ))"

echo "Current/latest objects (s3 ls):"
printf "  %s bytes | %s GiB | %s GB\n" "$current_bytes" "$(to_gib "$current_bytes")" "$(to_gb "$current_bytes")"
echo

echo "All object versions (s3api list-object-versions):"
printf "  %s bytes | %s GiB | %s GB\n" "$all_versions_bytes" "$(to_gib "$all_versions_bytes")" "$(to_gb "$all_versions_bytes")"
echo

echo "Non-latest versions only:"
printf "  %s bytes | %s GiB | %s GB\n" "$nonlatest_bytes" "$(to_gib "$nonlatest_bytes")" "$(to_gb "$nonlatest_bytes")"
printf "  %s objects\n" "$nonlatest_count"
echo

echo "Latest-only bytes computed from versions:"
printf "  %s bytes | %s GiB | %s GB\n" "$latest_by_versions" "$(to_gib "$latest_by_versions")" "$(to_gb "$latest_by_versions")"
