#!/bin/bash

read -p "username to be removed : " Pengguna

if getent passwd $Pengguna > /dev/null 2>&1; then
        userdel $Pengguna
        echo -e "User $Pengguna telah dihapus."
else
        echo -e "GAGAL: User $Pengguna tidak ada."
fi
