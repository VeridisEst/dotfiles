#!/bin/sh

# Complete a WSL2 setup for Debian

# Update Debian package libraries
sudo apt update
sudo apt upgrade

# Install things I like
sudo apt install \
	git \
	gh \
	wget \
 	make
#neovim 

#installing neovim v0.10 from the releases file
wget https://github.com/neovim/neovim-releases/releases/download/nightly/nvim-linux64.deb
sudo apt install ./nvim-linux64.deb
#bingo!

# TODO Figure out what more I use standard..
# TODO see if I use any non standard software, like, usually
# TODO finish these things and see if I can make a standard upload way
