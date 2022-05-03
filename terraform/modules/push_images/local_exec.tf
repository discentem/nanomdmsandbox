data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "null_resource" "docker_push" {
  provisioner "local-exec" {
     command     = "${coalesce("make", "build-containers-docker-compose", "AWS_ACCOUNT_ID=${data.aws_caller_identity.current.account_id}","AWS_REGION=${data.aws_region.current.name}")}"
     interpreter = ["bash", "-c"]
  }
}