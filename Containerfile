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

# ghcr.io/openkaiden/openshell-image-base-builder:next
FROM ghcr.io/openkaiden/openshell-image-base-builder@sha256:27c5cb3411afcd4950ec89308425d54685a7c07b8de094260e8e92c0c9c9e43e AS builder
ARG GOOSE_VERSION=v1.53.0

# Install goose inside the root filesystem
# The musl variant is self-contained: it needs no library from the root filesystem
RUN set -eux; \
    dnf install -y bzip2; \
    cd /tmp; \
    curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh \
      | GOOSE_VERSION="${GOOSE_VERSION}" GOOSE_LINUX_VARIANT=musl GOOSE_BIN_DIR=/mnt/rootfs/usr/local/bin CONFIGURE=false bash; \
    # the binary keeps the owner it has in the release archive
    chown root:root /mnt/rootfs/usr/local/bin/goose

# Now create our final image with reduced layers
FROM scratch
COPY --from=builder /mnt/rootfs/ /
# Do not send usage data
ENV GOOSE_TELEMETRY_ENABLED=false
CMD ["goose"]
