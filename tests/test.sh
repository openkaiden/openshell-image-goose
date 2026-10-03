#!/usr/bin/env bash
#
# Copyright (C) 2026 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

# Smoke test of the built image, run by the shared oci-image workflow once per platform.
# IMAGE and PLATFORM are provided by the workflow.
set -euo pipefail

expected=$(sed -n 's/^ARG GOOSE_VERSION=v//p' Containerfile)
# goose prints its version with a leading space
version=$(podman run --rm --platform "${PLATFORM}" "${IMAGE}" goose --version | tr -d '[:space:]')
echo "goose --version: ${version}"
[[ "${version}" == "${expected}" ]] || { echo "::error::expected ${expected}, got ${version}"; exit 1; }

# ACP initialize request. Keep the input open until the response is there, so that the
# agent is not stopped by the end of its input before it answers.
workdir=$(mktemp -d)
trap 'rm -rf "${workdir}"' EXIT
mkfifo "${workdir}/stdin"
timeout 120 podman run --rm -i --platform "${PLATFORM}" "${IMAGE}" goose acp < "${workdir}/stdin" > "${workdir}/stdout" &
exec 3> "${workdir}/stdin"
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":1,"clientCapabilities":{}}}' >&3

is_initialized() { jq -se 'any(.[]; .id == 1 and .result.protocolVersion == 1)' "${workdir}/stdout" > /dev/null 2>&1; }
for _ in $(seq 90); do
  is_initialized && break
  sleep 1
done
exec 3>&-
wait

echo "ACP response: $(cat "${workdir}/stdout")"
is_initialized || { echo "::error::invalid ACP initialize response"; exit 1; }
