#!/usr/bin/env bash
set -euo pipefail

os="$(uname -s)"
echo "Installing reverse-engineering command-line tools..."

case "$os" in
    Darwin)
        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew is required on macOS." >&2
            exit 1
        fi
        brew install binutils gdb git hexedit nasm openjdk patchelf python qemu radare2
        ;;
    Linux)
        if ! command -v apt >/dev/null 2>&1; then
            echo "The Linux installer currently requires an APT-based distribution." >&2
            exit 1
        fi
        if [ -r /etc/os-release ]; then
            . /etc/os-release
            if [ "${ID:-}" = "ubuntu" ]; then
                sudo apt update
                sudo apt install -y software-properties-common
                sudo add-apt-repository -y universe
            fi
        fi
        sudo apt update
        reversing_packages=(
            binutils bison build-essential ca-certificates curl file flex gdb git hexedit
            jq ltrace make nasm patchelf pkg-config python3 python3-dev python3-pip
            python3-venv qemu-user qemu-user-static strace tar unzip xxd
        )
        if [ "$(dpkg --print-architecture)" = "amd64" ]; then
            reversing_packages+=(gcc-multilib g++-multilib)
        fi
        sudo apt install -y "${reversing_packages[@]}"
        ;;
    *)
        echo "Unsupported operating system: $os" >&2
        exit 1
        ;;
esac

if [ "${INSTALL_GHIDRA:-1}" = "1" ]; then
    ghidra_repo="https://github.com/NationalSecurityAgency/ghidra.git"
    ghidra_source_dir="${GHIDRA_SOURCE_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/new-setup/ghidra-src}"

    if [ -d "$ghidra_source_dir/.git" ]; then
        echo "Updating the existing Ghidra source checkout..."
        git -C "$ghidra_source_dir" pull --ff-only
    elif [ -e "$ghidra_source_dir" ]; then
        echo "Ghidra source path exists but is not a Git checkout: $ghidra_source_dir" >&2
        exit 1
    else
        mkdir -p "$(dirname "$ghidra_source_dir")"
        git clone "$ghidra_repo" "$ghidra_source_dir"
    fi

    required_java="$(awk -F= '$1 == "application.java.min" { print $2 }' "$ghidra_source_dir/Ghidra/application.properties")"
    if [ -z "$required_java" ]; then
        echo "Could not determine Ghidra's required Java version." >&2
        exit 1
    fi

    installed_java=""
    if command -v java >/dev/null 2>&1; then
        installed_java="$(java -version 2>&1 | awk -F'[".]' '/version/ { print $2; exit }' || true)"
    fi

    java_home=""
    if [[ "$installed_java" =~ ^[0-9]+$ ]] && [ "$installed_java" -ge "$required_java" ]; then
        if [ "$os" = "Darwin" ]; then
            java_home="$(/usr/libexec/java_home -v "$required_java" 2>/dev/null || true)"
        else
            java_home="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
        fi
    fi

    if [ -z "$java_home" ]; then
        case "$(uname -m)" in
            x86_64) java_arch="x64" ;;
            aarch64|arm64) java_arch="aarch64" ;;
            *)
                echo "Temurin JDK downloads are unsupported on architecture: $(uname -m)" >&2
                exit 1
                ;;
        esac
        case "$os" in
            Darwin) java_os="mac" ;;
            Linux) java_os="linux" ;;
        esac
        managed_java_dir="${XDG_DATA_HOME:-$HOME/.local/share}/new-setup/temurin-$required_java"
        java_home="$managed_java_dir"
        if [ "$os" = "Darwin" ]; then
            java_home="$managed_java_dir/Contents/Home"
        fi
        if [ ! -x "$java_home/bin/java" ]; then
            echo "Downloading Temurin JDK $required_java for the Ghidra build..."
            java_archive="$(mktemp)"
            java_extract_dir="$(mktemp -d)"
            trap 'rm -f "$java_archive"; rm -rf "$java_extract_dir"' EXIT
            curl -fL "https://api.adoptium.net/v3/binary/latest/${required_java}/ga/${java_os}/${java_arch}/jdk/hotspot/normal/eclipse" -o "$java_archive"
            tar -xzf "$java_archive" -C "$java_extract_dir"
            extracted_java="$(find "$java_extract_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
            mkdir -p "$(dirname "$managed_java_dir")"
            mv "$extracted_java" "$managed_java_dir"
            rm -f "$java_archive"
            rm -rf "$java_extract_dir"
            trap - EXIT
        fi
    fi

    echo "Fetching Ghidra build dependencies..."
    (
        cd "$ghidra_source_dir"
        JAVA_HOME="$java_home" PATH="$java_home/bin:$PATH" \
            ./gradlew -I gradle/support/fetchDependencies.gradle -DhideDownloadProgress -DnoEclipse
        JAVA_HOME="$java_home" PATH="$java_home/bin:$PATH" \
            ./gradlew buildGhidra --parallel
    )

    ghidra_archives=("$ghidra_source_dir"/build/dist/ghidra_*.zip)
    if [ ! -f "${ghidra_archives[0]}" ]; then
        echo "The Ghidra build completed without producing a distribution archive." >&2
        exit 1
    fi
    ghidra_archive="${ghidra_archives[${#ghidra_archives[@]} - 1]}"
    ghidra_extract_dir="$(mktemp -d)"
    trap 'rm -rf "$ghidra_extract_dir"' EXIT
    unzip -q "$ghidra_archive" -d "$ghidra_extract_dir"
    ghidra_built_dir="$(find "$ghidra_extract_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    ghidra_name="$(basename "$ghidra_built_dir")"
    ghidra_install_dir="/opt/$ghidra_name"
    if [ ! -d "$ghidra_install_dir" ]; then
        sudo mv "$ghidra_built_dir" "$ghidra_install_dir"
    fi

    if [ "$os" = "Darwin" ]; then
        ghidra_launcher="$(brew --prefix)/bin/ghidra"
        printf '#!/usr/bin/env bash\nexport JAVA_HOME=%q\nexec %q "$@"\n' \
            "$java_home" "$ghidra_install_dir/ghidraRun" >"$ghidra_launcher"
        chmod 0755 "$ghidra_launcher"
    else
        ghidra_launcher="/usr/local/bin/ghidra"
        sudo mkdir -p /usr/local/bin
        printf '#!/usr/bin/env bash\nexport JAVA_HOME=%q\nexec %q "$@"\n' \
            "$java_home" "$ghidra_install_dir/ghidraRun" | sudo tee "$ghidra_launcher" >/dev/null
        sudo chmod 0755 "$ghidra_launcher"
    fi
fi

required_commands=(file gdb git nasm objdump patchelf readelf strace)
if [ "$os" = "Linux" ]; then
    case "$(dpkg --print-architecture)" in
        amd64) required_commands+=(qemu-aarch64) ;;
        arm64) required_commands+=(qemu-x86_64) ;;
    esac
fi
if [ "$os" = "Darwin" ]; then
    required_commands=(gdb git nasm patchelf radare2)
fi
for command_name in "${required_commands[@]}"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Required reversing command was not installed: $command_name" >&2
        exit 1
    fi
done
if [ "${INSTALL_GHIDRA:-1}" = "1" ] && ! command -v ghidra >/dev/null 2>&1; then
    echo "Ghidra launcher was not installed." >&2
    exit 1
fi

echo "Reverse-engineering tools installed. Analyze only software you own or are authorized to inspect."
