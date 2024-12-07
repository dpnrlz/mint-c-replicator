#!/bin/bash
# Script to setup Cinnamon DE in Mint 22.
#
# DO NOT RUN this script from your home folder
#
# BEFORE using this script, copy the relevant dot files and directories
# from the home folder on the base machine, and include those in this script
#
# 2024-12-05 - Mint 22 Cinnamon
#

mydir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo " "
echo " Home folder is $HOME"
echo " Running config script from ${mydir}"
if [ ${mydir} == $HOME ] ; then
  echo " ERROR! Do not run this script from the user's home"
  echo " Nothing done. Aborting..."
  exit
fi

dotd=".config .idlerc .linuxmint .local .mozilla .stellarium .themes .tuxguitar*"
dotf=".dmrc .emacs .gtkrc-2.0 .gtkrc-xfce .pam_environment .profile .xsessionrc"

sudo apt update && sudo apt upgrade -y

# dot directories; first remove existing ones from the new machine's home
cd ~
rm -fr $dotd
# now copy the ones from the backup
cd $mydir
for i in $dotd ; do cp -r $i ~/ ; done
# still in the backup's folder, copy/replace dot files to the new machine's home
for i in $dotf ; do cp $i ~/ ; done
# load the dconf settings backup to the new machine
cd $mydir
dconf load / < dconf-settings.ini
echo "- - - - - - - - - -"
echo " Done! Reboot now"
echo "- - - - - - - - - -"
