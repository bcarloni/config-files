#!/usr/bin/env python
import pexpect
import struct, fcntl, os, sys, signal

def sigwinch_passthrough (sig, data):
    # Check for buggy platforms (see pexpect.setwinsize()).
    if 'TIOCGWINSZ' in dir(termios):
        TIOCGWINSZ = termios.TIOCGWINSZ
    else:
        TIOCGWINSZ = 1074295912 # assume
    s = struct.pack ("HHHH", 0, 0, 0, 0)
    a = struct.unpack ('HHHH', fcntl.ioctl(sys.stdout.fileno(), TIOCGWINSZ , s))
    global global_pexpect_instance
    global_pexpect_instance.setwinsize(a[0],a[1])

#Load config file
user = ""
password = ""
path = os.environ['HOME'] + "/dev/config.dat"
if os.path.exists(path) == False:
    file = open(os.path.join(path), 'w+')
    file.write("meli_user:" + raw_input("MELI User:")  + "\n")
    file.write("meli_password:" + raw_input("MELI Pass:") + "\n")

f = open( os.path.join(path) )
try:
    for line in f:
        if "meli_user:" in line:
            user = str(line).split(':')[1]
            user = str(user).split('\n')[0]
        if "meli_password:" in line:
            password = str(line).split(':')[1]
            password = str(str(password).split('\n')[0])
finally:
    f.close()
#Pass and user setted

ssh_newkey = 'Are you sure you want to continue connecting'
p=pexpect.spawn('ssh ' + str(user) + '@10.100.41.3')
i=p.expect([ssh_newkey,'password:',pexpect.EOF])
p.sendline(password)
p.sendline("\r")
global global_pexpect_instance
global_pexpect_instance = p
signal.signal(signal.SIGWINCH, sigwinch_passthrough)

try:
    p.interact()
    sys.exit(0)
except:
    sys.exit(1)