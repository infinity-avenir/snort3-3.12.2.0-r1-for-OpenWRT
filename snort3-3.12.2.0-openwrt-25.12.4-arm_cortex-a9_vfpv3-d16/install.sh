            #!/bin/sh
            #
            # Snort3 3.12.2.0 installer for OpenWrt 25.12.4
            # Architecture: aarch64_cortex-a53
            #
            # Compatible devices:
            #   #   GL.iNet GL-MT6000 (Flint 2)
#   GL.iNet GL-MT3000 (Beryl AX)
#   GL.iNet GL-MT3600BE (Beryl 7)
            #
            # Usage:
            #   scp -r snort3-3.12.2.0-openwrt-25.12.4-aarch64_cortex-a53/ root@<router-ip>:/tmp/
            #   ssh root@<router-ip> 'cd /tmp/snort3-3.12.2.0-openwrt-25.12.4-aarch64_cortex-a53 && sh install.sh'
            #

            set -e

            echo "====================================="
            echo " Snort3 3.12.2.0 Installer"
            echo " OpenWrt 25.12.4 / aarch64_cortex-a53"
            echo "====================================="
            echo ""

            # Check architecture
            BOARD_ARCH=$(. /etc/openwrt_release 2>/dev/null && echo "$DISTRIB_ARCH" || echo "unknown")
            if [ "$BOARD_ARCH" != "unknown" ] && [ "$BOARD_ARCH" != "aarch64_cortex-a53" ]; then
                echo "WARNING: This bundle is for aarch64_cortex-a53"
                echo "         This device reports: $BOARD_ARCH"
                echo ""
                printf "Continue anyway? [y/N] "
                read -r ans
                case "$ans" in y|Y) ;; *) echo "Aborted."; exit 1 ;; esac
            fi

            SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
            APK_COUNT=$(ls -1 "$SCRIPT_DIR"/*.apk 2>/dev/null | wc -l)

            if [ "$APK_COUNT" -eq 0 ]; then
                echo "ERROR: No .apk files found in $SCRIPT_DIR"
                exit 1
            fi

            echo "Installing $APK_COUNT packages ..."
            echo ""

            # Install all .apk files, allowing untrusted (locally built)
            apk add --allow-untrusted "$SCRIPT_DIR"/*.apk

            echo ""
            echo "====================================="
            echo " Installation complete"
            echo "====================================="
            echo ""

            # Verify
            if command -v snort >/dev/null 2>&1; then
                echo "Snort version: $(snort -V 2>&1 | head -1)"
            else
                echo "NOTE: snort binary not found in PATH."
                echo "      Try: /usr/bin/snort -V"
            fi

            echo ""
            echo "Next steps:"
            echo "  1. Edit /etc/config/snort"
            echo "  2. Download rules from https://www.snort.org/downloads"
            echo "  3. Extract rules to /etc/snort/rules/"
            echo "  4. Test:  snort -c /etc/snort/snort.lua --warn-all -T"
            echo "  5. Start: /etc/init.d/snort enable && /etc/init.d/snort start"
            echo ""
