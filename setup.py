#! /usr/bin/env python

#
#   Instalation of config-files
#   Just run "python setup.py"
#

import os

print("\nBruno Carloni\n")
print("Initializing config-files installation ...\n")

print("\nCreating directory  ~/dev")
os.system("mkdir ~/dev")

#Creating data storage
path = os.environ['HOME'] + "/dev/config.dat"
if os.path.exists(path) == False:
    file = open(os.path.join(path), 'w+')
    file.write("user:" + raw_input("User:")  + "\n")
    file.write("pass:" + raw_input("Pass:") + "\n")

print("\nCloning git@github.com:bcarloni/config-files.git  into  ~/dev/config-files")
os.system("rm -rf ~/dev/config-files")
os.system("git clone git@github.com:bcarloni/config-files.git ~/dev/config-files")

print("\nSeting symbolic link to: ~/.gitconfig")
os.system("rm ~/.gitconfig")
os.system("ln -s ~/dev/config-files/.gitconfig ~/.gitconfig")

print("\nSeting symbolic link to: ~/.bash_profile")
os.system("rm ~/.bash_profile")
os.system("ln -s ~/dev/config-files/.bash_profile ~/.bash_profile")

print("\nUpdating bash terminal")
os.system("source ~/.bash_profile")

print("\nconfig-files Installed...")