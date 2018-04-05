#!/bin/bash

read -p "username to be removed : " Pengguna

if getent passwd $Pengguna > /dev/null 2>&1; then
        userdel $Pengguna
        echo -e "User $Pengguna removed"
else
        echo -e "FAILED: User $ User does not exist."
fi
