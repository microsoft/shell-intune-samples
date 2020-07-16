#!/bin/bash

# Script to install Company Portal

# Let's check to see if CP is already installed...
if [[ -a "/Applications/Company Portal.app" ]]; then
  echo "Company Portal already installed, nothing to do here"
  exit 0
else
  echo "Downloading Company Portal"  | tee -a /var/log/install.log
  curl -L -o /tmp/cp.pkg 'https://go.microsoft.com/fwlink/?linkid=853070'
  echo "Installing Company Portal"  | tee -a /var/log/install.log
  installer -pkg /tmp/cp.pkg -target / | tee -a /var/log/install.log
fi
