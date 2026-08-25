#!/usr/bin/env bash
set -euo pipefail

echo "Installing the Python learning environment..."
case "$(uname -s)" in
    Darwin)
        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew is required on macOS." >&2
            exit 1
        fi
        brew install git pipx python
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
        sudo apt install -y build-essential git pipx python3 python3-dev python3-pip python3-venv
        ;;
    *)
        echo "Unsupported operating system: $(uname -s)" >&2
        exit 1
        ;;
esac

python3 -m pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"
for tool in black ruff; do
    pipx install "$tool" --force
done

# pytest is installed in its own pipx environment while exposing the pytest CLI.
pipx install pytest --force

for command_name in black pipx pytest python3 ruff; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Python learning command was not installed or is not on PATH: $command_name" >&2
        exit 1
    fi
done

echo "Python learning tools installed. Open a new terminal before using pipx commands."
