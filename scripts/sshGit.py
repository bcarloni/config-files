#! /usr/bin/env python

#
#   Used to get and set the new public/private ssh key for GITHUB
#

import os

print("Generating new key for GITHUB")

os.system("ssh-keygen -t rsa -C 'bruno.carloni@mercadolibre.com' -f ~/.ssh/git")
os.system("ssh-add ~/.ssh/git")
os.system("pbcopy < ~/.ssh/git.pub")

print("The key for github is in the clipboard")
print("https://github.com/settings/ssh")