FROM ubuntu:22.04
ARG HANDLE_VERSION
ARG JDK_VERSION

# Update installed APT packages
# Get the handle server package and put it in the container
# Create the working directory for the handle server that will run in the container
# Redirect log files to stdout/stderr
# Install the AWS cli

RUN DEBIAN_FRONTEND=noninteractive apt update && \
    apt install -y curl openjdk-${JDK_VERSION}-jdk-headless python3 wget zip && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    wget -P /tmp http://www.handle.net/hnr-source/handle-${HANDLE_VERSION}-distribution.tar.gz && \
    mkdir -p /opt/handle && tar xf /tmp/handle-${HANDLE_VERSION}-distribution.tar.gz -C /opt/handle --strip-components=1 && \
    mkdir -p /var/handle/svr/logs && \
    ln -sf /dev/stdout /var/handle/svr/logs/access.log && \
    ln -sf /dev/stderr /var/handle/svr/logs/error.log && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws

# Copy over the handle configs & resolver plugin
COPY handle/ /home/handle/
COPY lib/* /opt/handle/lib/
COPY --chmod=755 handle.sh /
COPY --chmod=755 sitebndl.sh /opt/handle/bin/

CMD ["/handle.sh"]
