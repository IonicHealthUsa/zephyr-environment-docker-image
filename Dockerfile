# Use the official Ubuntu 22.04 base image
FROM ubuntu:22.04

# Set the working directory to /home
WORKDIR /zephyr-workdir

# Set environment variables
ENV ARM_TOOLCHAINS_URL=https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.4/toolchain_linux-x86_64_arm-zephyr-eabi.tar.xz
ENV ARM_TOOLCHAINS_FILENAME=toolchain_linux-x86_64_arm-zephyr-eabi.tar.xz
ENV ZEPHYR_SDK_URL_MINIMAL=https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.4/zephyr-sdk-0.16.4_linux-x86_64_minimal.tar.xz
ENV ZEPHYR_SDK_TAR_FILENAME=zephyr-sdk-0.16.4_linux-x86_64_minimal.tar.xz
ENV ZEPHYR_SDK_FOLDER=zephyr-sdk-0.16.4

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    tar \
    perl \
    xz-utils \
    python3 \
    python3-pip \
    git \
    file \
    make \
    gcc \
    cmake \
    ninja-build \
    gperf \
    device-tree-compiler \
    ccache \
    dfu-util \
    python3-setuptools \
    python3-wheel \
    python3-venv \
    sudo

# Download and install Zephyr SDK minimal
RUN wget $ZEPHYR_SDK_URL_MINIMAL -O /opt/$ZEPHYR_SDK_TAR_FILENAME

# Download and install ARM toolchains
RUN wget $ARM_TOOLCHAINS_URL -O /opt/$ARM_TOOLCHAINS_FILENAME

# Install Zephyr SDK
RUN cd /opt/ && tar xf ./$ZEPHYR_SDK_TAR_FILENAME && \
    bash ./$ZEPHYR_SDK_FOLDER/setup.sh -h -c -t arm-zephyr-eabi

# Create virtual environment
RUN python3 -m venv venv

# Upgrade pip
RUN python3 -m pip install -U pip

# Install west
RUN . venv/bin/activate && \
    pip install west

# Initialize west
RUN . venv/bin/activate && \
    west init

# Update west
RUN . venv/bin/activate && \
    west update

# Export Zephyr SDK
RUN . venv/bin/activate && \
    west zephyr-export

# Install Zephyr dependencies
RUN . venv/bin/activate && \
    pip install -r ./zephyr/scripts/requirements.txt

# Clone mcuboot
RUN git clone https://github.com/mcu-tools/mcuboot.git

# Install mcuboot dependencies
RUN . venv/bin/activate && \
    pip install -r ./mcuboot/scripts/requirements.txt

# Cleanup
RUN apt-get remove -y --purge \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    wget \
    xz-utils && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /opt/$ZEPHYR_SDK_TAR_FILENAME && \
    rm -f /opt/$ARM_TOOLCHAINS_FILENAME

# Set access to workdir
RUN chmod -R  777 /zephyr-workdir  

# Setting a password to root
RUN yes toor | passwd root

# Setting the a default CMD
CMD ["bash"]

