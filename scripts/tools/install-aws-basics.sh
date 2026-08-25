#!/usr/bin/env bash
set -euo pipefail

echo "Installing AWS CLI v2..."
if [ "$(uname -s)" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required on macOS." >&2
        exit 1
    fi
    brew install awscli
    aws --version
    echo "AWS CLI installed. Run 'aws configure sso' for an IAM Identity Center account; avoid long-lived root credentials."
    exit 0
fi

if [ "$(uname -s)" != "Linux" ] || ! command -v apt >/dev/null 2>&1; then
    echo "This installer supports macOS and APT-based Linux distributions." >&2
    exit 1
fi

sudo apt update
sudo apt install -y ca-certificates curl unzip

case "$(uname -m)" in
    x86_64) aws_arch="x86_64" ;;
    aarch64|arm64) aws_arch="aarch64" ;;
    *)
        echo "AWS CLI v2 is unsupported on architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

aws_archive="$(mktemp --suffix=.zip)"
aws_extract_dir="$(mktemp -d)"
trap 'rm -f "$aws_archive"; rm -rf "$aws_extract_dir"' EXIT
curl -fL "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip" -o "$aws_archive"
unzip -q "$aws_archive" -d "$aws_extract_dir"

if command -v aws >/dev/null 2>&1; then
    sudo "$aws_extract_dir/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
else
    sudo "$aws_extract_dir/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli
fi

if ! command -v aws >/dev/null 2>&1; then
    echo "AWS CLI launcher was not installed." >&2
    exit 1
fi
aws --version
echo "AWS CLI installed. Run 'aws configure sso' for an IAM Identity Center account; avoid long-lived root credentials."
