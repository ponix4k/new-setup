#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
fstab_template="$repo_root/configs/scripts/fstab_entries.txt"
credentials_file="/etc/.creds/creds"
managed_start="# BEGIN new-setup shares"
managed_end="# END new-setup shares"

read -r -p "Enter remote share IP [127.0.0.1]: " remote_ip
remote_ip="${remote_ip:-127.0.0.1}"
read -r -p "Enter share username: " share_username
read -r -s -p "Enter share password: " share_password
printf '\n'
read -r -p "Enter share domain: " share_domain

if ! [[ "$remote_ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Invalid IPv4 address: $remote_ip" >&2
    exit 1
fi

IFS=. read -r ip1 ip2 ip3 ip4 <<< "$remote_ip"
for octet in "$ip1" "$ip2" "$ip3" "$ip4"; do
    if ((10#$octet > 255)); then
        echo "Invalid IPv4 address: $remote_ip" >&2
        exit 1
    fi
done

if [ -z "$share_username" ] || [ -z "$share_password" ]; then
    echo "Username and password cannot be empty." >&2
    exit 1
fi

if [ ! -f "$fstab_template" ]; then
    echo "Missing fstab template: $fstab_template" >&2
    exit 1
fi

credentials_tmp="$(mktemp)"
fstab_entries_tmp="$(mktemp)"
fstab_tmp="$(mktemp)"
trap 'rm -f "$credentials_tmp" "$fstab_entries_tmp" "$fstab_tmp"' EXIT

printf 'username=%s\npassword=%s\ndomain=%s\n' \
    "$share_username" "$share_password" "$share_domain" > "$credentials_tmp"

user_id="$(id -u)"
group_id="$(id -g)"
sed \
    -e "s|127\\.0\\.0\\.1|$remote_ip|g" \
    -e "s|/home/USER|$HOME|g" \
    -e "s|uid=1000|uid=$user_id|g" \
    -e "s|gid=1000|gid=$group_id|g" \
    "$fstab_template" > "$fstab_entries_tmp"

awk -v start="$managed_start" -v end="$managed_end" -v projects="$HOME/projects" '
    $0 == start { managed = 1; next }
    $0 == end { managed = 0; next }
    managed { next }
    $2 == "/media/shared" || $2 == projects { next }
    { print }
' /etc/fstab > "$fstab_tmp"

printf '\n%s\n' "$managed_start" >> "$fstab_tmp"
cat "$fstab_entries_tmp" >> "$fstab_tmp"
printf '%s\n' "$managed_end" >> "$fstab_tmp"

echo "Installing CIFS support and configuring shares..."
sudo apt update
sudo apt install -y cifs-utils
sudo install -d -m 700 /etc/.creds
sudo install -m 600 "$credentials_tmp" "$credentials_file"
sudo chown -R "$USER:$USER" /etc/.creds
sudo install -d -m 755 /media/shared
mkdir -p "$HOME/projects"
if ! sudo test -e /etc/fstab.new-setup.bak; then
    sudo cp /etc/fstab /etc/fstab.new-setup.bak
fi
sudo install -m 644 "$fstab_tmp" /etc/fstab

echo "Mounting configured shares..."
sudo mount -a
echo "Shares configured successfully."
