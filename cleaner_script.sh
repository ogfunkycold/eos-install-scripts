#!/bin/bash

# Made by fernandomaroto for EndeavourOS and Portergos

# Adapted from AIS. An excellent bit of code!

if [ -f /tmp/chrootpath.txt ]
then 
    chroot_path=$(cat /tmp/chrootpath.txt |sed 's/\/tmp\///')
else 
    chroot_path=$(lsblk |grep "calamares-root" |awk '{ print $NF }' |sed -e 's/\/tmp\///' -e 's/\/.*$//' |tail -n1)
fi

if [ -f /tmp/new_username.txt ]
then
    NEW_USER=$(cat /tmp/new_username.txt)
else
    #NEW_USER=$(compgen -u |tail -n -1)
    NEW_USER=$(cat /tmp/$chroot_path/etc/passwd | grep "/home" |cut -d: -f1 |head -1)
fi

arch_chroot(){
# Use chroot not arch-chroot because of the way calamares mounts partitions
    chroot /tmp/$chroot_path /bin/bash -c "${1}"
}  

# Anything to be executed outside chroot need to be here.

# Copy any file from live environment to new system

cp -rf /etc/skel/.bashrc /tmp/$chroot_path/home/$NEW_USER/.bashrc

_copy_files(){

    local _files_to_copy=(

    
    /etc/lightdm/*
    /etc/sddm.conf.d/kde_settings.conf
    /etc/pacman.d/hooks/lsb-release.hook
    /etc/pacman.d/hooks/os-release.hook
    

)
    # /etc/os-release /etc/lsb-release removed, using sed now at chrooted script
    # /etc/default/grub # Removed from above since cleaner scripts are moved to last step at calamares
    # https://forum.endeavouros.com/t/calamares-3-2-24-needs-testing/4941/37
    
    local xx

# Uses the entire file path and copies directly to / mounted point
    for xx in ${_files_to_copy[*]}; do rsync -vaRI $xx /tmp/$chroot_path; done

}

_copy_files

# For chrooted commands edit the script bellow directly
arch_chroot "/usr/bin/chrooted_cleaner_script.sh"
