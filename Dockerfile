FROM ubuntu:22.04

RUN userdel -r ubuntu 2>/dev/null || true

# Setup tailscale
WORKDIR /tailscale.d

RUN apt-get update \
    && apt-get install -y curl ca-certificates iptables iproute2 iputils-ping openssh-server telnet sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /run/sshd \
    && chmod 755 /run/sshd \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    # Disable root login
    && echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    
COPY start.sh /tailscale.d/start.sh

ENV TAILSCALE_VERSION "latest"
ENV TAILSCALE_HOSTNAME "railway-app"
ENV TAILSCALE_ADDITIONAL_ARGS ""

RUN wget https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_amd64.tgz && \
  tar xzf tailscale_${TAILSCALE_VERSION}_amd64.tgz --strip-components=1

RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# Use the Tailscale installation script to add the repository and install the client
# This script handles adding the package signing keys and repository to sources.list.d

RUN chmod +x ./start.sh
CMD ["./start.sh"]
