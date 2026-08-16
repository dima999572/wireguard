# Restic Restore Guide and Restore Test

This document explains how to validate that your backups are actually restorable.

## Prerequisites

- `restic` installed on the host where you run restore checks
- access to the same repository credentials used for backup
- enough free disk space for restore target

Example required environment variables:

```bash
export AWS_ACCESS_KEY_ID=YOUR_B2_KEY_ID
export AWS_SECRET_ACCESS_KEY=YOUR_B2_APP_KEY
export RESTIC_REPOSITORY=s3:s3.eu-central-003.backblazeb2.com/YOUR_B2_BUCKET_NAME/immich-repo
export RESTIC_PASSWORD=YOUR_RESTIC_PASSWORD
```

## Quick health checks (before restore)

```bash
restic snapshots
restic stats --mode raw-data
restic check --read-data-subset=1/20
```

Expected result:

- snapshots list is present and recent
- `restic check` ends with `no errors were found`

## Restore smoke test

Use a dedicated temporary folder. Do not restore over production data.

```bash
sudo mkdir -p /tmp/restic-restore-test
restic restore latest --target /tmp/restic-restore-test
```

Validate key paths exist:

```bash
ls -lah /tmp/restic-restore-test/srv/immich
```

Check a few random files open correctly:

- one small photo
- one larger media file
- one recent file

## File integrity spot-check

Compare checksums between source and restored files for several samples.

```bash
sha256sum /srv/immich/library/upload/path/to/file.jpg
sha256sum /tmp/restic-restore-test/srv/immich/library/upload/path/to/file.jpg
```

Checksums should match exactly.

## Simulated disk-loss recovery test (recommended)

Run this periodically (for example quarterly):

1. Restore to a clean location (not production path)
2. Point a test Immich instance to restored data
3. Verify files are readable and expected content appears

This is the strongest confidence test without touching production.

## Cleanup after test

```bash
sudo rm -rf /tmp/restic-restore-test
```

