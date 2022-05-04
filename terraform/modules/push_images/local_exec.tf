data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "null_resource" "docker_push" {
  # TODO: create a dynamic trigger for this...connection
  # provisioner "local-exec" {
  #   command = coalesce("git","describe", "--tags" ,"--always")
  #   working_dir = ".."
  #   interpreter = ["bash", "-c"]
  # }
  # provisioner "local-exec" {
  #   command = coalesce("make", "build-containers-docker-compose", "AWS_ACCOUNT_ID=${data.aws_caller_identity.current.account_id}","AWS_REGION=${data.aws_region.current.name}")
  #   working_dir = ".."
  #   interpreter = ["bash", "-c"]
  # }
}