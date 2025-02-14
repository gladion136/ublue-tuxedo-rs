#!/bin/bash

set -ouex pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME:-kernel}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
rpm-ostree install screen

rpm-ostree install rpm-build
rpm-ostree install rpmdevtools
rpm-ostree install kmodtool

export HOME=/tmp

rpmdev-setuptree

curl -LsSf -o /etc/yum.repos.d/_copr_gladion136-tuxedo-drivers-kmod.repo "https://copr.fedorainfracloud.org/coprs/gladion136/tuxedo-drivers-kmod/repo/fedora-${RELEASE}/gladion136-tuxedo-drivers-kmod-fedora-${RELEASE}.repo"

### BUILD tuxedo-drivers (succeed or fail-fast with debug output)
dnf install -y \
    "akmod-tuxedo-drivers-*.fc${RELEASE}.${ARCH}"

akmods --force --kernels "${KERNEL}" --kmod "tuxedo-drivers"

rpm-ostree install cargo rust meson ninja-build libadwaita-devel gtk4-devel
git clone https://github.com/BrickMan240/tuxedo-rs
cd tuxedo-rs
cd tailord
meson setup --prefix=/usr _build
ninja -C _build
ninja -C _build install
systemctl enable tailord.service
cd ../tailor_gui
meson setup --prefix=/usr _build
ninja -C _build
ninja -C _build install
cd ../..

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File


systemctl enable podman.socket
