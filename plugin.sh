#!/usr/bin/env bash
set -euo pipefail

name="opa-docker-authz"
version="v0.10.0"
fname="ghcr.io/mikroskeem/${name}"
fnamev2="${fname}-v2"
platforms=(
	"linux/amd64"
	#"linux/arm64"
)

imgname="${name}-${RANDOM}"

[ -d ./plugin ] && rm -rf ./plugin
mkdir -p ./plugin/rootfs
jq -c < ./config.json > ./plugin/config.json

cid=""
cleanup () {
	docker image rm "${imgname}" || true
	(test -n "${cid}" && docker container rm "${cid}") || true
	rm -rf ./plugin || true
}

trap "cleanup" EXIT

docker buildx build --platform="$(IFS=","; echo -n "${platforms[*]}")" -t "${imgname}" .
docker image tag "${imgname}" "${fname}:${version}"

cid="$(docker container create "${imgname}" dummy)"
docker container export "${cid}" | tar -x -C ./plugin/rootfs
docker plugin create "${fnamev2}:${version}" ./plugin
