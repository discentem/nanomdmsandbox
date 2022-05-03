workspace(name = "nanomdm")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "io_bazel_rules_go",
    url = "https://github.com/bazelbuild/rules_go/releases/download/0.15.1/rules_go-0.15.1.tar.gz",
    sha256 = "5f3b0304cdf0c505ec9e5b3c4fc4a87b5ca21b13d8ecc780c97df3d1809b9ce6",
)

http_archive(
    name = "bazel_gazelle",
    urls = ["https://github.com/bazelbuild/bazel-gazelle/releases/download/0.14.0/bazel-gazelle-0.14.0.tar.gz"],
    sha256 = "c0a5739d12c6d05b6c1ad56f2200cb0b57c5a70e03ebd2f7b87ce88cabf09c7b",
)

load(
    "@io_bazel_rules_go//go:def.bzl", 
    "go_rules_dependencies", 
    "go_register_toolchains",
)

go_rules_dependencies()

go_register_toolchains()

gazelle_dependencies()

load(
    "@bazel_gazelle//:deps.bzl",
    "gazelle_dependencies",
    "go_repository",
)

git_repository(
    name = "io_bazel_rules_go",
    remote = "https://github.com/bazelbuild/rules_go.git",
    commit = "373feb6",
)

load("@io_bazel_rules_go//go:def.bzl", "go_repositories")

go_repositories()

git_repository(
  name = "nanomdm_remote",
  remote = "https://github.com/micromdm/nanomdm.git",
  commit = "56c9b7e2178772c551e59ea716f6ce6c8130f10f",
)


BARE_BUILD = """
load("@io_bazel_rules_go//go:def.bzl", "go_prefix", "go_library")

go_prefix("https://github.com/micromdm/nanomdm/cmd/nanomdm")

go_library(
    name = "main",
    srcs = [ "main.go" ],
    visibility = ["//visibility:public"],
)

"""

new_git_repository(
  name = "nanomdm_bare",
  remote = "https://github.com/micromdm/nanomdm.git",
  commit = "56c9b7e2178772c551e59ea716f6ce6c8130f10f",
  build_file_content = BARE_BUILD
)