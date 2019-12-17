#!/usr/bin/env bash

##cosmetic functions and Variables
##Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'
BLUE='\033[0;34m'

##Break function for readabillity
BR()
{
  echo "  "
}

##DoubleBreak function for readabillity
DBR()
{
  echo " "
  echo " "
}

##Paths
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"  ##Homedir
toBeInjectedFolder="$DIR/toBeInjected"


printf "${GREEN}drag and drop the config.Plist${NC}\n"
read configPlist
#configPlist="/Users/Niels/Dropbox/UCB/Scriptz/InjectConfigPlist/Config.plist"

ipaCheck()
{
  for toBeInjected in "$toBeInjectedFolder"/*
    do
      ipaFileExtentions="${toBeInjected##*.}"                     ##extract just the FileExtention without the dot
      echo File to be Exploded: $toBeInjected
      echo FileExtention: $ipaFileExtentions
      if [ $ipaFileExtentions == "ipa" ]                            ##if the FileExtention equals ipa
        then
          amountOfIpas+=("$toBeInjected")                         ##put the file in an array
          ipaArrayLength=${#amountOfIpas[@]}                        ##Get the array length for the next statement
        fi
    done
  if [[ $ipaArrayLength < "1" ]]                                    ## if the array length is less than 1, exit the script
   then
    printf "${RED}no ipa present in the toBeInjectedFolder: $toBeInjectedFolder${NC}\n"
    exit 113                                                        ##exit with code 113
  fi
}

getOgIpa()
{
    printf "${GREEN}Get the og app name${NC}\n"
    for apps in "$toBeInjectedFolder"/*                                             ##for every file in the folder
     do
      ogIpa=$(echo "$(basename "$apps")")                                         ##Get the filename with extention
      ogIpaNoExtention=$(echo "$(basename "$apps" .ipa)")
      printf "${YELLOW}The ipa that will be processed: ${GREEN}$ogIpa${NC}\n"
    done
    payloadFolder="$DIR/$ogIpa/Payload"
}

unZip()
{
    printf "${GREEN}Unzipping the ipa${NC}\n"
    cd $toBeInjectedFolder
    unzip "$ogIpa" -d $DIR/$ogIpa                                                ##unzip the ipa in a temp folder
}

copyConfigPlist()
{
    printf "${GREEN}Copy the plist${NC}\n"
    # cd "$DIR/$ogIpa/Payload"
    cd $payloadFolder
    # printf "${RED}DEBUGGING payloadFolder: $payloadFolder${NC}\n"
    # printf "${RED}DEBUGGING ogIpa: $ogIpa${NC}\n"
    # printf "${RED}DEBUGGING DIR: $DIR${NC}\n"
    payloadApp=$(ls | grep '.app')
    #printf "${RED}DEBUGGING copyPlist payloadApp: $payloadApp ${NC}\n"
    cd "$payloadFolder/$payloadApp"
    cp -v $configPlist $payloadFolder/$payloadApp/Config.plist
}

zipIpa()
{
    printf "${GREEN}Zipping the payloadFolder${NC}\n"
    cd $payloadFolder
    echo payloadFolder $payloadFolder
    find . -name ".DS_Store" -exec rm -rf {} +;
    cd $DIR/$ogIpa
    printf "${GREEN} ogipaname: $ogIpa ${NC}\n"
    zipIpaName="$ogIpaNoExtention"_Injectedconfig.ipa
    zip -r "$zipIpaName" ./Payload
}

folderCleanup()
{
    rm -rf "$payloadFolder"
}

ipaCheck
getOgIpa
unZip
copyConfigPlist
zipIpa
folderCleanup
