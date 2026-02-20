FROM centos:7

# CentOS 7 is EOL - switch to vault mirrors
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo

# Install everything in a single layer to minimize image size
RUN yum install -y epel-release centos-release-scl && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-SCL*.repo && \
    sed -ri 's|#\s*baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-SCL*.repo && \
    # Install devtoolset-11, rh-python38, and build dependencies (skip docs)
    yum install -y --setopt=tsflags=nodocs \
        devtoolset-11-gcc \
        devtoolset-11-gcc-c++ \
        devtoolset-11-binutils \
        rh-python38 \
        rh-python38-python-devel \
        rh-python38-python-pip \
        rh-git227 \
        zlib-devel \
        make \
        unzip \
        curl \
        ca-certificates \
        cpio \
        libatomic && \
    # Python packages needed for LLVM build
    scl enable rh-python38 "pip3 install --no-cache-dir pygments pyyaml" && \
    # Install cmake (only bin/ and share/cmake-*, skip docs/man)
    curl -fsSL https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.tar.gz | \
        tar xz -C /usr/local --strip-components=1 \
            --exclude='doc' --exclude='man' && \
    # Install ninja-build
    curl -fsSL -o /tmp/ninja.zip \
        https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip && \
    unzip /tmp/ninja.zip -d /usr/local/bin && \
    rm /tmp/ninja.zip && \
    # Install mold linker
    curl -fsSL https://github.com/rui314/mold/releases/download/v2.40.4/mold-2.40.4-x86_64-linux.tar.gz | \
        tar xz -C /usr/local --strip-components=1 \
            --exclude='share' && \
    # Install VE cross-compilation RPMs
    mkdir -p /tmp/rpms && cd /tmp/rpms && \
    curl -fsSLO https://sxauroratsubasa.sakura.ne.jp/repos/runtime/sdk/sdk_el7/binutils/2.26-2.12/x86_64/binutils-ve-2.26-2.12.x86_64.rpm && \
    curl -fsSLO https://sxauroratsubasa.sakura.ne.jp/repos/TSUBASA-repo_el7.9/veos/3.3.0/x86_64/glibc-ve1-2.21-18.el7.x86_64.rpm && \
    curl -fsSLO https://sxauroratsubasa.sakura.ne.jp/repos/TSUBASA-repo_el7.9/veos/3.3.0/x86_64/glibc-ve1-devel-2.21-18.el7.x86_64.rpm && \
    curl -fsSLO https://sxauroratsubasa.sakura.ne.jp/repos/TSUBASA-repo_el7.9/veos/3.0.1/x86_64/kheaders-ve1-3.10.0-514.el7_5.el7.x86_64.rpm && \
    rpm -ivh --nodeps *.rpm && \
    # Remove unzip (only needed for ninja), temp files, and caches
    yum remove -y unzip && \
    yum clean all && \
    rm -rf /var/cache/yum /tmp/rpms /usr/share/doc /usr/share/man /usr/share/info

# Enable devtoolset-11 and rh-python38 by default
ENV PATH=/opt/rh/devtoolset-11/root/usr/bin:/opt/rh/rh-python38/root/usr/bin:/opt/rh/rh-git227/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-11/root/usr/lib64:/opt/rh/devtoolset-11/root/usr/lib:/opt/rh/rh-python38/root/usr/lib64:/opt/rh/rh-git227/root/usr/lib64
