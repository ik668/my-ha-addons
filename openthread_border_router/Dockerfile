# Derivative image.
#
# Instead of compiling OpenThread/OTBR from source (20-40 minutes), this app
# inherits the official, prebuilt OTBR app image and only overwrites the files
# in rootfs/ - currently just `otbr-agent-configure.sh`, which sets the
# configurable transmit power.
#
# BUILD_FROM is injected by the Supervisor from `build.yaml`.
# To move to a newer upstream version, bump the tag in build.yaml.
#
# The original from-source Dockerfile is kept as `Dockerfile.from-source`.
ARG BUILD_FROM
FROM ${BUILD_FROM}

COPY rootfs/ /
