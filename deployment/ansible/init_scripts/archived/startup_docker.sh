#!/usr/bin/env bash

if [[ -f /etc/startup_was_launched ]]; then
    echo "startup ran, bailing"
    exit 0
fi

echo $(date) > /etc/startup_began

# install docker in one line on gcp
sudo apt-get update && \
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release bash-completion build-essential locales && \
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io && \
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
sudo chmod +x /usr/local/bin/docker-compose && \
sudo curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose

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

echo "setup complete!" | /etc/pushover.sh "Event on $HOSTNAME"

echo $(date) > /etc/startup_was_launched
