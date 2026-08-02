resource "random_id" "bucket_suffix" {
  byte_length = 2
}

resource "b2_bucket" "immich_backup" {
  bucket_name = "immich-backup-${random_id.bucket_suffix.hex}"
  bucket_type = "allPrivate"

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rules {
    file_name_prefix              = ""
    days_from_hiding_to_deleting  = 1
    days_from_uploading_to_hiding = null
  }
}

resource "b2_application_key" "pi_backup_key" {
  key_name   = "pi-5-append-only"
  bucket_ids = [b2_bucket.immich_backup.bucket_id]
  capabilities = [
    "listBuckets",
    "listFiles",
    "readFiles",
    "writeFiles"
  ]
}
