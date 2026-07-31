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

ARG BASE_IMAGE=ghcr.io/nvidia/openshell-community/sandboxes/base@sha256:aeef1c63f00e2913ea002ccb3aaf925f338b5c5d70e63576f0d95c16a138044e
FROM ${BASE_IMAGE}

USER root

RUN cd /tmp && curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | GOOSE_VERSION=v1.45.0 GOOSE_BIN_DIR=/usr/local/bin CONFIGURE=false bash

RUN mkdir -p /sandbox/.config/goose && \
    echo 'GOOSE_TELEMETRY_ENABLED: false' > /sandbox/.config/goose/config.yaml && \
    chown -R sandbox:sandbox /sandbox/.config/goose

USER sandbox

ENTRYPOINT ["/bin/bash"]
