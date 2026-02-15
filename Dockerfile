FROM centos:7

# CentOS 7 is EOL - switch to vault mirrors
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo

# Install EPEL and SCL repositories
RUN yum install -y epel-release centos-release-scl && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-SCL*.repo && \
    sed -ri 's|#\s*baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-SCL*.repo

# Install devtoolset-11 and build dependencies
RUN yum install -y \
        devtoolset-11-gcc \
        devtoolset-11-gcc-c++ \
        devtoolset-11-binutils \
        python3 \
        python3-devel \
        python3-pip \
        git \
        zlib-devel \
        make \
        unzip \
        curl \
        ca-certificates \
        cpio \
        libatomic && \
    yum clean all && \
    rm -rf /var/cache/yum

# Python packages needed for LLVM build
RUN pip3 install pygments pyyaml

# Install cmake (CentOS 7 default cmake is too old for LLVM)
RUN curl -fsSL https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.tar.gz | \
    tar xz -C /usr/local --strip-components=1

# Install ninja-build
RUN curl -fsSL -o /tmp/ninja.zip \
        https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip && \
    unzip /tmp/ninja.zip -d /usr/local/bin && \
    rm /tmp/ninja.zip

# Install mold linker (static binary)
RUN curl -fsSL https://github.com/rui314/mold/releases/download/v2.35.1/mold-2.35.1-x86_64-linux.tar.gz | \
    tar xz -C /usr/local --strip-components=1

# Enable devtoolset-11 by default
ENV PATH=/opt/rh/devtoolset-11/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-11/root/usr/lib64:/opt/rh/devtoolset-11/root/usr/lib

# Install VE cross-compilation RPMs to /opt
RUN mkdir -p /tmp/rpms && cd /tmp/rpms && \
    curl -fsSLO https://sxauroratsubasa.sakura.ne.jp/repos/runtime/sdk/sdk_el7/binutils/2.26-2.12/x86_64/binutils-ve-2.26-2.12.x86_64.rpm && \
    curl -fsSLO https://sxauroratsubasa.sakura.ne.jp/repos/TSUBASA-repo_el7.9/veos/3.3.0/x86_64/glibc-ve1-2.21-18.el7.x86_64.rpm && \
    curl -fsSLO https://sxauroratsubasa.sakura.ne.jp/repos/TSUBASA-repo_el7.9/veos/3.3.0/x86_64/glibc-ve1-devel-2.21-18.el7.x86_64.rpm && \
    curl -fsSLO https://sxauroratsubasa.sakura.ne.jp/repos/TSUBASA-repo_el7.9/veos/3.0.1/x86_64/kheaders-ve1-3.10.0-514.el7_5.el7.x86_64.rpm && \
    rpm -ivh --nodeps *.rpm && \
    rm -rf /tmp/rpms
