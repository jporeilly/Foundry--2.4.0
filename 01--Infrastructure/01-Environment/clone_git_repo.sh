!/bin/bash

# =========================================================================================
# check Workshop-Foundry directory exists
# remove Workshop-Foundry 
# create Workshop-Foundry/directory
# clone remote git Foundry--Deployment repository to /installers/Workshop-Foundry directory
# copy files over to /etc/ansible/playbooks
# tidy up directory..
# dont forget to close and open VSC ..
#
# 30/09/2022
# =========================================================================================

#set the loads of variables
remoteHost=github.com
remoteUser=jporeilly
localUser=installer
remoteDir=Foundry--2.4.0
remoteRepo=https://$remoteHost/$remoteUser/$remoteDir
localDir=/installers
localDirW=/installers/Workshop--Foundry-2.4.0
ansPlaybooks=/etc/ansible/playbooks
mod_01E=$localDirW/01--Infrastructure/01-Environment
mod_01A=$localDirW/01--Infrastructure/02-Ansible
mod_02=$localDirW/02--Pre-flight
mod_03=$localDirW/03--Foundry
mod_04=$localDirW/04--Visualization

# check to see if local directory exists
if [ -d "$localDirW" -a ! -h "$localDirW" ]
then
    echo "Directory $localDirW exists .." 
    echo "Deleting $localDirW .."
    sudo rm -rf $localDirW
else
    echo "Error: Directory $localDirW does not exists .."
fi
    echo "Creating $localDirW directory .."
    sudo mkdir $localDirW
    sudo git clone $remoteRepo $localDirW
    sudo chown -R $localUser $localDirW
    echo "Deleting $ansPlaybooks .."
    sudo rm -rfv $ansPlaybooks/*
    echo "Copying over Module 01 - Infrastructure .."
    sudo cp -rfp $mod_01E/*  $ansPlaybooks
    sudo cp -rfp $mod_01A/*  $ansPlaybooks
    echo "Copying over Module 02 - Pre-flight .."
    sudo cp -rfp $mod_02/*  $ansPlaybooks
    echo "Copying over Module 03 - Foundry .."
    sudo cp -rfp $mod_03/*  $ansPlaybooks
    echo "Copying over Module 04 - Visualization .."
    sudo cp -rfp $mod_04/*  $ansPlaybooks
    echo "Copy over ansible configuration files .."
    sudo cp -rfp 
    echo "Tidying up directory .."
    sudo rm -rfv $ansPlaybooks/*.md
    sudo rm -rfv $ansPlaybooks/resources
    sudo rm -rfv $ansPlaybooks/assets
    echo "Latest Foundry Workshop copied over .. close and open VSC .."