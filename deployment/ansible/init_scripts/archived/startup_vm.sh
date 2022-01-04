#!/usr/bin/env bash

if [[ -f /etc/startup_was_launched ]]; then
    echo "startup ran, bailing"
    exit 0
fi

echo $(date) > /etc/startup_began

# install docker in one line on gcp
sudo apt-get update && \
sudo apt-get install -y lsb-release bash-completion build-essential locales && \

# fix locale issues
LANG=en_US.UTF-8
sudo sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    sudo dpkg-reconfigure --frontend=noninteractive locales && \
    sudo update-locale LANG=$LANG

# add monitoring agent
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh && \
  sudo bash add-monitoring-agent-repo.sh --also-install && \
  sudo service stackdriver-agent start

# add pushover script to notify that things are done
cat <<- EOF > /etc/pushover.sh
#!/usr/bin/env bash
INPUT=\$( cat )
curl -s \
  --form-string "token=ag6p5a19ddu73yi2d61tvmoezmv8x5" \
  --form-string "user=ugjtync3ubif8a31a5tc6f8z8dmmux" \
  --form-string "title=\$1" \
  --form-string "monospace=1" \
  --form-string "message=\$INPUT" \
  https://api.pushover.net/1/messages.json
echo
EOF
chmod +x /etc/pushover.sh

echo "$HOSTNAME: setup complete at $(date)!" | /etc/pushover.sh "Setup complete on $HOSTNAME"

echo $(date) > /etc/startup_was_launched
