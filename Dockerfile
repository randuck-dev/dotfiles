FROM ubuntu:latest

RUN apt update && apt install -y \
    neovim git python3.12 wget curl zsh build-essential unzip sudo \
    && apt clean

# Create dev user and add to sudo group
RUN useradd -m -d /home/dev -s /bin/zsh dev && \
    usermod -aG sudo dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY --chown=dev:dev zshrc /home/dev/.zshrc

# Switch to dev user for remaining operations
USER dev

SHELL ["/bin/zsh", "-c"]
WORKDIR /home/dev

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


COPY --chown=dev:dev entrypoint.sh /home/dev/entrypoint.sh
COPY --chown=dev:dev config /home/dev/.config
COPY --chown=dev:dev pkgs /home/dev/pkgs
COPY --chown=dev:dev docker_install.sh /home/dev/docker_install.sh

# we have to install all zsh deps before anything else
RUN /home/dev/pkgs/oh-my-zsh.sh
RUN chmod +x /home/dev/docker_install.sh && source ~/.zshrc && /home/dev/docker_install.sh

WORKDIR /workspace

CMD ["/home/dev/entrypoint.sh"]
