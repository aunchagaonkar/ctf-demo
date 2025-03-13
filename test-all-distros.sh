#!/bin/bash

# Array of distro configurations: name, image, package manager command for git and sudo
declare -a distros=(
  "ubuntu-test ubuntu:latest 'apt update && apt install -y git sudo'"
  "debian-test debian:latest 'apt update && apt install -y git sudo'"
  "kali-test kalilinux/kali-rolling 'apt update && apt install -y git sudo'"
  "fedora-test fedora:latest 'dnf install -y git sudo'"
  "centos-test quay.io/centos/centos:stream9 'dnf install -y git sudo'"
  "arch-test archlinux:latest 'pacman -Sy --noconfirm git sudo'"
)

# Create all containers
for distro in "${distros[@]}"; do
  read -r name image setup_cmd <<< "$distro"
  echo "Creating $name container..."
  distrobox create --name "$name" --image "$image"
done

# Instructions for testing
echo -e "\nContainers created. To test, run these commands for each container:"
for distro in "${distros[@]}"; do
  read -r name image setup_cmd <<< "$distro"
  echo -e "\n# Testing on $name"
  echo "distrobox enter $name"
  echo "# Then inside the container:"
  echo "$setup_cmd"
  echo "git clone https://github.com/aunchagaonkar/ctf-demo.git"
  echo "cd ctf-demo"
  echo "sudo bash start.sh"
  echo "# When finished testing, exit the container"
  echo "exit"
done 