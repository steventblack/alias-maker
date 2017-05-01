#!/bin/bash

#######################
# (C) 2017 Steven Black
#######################
#
# 2017-05-01 - 0.0.1 validate alias is permitted
#
#######################


# response
send_response () {
  echo "$1"
}

# validate the alias
# ensure only limited set of characters permitted for aliases in order to
# mitigate security risks. (e.g. some jerk trying to set an alias that
# pipes to a shell function)
validate_alias () {
  # only lower-case letters are permitted, but this can be corrected
  local Lower=`echo $1 | tr '[:upper:]' '[:lower:]'`
  
  # check only permitted characters are used
  # (lowercase letters, digits, "-", "_", and ".")
  local Valid=`echo $Lower | tr -c -d [:lower:][:digit:]\-\_\.`
  if [ $Valid != $Lower ]; then 
    send_response "\"$Lower\" does not conform to alias format; please specify a different alias."
    return 1
  fi

  # check the length of the alias to avoid naughtiness
  local AliasLen=`echo ${#Lower}`
  if [ $AliasLen -gt 32 ]; then
    send_response "\"$Lower\" is too long; please specify a different alias."
    return 1
  fi

  # check the alias file to see if the desired alias already in use
  local AliasExists=`awk -F : '{print $1}' "${RootDir}/etc/aliases" | grep -c -w "$Lower"`
  if [ $AliasExists -gt 0 ]; then
    send_response "\"$Lower\" is already in use; please specify a different alias."
    return 1
  fi

  # check the users list to ensure alias isn't a real username
  local UserExists=`synouser --enum all | \
            grep -v "User Listed" | \
            awk -F @ '{print $1}' | \
            grep -c -w "$Lower"`
  if [ $UserExists -gt 0 ]; then
    send_response "\"$Lower\" is already in use; please specify a different alias."
    return 1
  fi
  
  return 0
}

RootDir="/var/packages/MailServer/target"

validate_alias "Fruit"
validate_alias "Bat"
validate_alias "Wargarble"
validate_alias "stb"
validate_alias "steven"
validate_alias "fruit-bat"
validate_alias "batty!"
validate_alias "fruit-bat1923"
validate_alias "#fruitbat"
validate_alias "\nhahaha|/bin/nasty"
validate_alias "thisisavery-very-very-longaliasthatshouldexceedlimits"
