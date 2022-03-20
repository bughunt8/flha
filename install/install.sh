#!/bin/bash
echo
echo '*** Install script for remote access for Konnekt devices'
echo

SUDO=
if [ "$UID" != "0" ]; then
	if [ -e /usr/bin/sudo -o -e /bin/sudo ]; then
		SUDO=sudo
	else
		echo '*** This quick installer script requires root privileges.'
		exit 0
	fi
fi

# Detect already-installed on Linux
#if [ -f /usr/sbin/zerotier-one ]; then
#	echo '*** ZeroTier appears to already be installed.'
#	exit 0
#fi

  echo
	echo '*** Adding Original APT Sources...'
	$SUDO mv -f /etc/apt/sources.list /etc/apt/sources.saved.list
	$SUDO cp -f /media/konnekt/9216-/sources.list /etc/apt/sources.list
	$SUDO chown 0 /etc/apt/sources.list
	$SUDO chgrp 0 /etc/apt/sources.list

	echo
	echo '*** Installing tinysshd server ...'
	$SUDO apt install tinysshd

	echo
	echo '*** Installing public key ID ...'
	cp /media/konnekt/9216-/id_ed25519.pub /home/konnekt/.ssh/authorized_keys

	echo
	echo '*** Changing UFW rules to allow SSH from ZT Network ...'
	$SUDO ufw allow from 10.100.0.0/16 to any port 22 proto tcp

  echo
	echo '*** zerotier-one via script...'
  if [ -e ./install_zt.sh ]; then
		$SUDO ./install_zt.sh
	fi

exit 0
