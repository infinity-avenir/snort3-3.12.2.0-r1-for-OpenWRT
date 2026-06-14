# Compiling Snort 3.12.2.0 APK from Source for OpenWrt 25.12+

**Target device:** Linksys WRT3200ACM (mvebu/cortexa9 — `arm_cortex-a9_vfpv3-d16`)
**Package:** Snort 3.12.2.0
**Package format:** APK (Alpine Package Keeper), default since OpenWrt 25.12

---

## Part 1 — Prepare the Build Host

Ubuntu 22.04/24.04 or Debian 12+ on x86_64.

### Step 1 — Install host dependencies

```bash
sudo apt update
sudo apt install -y \
  build-essential gawk gcc-multilib flex gettext git \
  libncurses5-dev libssl-dev python3-distutils python3-setuptools \
  rsync swig unzip zlib1g-dev file wget curl xsltproc \
  python3 python3-dev time
```

---

## Part 2 — Download and Inspect the Snort 3 Source Code

### Step 2 — Check the latest release

Visit https://github.com/snort3/snort3/releases

At time of writing the latest is **3.12.2.0**. The tarball URL:

```
https://github.com/snort3/snort3/archive/refs/tags/3.12.2.0.tar.gz
```

### Step 3 — Download the source tarball

```bash
mkdir -p ~/snort3-source && cd ~/snort3-source
wget -O snort3-3.12.2.0.tar.gz \
  "https://github.com/snort3/snort3/archive/refs/tags/3.12.2.0.tar.gz"
```

### Step 4 — Compute the SHA-256 hash

```bash
sha256sum snort3-3.12.2.0.tar.gz
```

Result:

```
43000d6b0e0307bc1a735874d00deb61e8b6a96d074f8cc9b2fe2cde0058720b
```

Save this hash — you need it later.

### Step 5 — Extract and inspect

```bash
tar xzf snort3-3.12.2.0.tar.gz
ls snort3-3.12.2.0/
```

### Step 6 — Identify dependencies and minimum libdaq version

```bash
# Required dependencies (from cmake/include_libraries.cmake)
cat snort3-3.12.2.0/cmake/include_libraries.cmake | grep "find_package.*REQUIRED"

# Minimum libdaq version (CRITICAL — must match)
cat snort3-3.12.2.0/cmake/FindDAQ.cmake | grep "pkg_check_modules"
```

Results:

| Dependency | Required | Notes |
|---|---|---|
| Threads | yes | built-in (libc) |
| DAQ | yes | **>= 3.0.27** (feeds ship 3.0.23, must upgrade!) |
| DNET | yes | libdnet |
| FlexLexer | yes | flex (host tool) |
| HWLOC | yes | hwloc |
| LuaJIT | yes | luajit2 |
| OpenSSL >= 1.1.1 | yes | libopenssl |
| PCAP | yes | libpcap |
| PCRE2 | yes | pcre2 |
| ZLIB | yes | zlib |

**CRITICAL:** Snort 3.12.2.0 requires libdaq >= 3.0.27. The OpenWrt feeds ship 3.0.23. You **must** upgrade libdaq in the feeds before compiling Snort. Failing to do this causes a hard compile error (`'struct _daq_snort_latency_data' has no member named 'snort_up_max_pkt_dst_port'`).

### Step 7 — Download libdaq source and get its hash

```bash
cd ~/snort3-source
wget -O libdaq-3.0.27.tar.gz \
  "https://github.com/snort3/libdaq/archive/refs/tags/v3.0.27.tar.gz"
sha256sum libdaq-3.0.27.tar.gz
```

Result:

```
03fac3da27e3230a7d26262f2480cd65a409cee3596c6758a7f9eacb7f24601c
```

---

## Part 3 — Set Up the OpenWrt Build System

### Step 8 — Clone OpenWrt

```bash
cd ~
git clone https://git.openwrt.org/openwrt/openwrt.git
cd openwrt
git checkout v25.12.0
```

### Step 9 — Update and install feeds

```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

### Step 10 — Configure for the WRT3200ACM

```bash
make menuconfig
```

Set:

| Setting | Value |
|---|---|
| **Target System** | `Marvell EBU Armada` (mvebu) |
| **Subtarget** | `Marvell Armada 37x/38x/XP` (cortexa9) |
| **Target Profile** | `Linksys WRT3200ACM` |

Navigate to **Network → Firewall → snort3**, select it as `<M>` (module).

Exit and save.

### Step 11 — Build the toolchain and base system

```bash
make -j$(nproc) V=s 2>&1 | tee build.log
```

This takes 1–3 hours on first run. The toolchain is cached for later.

---

## Part 4 — Upgrade libdaq and Snort in the Feeds

The feeds ship Snort 3.10.0.0 with libdaq 3.0.23. We need to upgrade both.

### Step 12 — Upgrade libdaq3 from 3.0.23 to 3.0.27

```bash
cd ~/openwrt

sed -i 's/PKG_VERSION:=3.0.23/PKG_VERSION:=3.0.27/' feeds/packages/libs/libdaq3/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=03fac3da27e3230a7d26262f2480cd65a409cee3596c6758a7f9eacb7f24601c/' feeds/packages/libs/libdaq3/Makefile
```

Verify:

```bash
grep "PKG_VERSION\|PKG_HASH" feeds/packages/libs/libdaq3/Makefile | head -2
```

Expected:

```
PKG_VERSION:=3.0.27
PKG_HASH:=03fac3da27e3230a7d26262f2480cd65a409cee3596c6758a7f9eacb7f24601c
```

### Step 13 — Upgrade snort3 from 3.10.0.0 to 3.12.2.0

```bash
sed -i 's/PKG_VERSION:=3.10.0.0/PKG_VERSION:=3.12.2.0/' feeds/packages/net/snort3/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=43000d6b0e0307bc1a735874d00deb61e8b6a96d074f8cc9b2fe2cde0058720b/' feeds/packages/net/snort3/Makefile
```

Verify:

```bash
grep "PKG_VERSION\|PKG_HASH" feeds/packages/net/snort3/Makefile | head -2
```

Expected:

```
PKG_VERSION:=3.12.2.0
PKG_HASH:=43000d6b0e0307bc1a735874d00deb61e8b6a96d074f8cc9b2fe2cde0058720b
```

---

## Part 5 — Compile

### Step 14 — Clean and rebuild libdaq3 first

```bash
make package/feeds/packages/libdaq3/clean V=s
make package/feeds/packages/libdaq3/compile V=s -j$(nproc)
```

### Step 15 — Compile snort3

```bash
make package/feeds/packages/snort3/clean V=s
rm -rf tmp/
make package/feeds/packages/snort3/compile V=s -j$(nproc)
```

### Step 16 — Locate the compiled APKs

```bash
find bin/ -name "snort3*.apk"
ls bin/packages/arm_cortex-a9_vfpv3-d16/packages/
```

Expected output:

```
libdaq3-3.0.27-r1.apk
libdnet-1.16.1-r1.apk
libhwloc-2.12.1-r1.apk
liblzma-5.8.1-r1.apk
libnetfilter-queue1-1.0.5-r4.apk
libpciaccess-0.18.1-r1.apk
libtirpc-1.3.7-r2.apk
luajit-2.1.0-r8.apk
snort3-3.12.2.0-r1.apk
```

---

## Part 6 — Install on the Router

### Step 17 — Transfer all APKs to the router

```bash
scp bin/packages/arm_cortex-a9_vfpv3-d16/packages/*.apk \
  root@192.168.1.1:/tmp/snort3-pkg/
```

### Step 18 — Install on the router

```bash
ssh root@192.168.1.1
mkdir -p /tmp/snort3-pkg
cd /tmp/snort3-pkg

# Install all packages at once
apk add --allow-untrusted \
  libdaq3-3.0.27-r1.apk \
  libdnet-1.16.1-r1.apk \
  libhwloc-2.12.1-r1.apk \
  liblzma-5.8.1-r1.apk \
  libnetfilter-queue1-1.0.5-r4.apk \
  libpciaccess-0.18.1-r1.apk \
  libtirpc-1.3.7-r2.apk \
  luajit-2.1.0-r8.apk \
  snort3-3.12.2.0-r1.apk
```

Some core dependencies (libpcap, libopenssl, zlib, libpcre2, libstdcpp) should already be on the router. If `apk add` complains about a missing one:

```bash
apk update
apk add libpcap libopenssl zlib libpcre2
```

### Step 19 — Verify

```bash
apk info snort3
snort --version
```

Expected: `Snort++ 3.12.2.0`

---

## Part 7 — Updating to Future Versions

When a new Snort release appears:

1. Download the new Snort tarball and compute its SHA-256.
2. Check `cmake/FindDAQ.cmake` for the minimum libdaq version.
3. If libdaq needs upgrading too, download that tarball and get its hash.
4. Update both `PKG_VERSION` and `PKG_HASH` in the feed Makefiles.
5. Clean and recompile libdaq first, then snort3.

```bash
# Example for a hypothetical future version
sed -i 's/PKG_VERSION:=OLD/PKG_VERSION:=NEW/' feeds/packages/net/snort3/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=NEW_HASH/' feeds/packages/net/snort3/Makefile
make package/feeds/packages/snort3/clean V=s
make package/feeds/packages/snort3/compile V=s -j$(nproc)
```

---

## Troubleshooting Reference

### Finding the correct make path for any package

Never guess package paths. Always use:

```bash
# Find where a package Makefile lives
find package/ feeds/ -name "Makefile" | xargs grep -l "PKG_NAME:=packagename" 2>/dev/null
```

The make target uses the **symlink** path under `package/feeds/`, not the real path under `feeds/`. Feed packages are always `package/feeds/<feedname>/<packagename>/compile` — the hierarchy is **flat** (no subdirectories like `libs/` or `net/`).

Core packages (pcre2, libpcap, openssl, zlib) live directly under `package/libs/` or similar.

### "No rule to make target"

Three possible causes:

1. **Wrong path** — use the `find` command above.
2. **Package not selected in menuconfig** — check with `grep CONFIG_PACKAGE_snort3 .config` (must show `=m` or `=y`).
3. **Stale cache** — run `rm -rf tmp/` then `make menuconfig`, re-select the package, save and exit.

### API mismatch errors (missing struct members)

This means the dependency version is too old for the package version. Check the package's cmake Find*.cmake files for minimum version requirements and upgrade the dependency in the feeds.

### Format string warnings treated as errors

OpenWrt's hardening flags include `-Wformat -Werror=format-security`. If a package has format string mismatches (common on 32-bit ARM cross-compilation), the flags conflict. Do NOT use `-Wno-format` as it breaks `-Werror=format-security`. Instead use `-Wno-error=format -Wno-error=format-security` together.

### APK vs opkg command reference

| Task | Old (opkg) | New (apk) |
|---|---|---|
| Update lists | `opkg update` | `apk update` |
| Install | `opkg install pkg` | `apk add pkg` |
| Install local | `opkg install ./pkg.ipk` | `apk add --allow-untrusted ./pkg.apk` |
| Remove | `opkg remove pkg` | `apk del pkg` |
| List installed | `opkg list-installed` | `apk list --installed` |
| Search | `opkg find pattern` | `apk search pattern` |
| Info | `opkg info pkg` | `apk info pkg` |
