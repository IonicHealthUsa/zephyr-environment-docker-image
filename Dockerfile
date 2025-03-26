FROM ubuntu:22.04

# Set the working directory to /home
WORKDIR /zephyr-workdir

# Set environment variables
ENV ARM_TOOLCHAINS_URL=https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.0/toolchain_linux-x86_64_arm-zephyr-eabi.tar.xz
ENV ARM_TOOLCHAINS_FILENAME=toolchain_linux-x86_64_arm-zephyr-eabi.tar.xz
ENV ZEPHYR_SDK_URL_MINIMAL=https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.0/zephyr-sdk-0.17.0_linux-x86_64_minimal.tar.xz
ENV ZEPHYR_SDK_TAR_FILENAME=zephyr-sdk-0.17.0_linux-x86_64_minimal.tar.xz
ENV ZEPHYR_SDK_FOLDER=zephyr-sdk-0.17.0


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
RUN python3 -m venv venv && \
  # Upgrade pip
  python3 -m pip install -U pip


# Install west
RUN . venv/bin/activate && \
  pip install west


# Initialize west
RUN . venv/bin/activate && \
  west init -m https://github.com/zephyrproject-rtos/zephyr --mr v3.7.0


# Update west
RUN . venv/bin/activate && \
  west update && \
  # Export Zephyr SDK
  west zephyr-export


# Install Zephyr dependencies
RUN . venv/bin/activate && \
  pip install -r ./zephyr/scripts/requirements.txt


# Clean
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

