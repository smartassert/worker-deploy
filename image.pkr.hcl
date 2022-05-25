
variable "digitalocean_api_token" {
  type      = string
  sensitive = true
  default = env("DIGITALOCEAN_API_TOKEN")

  validation {
    condition     = length(var.digitalocean_api_token) > 0
    error_message = "DigitalOcean API token is required."
  }
}

variable "snapshot_name" {
  type = string
  default = env("SNAPSHOT_NAME")

  validation {
    condition     = length(var.snapshot_name) > 0
    error_message = "Snapshot name is required."
  }
}

variable "compiler_version" {
  type = string
  default = env("COMPILER_VERSION")

  validation {
    condition     = length(var.compiler_version) > 0
    error_message = "Compiler version is required."
  }
}

variable "chrome_runner_version" {
  type = string
  default = env("CHROME_RUNNER_VERSION")

  validation {
    condition     = length(var.chrome_runner_version) > 0
    error_message = "Chrome runner version is required."
  }
}

variable "firefox_runner_version" {
  type = string
  default = env("FIREFOX_RUNNER_VERSION")

  validation {
    condition     = length(var.firefox_runner_version) > 0
    error_message = "Firefox runner version is required."
  }
}

variable "delegator_version" {
  type = string
  default = env("DELEGATOR_VERSION")

  validation {
    condition     = length(var.delegator_version) > 0
    error_message = "Delegator version is required."
  }
}

variable "worker_version" {
  type = string
  default = env("WORKER_VERSION")

  validation {
    condition     = length(var.worker_version) > 0
    error_message = "Worker version is required."
  }
}

source "digitalocean" "worker_base" {
  api_token     = "${var.digitalocean_api_token}"
  image         = "ubuntu-22-04-x64"
  region        = "lon1"
  size          = "s-1vcpu-1gb"
  snapshot_name = "worker-${var.snapshot_name}"
  ssh_username  = "root"
  temporary_key_pair_type = "ed25519"
}

build {
  sources = ["source.digitalocean.worker_base"]

  # Copy system files and provision for use
  provisioner "file" {
    destination = "~/docker-compose.yml"
    source      = "docker-compose.yml"
  }

  provisioner "file" {
    destination = "~/.env"
    source      = ".env"
  }

  provisioner "shell" {
    inline = ["mkdir -p ~/caddy"]
  }

  provisioner "file" {
    destination = "~/caddy/"
    sources = [
      "${path.root}/caddy/Caddyfile",
      "${path.root}/caddy/index.php"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "LOCAL_SOURCE_PATH=/var/basil/source",
      "COMPILER_VERSION=${var.compiler_version}",
      "CHROME_RUNNER_VERSION=${var.chrome_runner_version}",
      "FIREFOX_RUNNER_VERSION=${var.firefox_runner_version}",
      "DELEGATOR_VERSION=${var.delegator_version}",
      "WORKER_VERSION=${var.worker_version}",
    ]
    scripts = ["./provision.sh"]
  }

  # Copy docker services self-test files and run docker services self-test process
  provisioner "shell" {
    inline = ["mkdir -p ~/self-test"]
  }

  provisioner "file" {
    destination = "~/self-test/fixtures"
    source      = "self-test/fixtures"
  }

  provisioner "shell" {
    scripts = ["./self-test/docker-compose-services.sh"]
  }

  provisioner "shell" {
    environment_vars = ["BROWSER=chrome"]
    scripts          = ["./self-test/delegator.sh"]
  }

  provisioner "shell" {
    environment_vars = ["BROWSER=firefox"]
    scripts          = ["./self-test/delegator.sh"]
  }

  # Copy app self-test files and run app self-test process
  provisioner "shell" {
    inline = ["mkdir -p ~/self-test/app"]
  }

  provisioner "file" {
    destination = "~/self-test/app/composer.json"
    source      = "self-test/app/composer.json"
  }

  provisioner "file" {
    destination = "~/self-test/app/src"
    source      = "self-test/app/src"
  }

  provisioner "file" {
    destination = "~/self-test/services.yml"
    source      = "self-test/services.yml"
  }

#  provisioner "shell" {
#    environment_vars = [
#      "LOCAL_SOURCE_PATH=/var/basil/source",
#      "COMPILER_VERSION=${var.compiler_version}",
#      "CHROME_RUNNER_VERSION=${var.chrome_runner_version}",
#      "FIREFOX_RUNNER_VERSION=${var.firefox_runner_version}",
#      "DELEGATOR_VERSION=${var.delegator_version}",
#      "WORKER_VERSION=${var.worker_version}",
#    ]
#    scripts = ["./self-test/app.sh"]
#  }

}
