FROM ubuntu:noble

# Avoid user prompts during package installs
ARG DEBIAN_FRONTEND=noninteractive

# Update base image and install Orthanc core + dependencies
RUN apt-get -q --fix-missing update -y && \
    apt-get -q install -y \
        orthanc \
        libssl-dev \
        git \
        mercurial \
        cmake \
        make \
        g++ \
        patch \
        unzip \
        libcurl4-openssl-dev \
        libboost-iostreams-dev \
        libicu-dev

# Expose DICOM and HTTP ports
EXPOSE 11112
EXPOSE 8042

# Create needed folders
RUN mkdir -p /images /root/src /root/keys /root/orthanc-index

# Define architecture and plugin argument
ARG TARGETARCH
ARG indexer

# Set working directory
WORKDIR /root/src

# Copy plugin build script and run it
COPY build_orthanc_indexer.sh .

RUN echo "Using indexer: $indexer" && \
    chmod +x build_orthanc_indexer.sh && \
    ./build_orthanc_indexer.sh "$indexer"

# Optional: Ensure plugin has executable permissions (some plugins need it)
RUN chmod +x libOrthancIndexer.so || true

# Copy all other relevant files (e.g., config)
COPY . .

# Start Orthanc with your config file
CMD ["Orthanc", "/root/src/Configuration.json"]
