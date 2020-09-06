variable "gcp_regions" {
  type = list(string)
  default = ["us-central1","us-east1","us-east4","europe-west1","europe-west2","asia-east2","asia-northeast1","asia-northeast2","europe-west3","europe-west6","us-west3","northamerica-northeast1","australia-southeast1","us-west2","us-west4","southamerica-east1","asia-south1","asia-southeast2","asia-northeast3"]
}
variable "project_name" {
  default = "prodapp1-214321"
}

// Google Cloud provider & Beta
provider "google" {
  project = var.project_name
}
provider "google-beta" {
  project = var.project_name
}

# Create Bucket for code & Upload it

resource "google_storage_bucket" "bucket" {
  name = "rgreaves-code"
}

resource "google_storage_bucket_object" "archive" {
  name   = "Archive.zip"
  bucket = google_storage_bucket.bucket.name
  source = "../Archive.zip"
}


# Create cloud functions per region
resource "google_cloudfunctions_function" "function" {
  description = "Regional speciic function"
  runtime     = "python37"
  for_each = toset(var.gcp_regions)
  name = format("region-test-%s", each.key)
  region  = each.key

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  timeout               = 60
  entry_point           = "MyApp"

}

# Assign permissions to allow anon invocation
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_name
  for_each = toset(var.gcp_regions)
  region         = each.key
  cloud_function = format("region-test-%s", each.key)

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

# Get a static IP:
resource "google_compute_global_address" "default" {
  name = "global-appserver-ip"
  description = "To be used by Global LB"
}

#google_compute_address.static.address