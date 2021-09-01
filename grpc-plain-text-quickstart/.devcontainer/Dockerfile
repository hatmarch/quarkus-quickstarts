#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM python:3

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Or your actual UID, GID on Linux if not the default 1000
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG GRAALVM_RELEASE_URL="https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.2.0/graalvm-ce-java11-linux-amd64-21.2.0.tar.gz"
ARG GRAALVM_BASEDIR="/usr/local/lib"
ARG GRAALVM_MAINDIR="graalvm"

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    # NOTE: groff is necessary for aws cli support
    # NOTE: openjdk is not necessary as it will packaged with graal
    && apt-get -y install maven groff git less jq procps lsb-release rsync zsh zplug apt-transport-https ca-certificates curl gnupg \
    #
    # Install pylint
    && pip --disable-pip-version-check --no-cache-dir install pylint ipykernel \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    # Install Docker
    && curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get -y install docker-ce-cli \
    # Install Terraform
    && apt-get install -y software-properties-common \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update && apt-get -y install terraform \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# install the AWS cli
RUN curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm awscliv2.zip && rm -rf ./aws

# install SAM
RUN curl -L "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o "aws-sam-cli-linux-x86_64.zip" \
    && unzip aws-sam-cli-linux-x86_64.zip -d sam-installation && ./sam-installation/install \
    && rm aws-sam-cli-linux-x86_64.zip && rm -rf ./sam-installation

# docker post-installation steps
RUN groupadd docker && usermod -aG docker vscode && usermod -aG root vscode

# install GraalVM
RUN mkdir -p ${GRAALVM_BASEDIR}/${GRAALVM_MAINDIR} && curl -L ${GRAALVM_RELEASE_URL} -o /tmp/graal.tar.gz \
    && tar -xzf tmp/graal.tar.gz -C ${GRAALVM_BASEDIR}/${GRAALVM_MAINDIR} --strip-components=1 && rm /tmp/graal.tar.gz \
    && ${GRAALVM_BASEDIR}/${GRAALVM_MAINDIR}/bin/gu install native-image

ENV JAVA_HOME="${GRAALVM_BASEDIR}/${GRAALVM_MAINDIR}"
ENV PATH="${JAVA_HOME}/bin;${PATH}"

# install grpcurl for debugging gRPC
RUN curl -L -o- https://github.com/fullstorydev/grpcurl/releases/download/v1.8.2/grpcurl_1.8.2_linux_x86_64.tar.gz | tar xzvf - -C /usr/local/bin grpcurl 

USER vscode

RUN /usr/local/bin/python -m pip install -U pytest --user && \
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

COPY --chown=vscode workspace-setup/zshrc.template /home/vscode/.zshrc

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=


