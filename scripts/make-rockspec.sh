#!/usr/bin/env bash

set -euo pipefail

declare package="${INPUT_NAME:-}"

if test -z "${package}"; then
  package="${GITHUB_REPOSITORY##*/}"
fi

declare -r repo_rockspec="${package}.rockspec"

if ! test -f "${repo_rockspec}"; then
  echo "missing rockspec: ${repo_rockspec}" >&2
  exit 1
fi

if ! cat "${repo_rockspec}" | grep --silent '^version *= *"dev"'; then
  echo "invalid rockspec, missing: version = \"dev\"" >&2
  exit 1
fi

if ! cat "${repo_rockspec}" | grep --silent '^ *tag *= *nil'; then
  echo "invalid rockspec, missing: tag = nil" >&2
  exit 1
fi

if [[ "${GITHUB_REF_NAME}" != "${INPUT_DEV_REF}" ]] && [[ "${GITHUB_REF_TYPE}" != "tag" ]]; then
  echo "unexpected \$GITHUB_REF_TYPE: ${GITHUB_REF_TYPE}, expected 'tag'" >&2
  exit 1
fi

declare version="${GITHUB_REF_NAME}"

if [[ "${version}" = "${INPUT_DEV_REF}" ]]; then
  version="dev"
elif [[ "${GITHUB_REF_TYPE}" = "tag" ]]; then
  version="${version#v}"
fi

if [[ -z "${version}" ]]; then
  echo "missing version" >&2
  exit 1
fi

declare rockspec_version="${version}"

if [[ "${version}" = *"-"* ]]; then
  version="${version%%-*}"
else
  rockspec_version="${version}-1"
fi

declare -r rockspec="${package}-${rockspec_version}.rockspec"

cp "${repo_rockspec}" "${rockspec}"

script="/^version/s|\"[^\"]\\+\"|\"${rockspec_version}\"|"
sed -e "${script}" -i "${rockspec}"

if [[ "${GITHUB_REF_TYPE}" = "tag" ]]; then
  script="/^ \\+tag/s|nil|\"${GITHUB_REF_NAME}\"|"
fi
sed -e "${script}" -i "${rockspec}"

echo "--[[ START: ${rockspec} ]]"
echo
cat "${rockspec}"
echo
echo "--[[   END: ${rockspec} ]]"
