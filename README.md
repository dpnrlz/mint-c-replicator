# mint-c-replicator
Replicate your current  Linux Mint Cinnamon setup

# Welcome to the Mint Cinnamon Replicator

Replicate with little effort your current Mint setup so you can go from an out-of-the-box installation looking like this

![freshmint](https://github.com/dpnrlz/mint-c-replicator/blob/main/img1-before.png "Before")

to something with the software and the looks you like, in no-time; maybe like this

![mymint](https://github.com/dpnrlz/mint-c-replicator/blob/main/img2-after.png "After")


# What this is (and is not)

This project is a collection of steps and shell scripts to replicate your customised Linux Mint system (settings for desktop and most apps) to other, fresh installations of Linux Mint.
It is not a download-and-use package, but a guide meant to be adapted to each case. NOTE that **this does not a back up your data files**, it's only for preparation of a new system (although you can of course modify this to include some sort of backup).
Alternatively, it is possible make your own ("DVD/USB") install media to include/exclude software, configurations, etc., but for small-scale use that's not as simple as the recipe I show here --making your own linux install media is simpler if you have to deploy the same system on lots of computers, but if you need that you won't be reading this guide!

**Use-case**: you have installed and configured your Linux Mint and software, are happy with the way it looks and works, and now you want to replicate the same on other computers (maybe on virtual machines to do other stuff) without doing everything by hand again and again.

This is most useful when you always do the same things to a new system so that it looks and behaves the way you want; some examples:
* You define some variables and aliases in your ~.bashrc file.
* You like to add some particular applets (like weather, etc.) to the panel. Adding applets is easy enough, but: 1) they have to be added one by one, 2) they also have to be configured one by one, and some applets have many settings to modify (for example, maybe you want the "System Monitor" but don't want to show the "Load", and so on).
* In the file manager (e.g. Nemo), you prefer a different column order, or different columns, column widths, toolbar buttons, view, etc.
* You want to apply some theme.
* You install certain applications, and also customise their settings.
* In recent Python installations (apparently since Ubuntu 24.04 and Mint 22, for instance), many packages cannot be installed anymore with a simple `pip install thepackage`. The system refuses to do it and basically requires to do these installs within a virtual environment (*).

> (*) The `--break-system-packages` flag in pip allows to override the `externally-managed-environment` error and install Python packages system-wide, but this is asking for trouble and it's safer to use virtual environments.
> See for example [this stack overflow post](https://stackoverflow.com/questions/75608323/how-do-i-solve-error-externally-managed-environment-every-time-i-use-pip-3)

# Long story short

This section is the TL/DR version, for when you know what you're doing and only need a quick guide: just follow steps 1-3 and you're done.
If this is your first time here, I recommend reading the long story first, to understand what is done and what you need to adapt to your case.

### Steps

1. Prepare your "backup" source files and copy them e.g. to a USB (see the .sh scripts for examples).
    * Dot files, dot directories, list of software & (python) packages, locale file, dconf backup (`dconf dump / > dconf-settings.ini`), and .sh scripts.

2. Do the new Mint install on the new computer.

3. On the new system:
    1. Edit the `/etc/default/locale` file if needed; do an initial update with\
       `sudo apt update && sudo apt upgrade -y`\
       and reboot.
    2. Run\
       `source 1_packs.sh`\
       (user interaction may be needed) and reboot.
    3. Run\
       `source 2_config.sh`\
       and reboot.


# Detailed story

The recipe I developed, described below, is a setp-by-step guide and two bash shell scripts to go from a fresh install to a working system for my use-case. Some notes to consider:

* This has been tested on Mint 22 Cinnamon, and some things may/will not apply or work for other distros, DEs (Mate, XFce...) or other major versions of Mint Cinnamon, but should be a good starting point.

* The process is likely not optimised yet, and includes three reboots, some of which may not be strictly necessary (perhaps service restarts or log outs/ins might be enough, but so far I have not looked into that); in any case, this recipe works :)

* Follow the steps below, which include some commands in the terminal, and running a couple of scripts. The scripts I made here include some examples of software to install, but you should modify them for your desired apps and python packages. Still, some of them should be kept (marked as such in the .sh files).

* As the Python packages I need have the problem I described above, the script installs python-venv, then creates a virtual environment in the user's home, activates it, and adds it to the ~/.bashrc file so that it is automatically activated when opening a terminal.

## 1. Preparation
Install and set up the "source" system; install apps, desktop applets & themes, configure settings, customise, etc. Once ready, create some "backup" directory where we will place all files, settings, etc to be transplanted. Copy the 2 shell scripts (`1_packs.sh` and `2_config.sh`) to this directory too. Let's say this directory is ~/mybak

### 1a.
Export your DE settings to a file:\
` dconf dump / > ~/mybak/dconf-settings.ini`

### 1b.
Copy language settings:\
` cp /etc/default/locale ~/myback/mylocale`\
  For example, for UK English this file may contain (make sure to include LC_TIME):\
LANG=en_GB.UTF-8\
LANGUAGE=en_GB:en\
LC_NUMERIC=en_GB.UTF-8\
LC_TIME=en_GB.UTF-8\
LC_MONETARY=en_GB.UTF-8\
LC_PAPER=en_GB.UTF-8\
LC_IDENTIFICATION=en_GB.UTF-8\
LC_NAME=en_GB.UTF-8\
LC_ADDRESS=en_GB.UTF-8\
LC_TELEPHONE=en_GB.UTF-8\
LC_MEASUREMENT=en_GB.UTF-8\

### 1c.
Copy the relevant dot files and dot directories, e.g. (adjust as per your system; some files or directories may not exist, but keeping them in the lists below should not cause problems):

` for i in .dmrc .emacs .gtkrc-2.0 .gtkrc-xfce .pam_environment .profile .xsessionrc ; do cp $i ~/mybak ; done`\
` for i in .config .gnupg .grsync .idlerc .linuxmint .local .mozilla .stellarium .themes .tuxguitar* ; do cp -r $i ~/mybak ; done`

- Of the dot files (first line), `.emacs` might not exist or be needed in general, unless you use emacs _and_ have made customisations to it.

- Of the dot directories (second line), `.idlerc` only exists if you have installed the Idle Python IDE, and similarly for `.themes` (if you have installed additional themes), `.stellarium` and `.tuxguitar*`.

- About Mozilla Firefox:
Copying a profile (especially if, for instance, it contains logged in sessions) may cause problems, so I recommend that in the "source" system, before making this "backup", only the general Firefox settings are changed and aesthetic changes are made; do not log in, save passwords or sessions, etc (even clear any cookies and cache) before making the "backup" copy. Perhaps simply excluding the profile/s subdirectories inside `.mozilla/firefox` could be enough to avoid issues (although it might still cause problems with conflicting Firefox versions, if Firefox was updated in the "source" system since its own fresh install), or maybe keeping the full profile/s works for you, so adapt to your liking. In any case, most (if not all) settings and bookmarks, etc can be later [synchronised natively by Firefox](https://www.mozilla.org/en-US/firefox/features/sync/) by logging in to your Mozilla account after the general setup is done.

- About TuxGuitar & others:
For some software, the config folders include, apart from the software name, its version; for example for TuxGuitar the config directory as of Dec/2024 is `~/.tuxguitar-1.5.6`, which will change at some point, and that's why the command above considers `.tuxguitar*`. Blender and Gimp do a similar thing, although inside the `~/.config` directory (e.g. `~/.config/blender/4.0`).

### 1d.
Copy the setup scripts (`1_packs.sh` and `2_config.sh`) to the backup directory.

### 1e.
Copy the backup directory to a USB or any portable location. Now we are ready!

## 2. Install Linux Mint on the new computer/s.
Just follow the graphical installer (I recommend to activate the option to "Install multimedia codecs") until it finishes and asks for a reboot. After the reboot, log in. The rest of the steps are done on this new machine.

## 3. Locale
Open a terminal and edit the locale file (see step 1b above); delete all lines from this file in the new system and copy-paste the lines from `mylocale`:\
`sudo nano /etc/default/locale`\
When done, use `ctrl+x` and then `y` to save the file and close it. Then reboot, and log back in. This reboot seems safe to skip if we immediately do step 4.

## 4. Initial update
Open a terminal and do:\
` sudo apt update && sudo apt upgrade -y`\
The first script (`1_packs.sh`) will do an update before installing packages, but for extra safety, do this initial update here. When done, reboot and log back in. Usually, apt will tell us if a reboot is needed after the update, and maybe a log out/in might suffice, but I prefer to reboot here too.

## 5. .bashrc, software, Python
Open a terminal, go to the directory with the scripts and run:\
` source 1_packs.sh`\
  which installs stuff and creates a Python venv.\
Note that the installation of the following requires user interaction:
* openssh-server   (for any email server)
* auto-cpufreq   (type I to install; note that auto-cpufreq requires git, which is installed by `1_packs.sh`, and the auto-cpufreq installer auto-downloads whatever else it needs).

When done, reboot and log back in.

## 6. Looks
Open a terminal, go to the directory with the scripts and run:\
` source 2_config.sh`\
When finished, reboot and log back in. We're done!


# Additional notes / issues

* If you are curious, the theme shown on the "after" screenshot is "Graphite-Zero", with "Mint-Y-Sand" icons.
* The applets shown on the same are: "Weather", "System Monitor", "Graphical Hardware Monitor", and "Workspace switcher" (to the right of the clock). For the Graphical HW Monitor, in my "base" machine I hide all tabs except the Disk ones (for read and for write), but for some reason this setting is not kept, and all tabs are being shown in the new machine, so this setting seems to be saved somewhere else.
