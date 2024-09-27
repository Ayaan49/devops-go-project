
packages {
  development = ["coreutils-full@9.5", "bash@5.2.15", "go@1.22.3", "gotools@0.18.0", "delve@1.22.1"]
  runtime     = ["cacert@3.95"]
}

gomodule {
  name    = "devops-go-project.git"
  src     = "./."
  ldFlags = null
  tags    = null
  doCheck = false
}

oci "dev" {
  name         = "ttl.sh/gonew/go:demo"
  cmd          = ["devops-go-project.git"]
  envVars = ["foo=bar"]
  exposedPorts = ["8080/tcp"]
}
