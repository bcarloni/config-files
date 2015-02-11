#!/usr/bin/expect

proc getProps {propsFile out} {
    upvar $out props
    set key ""

    # Open the properties file
    set file $propsFile
    set fp [open $file r]
    fconfigure $fp -buffering line

    # Fetch the first line
    gets $fp line

    # Read the lines
    while {$line != ""} {
    # Check for comments in the file and ignore
    if { [regexp "\=\#\#" $line] == 0 } {
    # Split each property line into key/val pairs
    set keyAndVal [split $line "="]
    foreach item $keyAndVal {
    if { $key == "" } {
    set key $item
    } else {
    # Set the values to the array
    set props($key) $item
    # Reset key
    set key ""
    }
    }
    }

    # Increment to the next line
    gets $fp line
    }
}

proc getopt {_argv name {_var ""} {default ""}} {
     upvar 1 $_argv argv $_var var
     set pos [lsearch -regexp $argv ^$name]
     if {$pos>=0} {
         set to $pos
         if {$_var ne ""} {
             set var [lindex $argv [incr to]]
         }
         return 1
     } else {
         if {[llength [info level 0]] == 5} {set var $default}
         return 0
     }
 }

getProps $env(HOME)/.melicssh/config properties;

set timeout $properties(timeout)
match_max $properties(match_max)
set user $properties(user)
set passwordrobin $properties(user_$user)
getopt argv -l userserver $user

if [ regexp -nocase {.*{}*} $argv matchresult ] then {
    set argsssh [lrange $argv 0 end-1]
} else {
    set argsssh $argv
}

set server [lrange $argv end end]

if {[info exists properties(user_${userserver}_$server)]} {
    set password $properties(user_${userserver}_$server)
} else {
    if {[info exists properties(user_$userserver)]} {
        set password $properties(user_$userserver)
    } else {
        set password ""
    }
}

#trap sigwinch and pass it to the child we spawned
trap {
 set rows [stty rows]
 set cols [stty columns]
 stty rows $rows columns $cols < $spawn_out(slave,name)
} WINCH

#trap sigwinch and pass it to the child we spawned
trap {
 set rows [stty rows]
 set cols [stty columns]
 stty rows $rows columns $cols < $spawn_out(slave,name)
} SIGWINCH

puts "Entrando a gateway con usuario $user...\n"
spawn /usr/bin/ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HashKnownHosts=yes -o ServerAliveInterval=1000 $user@$properties(gateway)


expect {
    "*yes/no*" { send "yes\r"; exp_continue }
    -nocase "*assword:*" { send "$passwordrobin\r"; exp_continue }
    "]# " {  }
    "]> " {  }
    "*$*" {  }
    "~>" {  }
    " ~" {  }

}
if { $argsssh != "" } then  {
puts "Entrando a server con usuario $user...\n"
send "ssh -o ConnectTimeout=5 -o ConnectionAttempts=1 -o ServerAliveInterval=1000 $argsssh\r"


expect {
  -nocase "*assword:*" {
    if { $password != ""} {
        send "$password\r"
        expect {
          "*yes/no* " { send "yes\r"; exp_continue }
          "]#*" { send "clear\r" }
          "]$*" { send "clear\r" }
          "]>*" { send "clear\r" }
          "~$*" { send "clear\r" }
          "/>*" { send "clear\r" }
          "$*" { send "clear\r" }
          " ~" { send "clear\r" }
          "~>" { send "clear\r"  }
          "*assword:*" { interact  }
        }
    }
  }
  "*yes/no* " { send "yes\r"; exp_continue }
  "]#*" { send "clear\r" }
  "]$*" { send "clear\r" }
  "]>*" { send "clear\r" }
  "~$*" { send "clear\r" }
  "/>*" { send "clear\r" }
  "$*" { send "clear\r" }
  "~>" { send "clear\r"  }
  " ~" { send "clear\r" }

  "Name or service not known" { }
  "Permission denied, please try again." { }
  eof  {break}
}

send "\[ -e /home/batman \] && echo 'Cerrando ventana en 5 segundos, se quedo en batman...' && sleep 5 && exit\r"
send "clear\r"
}
interact

