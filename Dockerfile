FROM ubuntu:26.04

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest
ARG OPENCODE_VERSION=latest
ENV AGENT_USER=agent

# Install basic development tools and iptables/ipset
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  binutils \
  fzf \
  gh \
  git \
  gnupg2 \
  jq \
  less \
  man-db \
  neovim \
  nodejs \
  npm \
  procps \
  sudo \
  unzip \
  wget \
  xz-utils \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# User setup
RUN adduser $AGENT_USER && \
  usermod -aG sudo $AGENT_USER && \
  echo " agent      ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$AGENT_USER && \
  mkdir -p /workspace /home/$AGENT_USER/.claude /home/$AGENT_USER/.opencode && \
  chown -R $AGENT_USER:$AGENT_USER /workspace /home/$AGENT_USER/.opencode /home/$AGENT_USER/.claude

USER $AGENT_USER

# Installing devbox
RUN wget --quiet --output-document=/dev/stdout https://get.jetpack.io/devbox   | bash -s -- -f
RUN chown -R "${AGENT_USER}:${AGENT_USER}" /usr/local/bin/devbox

# Install Nix
RUN wget --output-document=/dev/stdout https://nixos.org/nix/install | sh -s -- --no-daemon
RUN . ~/.nix-profile/etc/profile.d/nix.sh
# updating PATH
ENV PATH="/home/${AGENT_USER}/.nix-profile/bin:/home/${AGENT_USER}/.devbox/nix/profile/default/bin:${PATH}"

RUN sudo npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} && \
    sudo npm install -g opencode-ai@${OPENCODE_VERSION}

WORKDIR /workspace
USER $AGENT_USER

COPY opencode.jsonc /home/$AGENT_USER/.opencode/
