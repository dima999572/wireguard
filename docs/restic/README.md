# Restic vs Backblaze B2 Size Difference

This note explains a common confusion:

- Restic shows about 20 GiB
- Backblaze UI shows about 32.7 GB

Both can be correct at the same time.

## Why numbers differ

Restic reports active repository data.

- `restic stats --mode raw-data` shows logical data referenced by current snapshots.
- `restic prune --dry-run` tells whether repo-internal garbage can be removed.

Backblaze bucket UI can include more than active data.

- Current/latest object versions
- Non-latest (old) object versions
- Incomplete multipart uploads (if any)

So UI usage can be higher even when Restic is healthy and prune removes nothing.

## What happened in our case

Measured values:

- All object versions: `32669617768` bytes
- Non-latest versions only: `11276516966` bytes

This means the extra space is mostly old object versions, not active Restic data.

## Verify with Docker AWS CLI (no local install)

Quick option from this repository:

```bash
# Required env vars:
export AWS_ACCESS_KEY_ID=YOUR_B2_KEY_ID
export AWS_SECRET_ACCESS_KEY=YOUR_B2_APP_KEY

# Optional (defaults are set in script):
export AWS_DEFAULT_REGION=eu-central-1
export B2_ENDPOINT=https://s3.eu-central-003.backblazeb2.com

# Run via Make target:
B2_BUCKET=YOUR_B2_BUCKET_NAME make b2-size-check

# Or run directly:
B2_BUCKET=YOUR_B2_BUCKET_NAME ./scripts/b2_size_check.sh
```

The script prints:

- Current/latest object bytes (`aws s3 ls`)
- All-version bytes (`list-object-versions`)
- Non-latest version bytes and object count
- Latest-only bytes computed from all-version minus non-latest

Set credentials in your shell first:

```bash
export AWS_ACCESS_KEY_ID=YOUR_B2_KEY_ID
export AWS_SECRET_ACCESS_KEY=YOUR_B2_APP_KEY
export AWS_DEFAULT_REGION=eu-central-1
```

Check current/latest objects only:

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION \
  amazon/aws-cli:2 \
  s3 ls s3://YOUR_BUCKET --recursive --summarize \
  --endpoint-url https://s3.eu-central-003.backblazeb2.com
```

Check all versions total bytes (sum pages):

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION \
  amazon/aws-cli:2 \
  s3api list-object-versions \
  --bucket YOUR_BUCKET \
  --endpoint-url https://s3.eu-central-003.backblazeb2.com \
  --query "sum(Versions[].Size)" --output text | awk '{s+=$1} END{print s}'
```

Check non-latest versions bytes (sum pages):

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION \
  amazon/aws-cli:2 \
  s3api list-object-versions \
  --bucket YOUR_BUCKET \
  --endpoint-url https://s3.eu-central-003.backblazeb2.com \
  --query "sum(Versions[?IsLatest==\`false\`].Size)" --output text | awk '{s+=$1} END{print s}'
```


