FROM ubuntu:26.04

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest
ARG OPENCODE_VERSION=latest
ARG USER=agent
ARG USER_ID=1001

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
RUN adduser $USER && \
  echo " $USER      ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER && \
  mkdir -p /workspaces /home/$USER/.claude /home/$USER/.opencode && \
  chown -R $USER:$USER /workspaces /home/$USER/.opencode /home/$USER/.claude

USER $USER

# Installing devbox
RUN wget --quiet --output-document=/dev/stdout https://get.jetpack.io/devbox   | bash -s -- -f
RUN chown -R "${USER}:${USER}" /usr/local/bin/devbox

# Install Nix
RUN wget --output-document=/dev/stdout https://nixos.org/nix/install | sh -s -- --no-daemon
RUN . ~/.nix-profile/etc/profile.d/nix.sh
# updating PATH
ENV PATH="/home/${USER}/.nix-profile/bin:/home/${USER}/.devbox/nix/profile/default/bin:${PATH}"

# install binary
RUN devbox version

RUN sudo npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} && \
    sudo npm install -g opencode-ai@${OPENCODE_VERSION}

WORKDIR /workspaces

COPY opencode.jsonc /home/$USER/.opencode/
