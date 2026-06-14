# snort3----snort3-3.12.2.0-r1-for-OpenWRT---Linksys-WRT3200ACM<br>
snort3 -- snort3-3.12.2.0-r1 for OpenWRT - Linksys WRT3200ACM<br>
folder patth : /openwrt/bin/packages/arm_cortex-a9_vfpv3-d16/packages<br>
<br>
<br>
Compiled snort3 APK packages for OpenWRT, Linksys WRT3200ACM<br>
<br>
Source Code : https://github.com/snort3/snort3/releases/tag/3.12.2.0<br>
<br>
<br>
35c4215e4e493f0e51d2859587506e8d1e1526d8892d8f92ad092a91af302799  libdaq3-3.0.27-r1.apk<br>
2e3d877da8da42399597a0a88ddea19e37d0ca003f1519e9781f1d45273e5894  libdnet-1.16.1-r1.apk<br>
a18776a7491ab8663e89824623c97920d514ef920de00c157e69a79d6c505d8f  libhwloc-2.12.1-r1.apk<br>
bb7e49cf4c4cdc792b28cdf94c51e67fbbe310facc25f0978d2703015dbcbfbe  liblzma-5.8.1-r1.apk<br>
19155fb2916cb9143ae73cce599cb777f2a1e82dab4a5b302b744e67d314b8ce  libnetfilter-queue1-1.0.5-r4.apk<br>
20fdb570e88eef33033e0e56fd6c5a6c4ab73dbb8efb0c207eafae539bee5910  libpciaccess-0.18.1-r1.apk<br>
f4bbca58be9ec654d7923a5b79388a465a107c90692ecc6ed814a0535591e527  libtirpc-1.3.7-r2.apk<br>
5901a585cac36e458e66355cd15eea1a83c29d6d51bafd90caa60fcf3d0ee966  luajit-2.1.0-r8.apk<br>
6ba7c7975a40bef1cfd758a3ef1ab0a7377b1a998fecf1f73486b6c74a418118  snort3-3.12.2.0-r1.apk<br>
<br>
<br>
/openwrt/bin/packages/arm_cortex-a9_vfpv3-d16/packages<br>
<br>
-rw-r--r-- 1 test test  146059 Jun 15 01:41 libdaq3-3.0.27-r1.apk<br>
-rw-r--r-- 1 test test   21014 Jun 15 00:06 libdnet-1.16.1-r1.apk<br>
-rw-r--r-- 1 test test  137614 Jun 15 00:07 libhwloc-2.12.1-r1.apk<br>
-rw-r--r-- 1 test test   60789 Jun 15 00:31 liblzma-5.8.1-r1.apk<br>
-rw-r--r-- 1 test test    9330 Jun 15 00:06 libnetfilter-queue1-1.0.5-r4.apk<br>
-rw-r--r-- 1 test test   12176 Jun 15 00:09 libpciaccess-0.18.1-r1.apk<br>
-rw-r--r-- 1 test test   58921 Jun 15 00:40 libtirpc-1.3.7-r2.apk<br>
-rw-r--r-- 1 test test  200437 Jun 15 00:32 luajit-2.1.0-r8.apk<br>
-rw-r--r-- 1 test test 1905074 Jun 15 01:46 snort3-3.12.2.0-r1.apk<br>
<br>
<br>
Installation Step :<br>
<br>
Login to the target :<br>
ssh root@192.168.x.x<br>
<br>
mkdir -p /tmp/snort3-3-12-pkg<br>
cd /tmp/snort3-3-12-pkg<br>
<br>
Upload file to the target (from your computer to OpenWRT) :<br>
scp -O ~/Desktop/OpenWRT/openwrt/bin/packages/arm_cortex-a9_vfpv3-d16/packages/*.apk   root@192.168.x.x:/tmp/snort3-3-12-pkg/<br>
<br>
# Install everything at once — apk resolves the order automatically<br>
apk add --allow-untrusted \<br>
  libdaq3-3.0.27-r1.apk \<br>
  libdnet-1.16.1-r1.apk \<br>
  libhwloc-2.12.1-r1.apk \<br>
  liblzma-5.8.1-r1.apk \<br>
  libnetfilter-queue1-1.0.5-r4.apk \<br>
  libpciaccess-0.18.1-r1.apk \<br>
  libtirpc-1.3.7-r2.apk \<br>
  luajit-2.1.0-r8.apk \<br>
  snort3-3.12.2.0-r1.apk<br>
<br>
# Verify<br>
snort --version<br>
<br>
<br>
Result / Version info : <br>
WRT:/tmp/tmp# snort --version<br>
<br>
   ,,_     -*> Snort++ <*-<br>
  o"  )~   Version 3.12.2.0<br>
   ''''    By Martin Roesch & The Snort Team<br>
           http://snort.org/contact#team<br>
           Copyright (C) 2014-2026 Cisco and/or its affiliates. All rights reserved.<br>
           Copyright (C) 1998-2013 Sourcefire, Inc., et al.<br>
           Using DAQ version 3.0.27<br>
           Using libpcap version 1.10.6 (64-bit time_t, with TPACKET_V3)<br>
           Using LuaJIT version 2.1.0-beta3<br>
           Using LZMA version 5.8.1<br>
           Using OpenSSL 3.5.6 7 Apr 2026<br>
           Using PCRE2 version 10.47 2025-10-21<br>
           Using ZLIB version 1.3.1<br>
<br>
