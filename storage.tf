module "gcs_buckets" {
  source     = "terraform-google-modules/cloud-storage/google"
  project_id = var.google_project_id
  names      = ["bucket-1"]
  prefix     = ""
  labels = {
    team  = "team-z"
    env   = "dev"
    owner = "me"
  }
}

# module "gcs_buckets2" {
#   source     = "terraform-google-modules/cloud-storage/google"
#   project_id = var.google_project_id
#   names      = ["bucket-missing-team-label"]
#   prefix     = ""
#   labels = {
#     team = "my team" # Invalid team name
#   }
# }

# module "gcs_buckets3" {
#   source     = "terraform-google-modules/cloud-storage/google"
#   project_id = var.google_project_id
#   names      = ["bucket-name-too-long-012345678901234567890123456789012345678901234567890"] # Bucket name too long
#   prefix     = ""
#   labels = {
#     team = "my team" # Invalid team name
#   }
# }