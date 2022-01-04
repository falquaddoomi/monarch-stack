#!/usr/bin/env bash

if [[ -f /etc/startup_was_launched ]]; then
    echo "startup ran, bailing"
    exit 0
fi

# clear files whose existence indicates start or end of setup process
rm -rf /etc/startup_began
rm -rf /etc/startup_was_launched

echo $(date) > /etc/startup_began

# # install packages that ansible, building other stuff, relies upon
# sudo apt-get -qq update && \
# sudo apt-get -qq install -y \
#   lsb-release bash-completion build-essential locales \
#   python3-minimal python3-setuptools python3-pip

# # fix locale issues
# LANG=en_US.UTF-8
# sudo sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
#     sudo dpkg-reconfigure --frontend=noninteractive locales && \
#     sudo update-locale LANG=$LANG

# more locale-fixing?
echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen en_US.UTF-8

# add monitoring agent
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh && \
  sudo bash add-monitoring-agent-repo.sh --also-install && \
  sudo service stackdriver-agent start

echo $(date) > /etc/startup_was_launched
