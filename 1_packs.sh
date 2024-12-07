#!/bin/bash
# Script to install various software and python packages (python packages via venv)
# NOTE that openssh-server and auto-cpufreq require user input during install
#
# This script can be run from your home folder, but it's safer to run from
# a different directory, as 2_config.sh should NOT be run from ~/
#
# BEFORE RUNNING THIS SCRIPT, do a system update, edit /etc/default/locale & reboot:
# sudo apt update && sudo apt upgrade -y
# sudo nano /etc/default/locale
#LANG=en_GB.UTF-8
#LANGUAGE=en_GB:en
#LC_NUMERIC=en_GB.UTF-8
#LC_TIME=en_GB.UTF-8
#LC_MONETARY=en_GB.UTF-8
#LC_PAPER=en_GB.UTF-8
#LC_IDENTIFICATION=en_GB.UTF-8
#LC_NAME=en_GB.UTF-8
#LC_ADDRESS=en_GB.UTF-8
#LC_TELEPHONE=en_GB.UTF-8
#LC_MEASUREMENT=en_GB.UTF-8
#
# Also, copy the necessary dot files and directories (see 2_config.sh), and
# backup the settings from base machine before copying to a new system:
#  dconf dump / > dconf-settings.ini
# To restore settings to new machine (if done manually, do this last! but
# this is done in 2_config.sh):
#  dconf load / < dconf-settings.ini
#
# * 2024-12-05 -  Mint 22 Cinnamon
#   2024: auto-cpufreq not available in Mint 22 repos, so we get it from GitHub
#        (https://github.com/AdnanHodzic/auto-cpufreq)

 sudo apt update && sudo apt upgrade -y
# synaptic is already preinstalled in Mint 22
# sudo apt install -y synaptic
 sudo apt install -y apt-xapian-index build-essential
 sudo apt install -y dos2unix emacs psutils cifs-utils openssh-server
 sudo apt install -y xscreensaver-gl xscreensaver-gl-extra
 sudo apt install -y gawk pdftk-java bashtop juffed
# sudo apt install -y stellarium timidity tuxguitar
# auto-cpufreq needs git
 sudo apt install -y git
# python3; we create and activate a virtual environment (myv) to install most packages
 sudo apt install -y idle python3-pip
 sudo apt install -y python3-xlib python3-tk python3-dev python3-venv
 python3 -m venv ~/.venv/myv
 cd ~/.venv/myv/bin
 ./pip install numpy scipy matplotlib ipython jupyter pandas sympy nose
# To activate venv:
#  source ~/.venv/myv/bin/activate
# To deactivate, simply do:   deactivate
 cd ~
# Add some aliases to ~/.bashrc
 echo "alias ls='ls -FCs --color'
alias py=python3
source ~/.venv/myv/bin/activate
" >> ~/.bashrc
# Install auto-cpufreq (downloading from GitHub)
 git clone https://github.com/AdnanHodzic/auto-cpufreq.git
 cd auto-cpufreq && sudo ./auto-cpufreq-installer
 cd ~
 sudo auto-cpufreq --install
# undo the below with unmask instead of mask, and delete the HandleLidSwitch lines
 sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
echo "[Login]
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
" | sudo tee -a /etc/systemd/logind.conf
# tell linux this machine's clock is in local time (not UTC)
 sudo timedatectl set-local-rtc 1
 echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - -"
 echo "- - Added the 3 lines below to /etc/systemd/logind.conf"
 echo "[Login]"
 echo "HandleLidSwitch=ignore"
 echo "HandleLidSwitchDocked=ignore"
 echo "- - And configured .bashrc"
 echo "    Note: to activate venv:"
 echo " source ~/.venv/myv/bin/activate"
 echo "    To deactivate, simply do:   deactivate"
 echo "- - Reboot now!"
 echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - -"
