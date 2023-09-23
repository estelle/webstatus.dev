locals {
  service_dir = "workflows/steps/services/common/repo_downloader"
}
resource "docker_image" "repo_downloader_image" {
  name = "${var.docker_repository_details.url}/repo_downloader_image"
  build {
    context = "${path.cwd}/.."
    build_args = {
      service_dir : local.service_dir
    }
    dockerfile = "images/go_service.Dockerfile"
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.cwd, "/../${local.service_dir}/**") : filesha1(f)], [for f in fileset(path.cwd, "/../lib/**") : filesha1(f)]))
  }
}
resource "docker_registry_image" "repo_downloader_remote_image" {
  name          = docker_image.repo_downloader_image.name
  keep_remotely = true
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.cwd, "/../${local.service_dir}/**") : filesha1(f)], [for f in fileset(path.cwd, "/../lib/**") : filesha1(f)]))
  }
}

resource "google_storage_bucket_iam_member" "binding" {
  bucket = var.repo_bucket
  role   = "roles/storage.objectUser"
  member = google_service_account.service_account.member
}

resource "google_secret_manager_secret_iam_member" "binding" {
  secret_id = data.google_secret_manager_secret.github_token.id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.service_account.member
}

resource "google_service_account" "service_account" {
  account_id   = "repo-downloader-${var.env_id}"
  display_name = "Repo Downloader service account for ${var.env_id}"
}

data "google_secret_manager_secret" "github_token" {
  secret_id = var.github_token_secret_id
}

resource "google_cloud_run_v2_service" "service" {
  count    = length(var.regions)
  name     = "${var.env_id}-${var.regions[count.index]}-repo-downloader-srv"
  location = var.regions[count.index]

  template {
    containers {
      image = "${docker_image.repo_downloader_image.name}@${docker_registry_image.repo_downloader_remote_image.sha256_digest}"
      env {
        name = "GITHUB_TOKEN"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.github_token.id
            version = "latest"
          }
        }
      }
      env {
        name  = "BUCKET"
        value = var.repo_bucket
      }
    }
    service_account = google_service_account.service_account.email
  }
  depends_on = [
    google_storage_bucket_iam_member.binding,
    google_secret_manager_secret_iam_member.binding
  ]
}