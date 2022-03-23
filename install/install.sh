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
	#$SUDO mv -f /etc/apt/sources.list /etc/apt/sources.saved.list
	#$SUDO cat >> /media/konnekt/9216-/sources.list /etc/apt/sources.list
	$SUDO mv /home/konnekt/flha/install/sources.list /etc/apt/sources.list.d/sources.list
	$SUDO chown 0 /etc/apt/sources.list.d/sources.list
	$SUDO chgrp 0 /etc/apt/sources.list.d/sources.list

	echo
	echo '*** Installing tinysshd server ...'
	$SUDO apt update
	$SUDO apt install tinysshd

	echo
	echo '*** Installing public key ID ...'
	mkdir /home/konnekt/.ssh/
	chmod 700 /home/konnekt/.ssh/
	#cp /media/konnekt/9216-/id_ed25519.pub /home/konnekt/.ssh/authorized_keys
	cp /home/konnekt/flha/install/id_ed25519.pub /home/konnekt/.ssh/authorized_keys
	chmod 644 /home/konnekt/.ssh/authorized_keys

	echo
	echo '*** Changing UFW rules to allow SSH from ZT Network ...'
	$SUDO ufw allow from 10.100.0.0/16 to any port 22 proto tcp

  echo
	echo '*** zerotier-one via script...'
  if [ -e ./install_zt.sh ]; then
		$SUDO ./install_zt.sh
	fi

  echo
	echo '*** Joining ZT Network...'
	$SUDO /usr/sbin/zerotier-cli join 159924d630fd6db6

  echo
	echo 'Done.''
exit 0
