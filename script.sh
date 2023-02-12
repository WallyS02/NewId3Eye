# Author           : Sebastian Kutny (sebkutny@gmail.com)
# Created On       : 26.04.2022r.
# Last Modified By : Sebastian Kutny (sebkutny@gmail.com)
# Last Modified On : 27.04.2022r.
# Version          : 1.0
#
# Description      :
# Opis
#
#		   Script will help user to find mp3 files by their id3 tags, allow him/her to modify or set them, 
#		   organize them in directories and automatically set their tags after sorting.
#		   It will use eyeD3 tool. It will display an user-friendly
#	 	   graphical interface (zenity), with all options for features presented above.
#		   
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

#!/bin/bash

CHOICE=0

while getopts hv OPT; do
case $OPT in
h) zenity --info --title "Help" --text "Welcome to newId3EYE! After running script pick one option and set it's given parameter to execute it. All important information included int options." --width=300 --height=400
zenity --question --title "Run" --text "Continue running script?"
if [ $? -eq 1 ]; then
CHOICE=6
fi ;;
v) zenity --info --title "Version" --text "Welcome to newId3EYE! Current version is 1.0, author's name is Sebastian Kutny." --width=300 --height=400
zenity --question --title "Run" --text "Continue running script?"
if [ $? -eq 1 ]; then
CHOICE=6
fi ;;
*) zenity --error --text "Wrong Option!"
CHOICE=6 ;;
esac
done

if [ $CHOICE -ne 6 ]; then
zenity --info --title "Start" --text "Welcome to newId3EYE! Pick an option or run script with other options: " --width=300 --height=100
fi

while [ $CHOICE -ne 6 ]; do

menu=("1. Modification of a id3 tag" "2. Check id3 tag" "3. Organization of directory , REMEMBER ABOUT FILES WITH NAME PATTERN: ARTIST-TITLE-ALBUM-TRACK" "4. Automatic seting id3 tags in directory, USE ONLY ON ORGINIZED DIRECTORIES!" "5. Install eyeD3, REMEMBER TO TYPE YOUR ACCOUNT PASSWORD IN CONSOLE!" "6. Exit")
CHOICE=`zenity --list --column=Menu "${menu[@]}" --height 300 --width 800`

case $CHOICE in 

1*) 
NAMEMOD=`zenity --entry --title "Modification" --text "Type file's name: "`
CHECKMOD=$(find -name "$NAMEMOD")
if [ -z "$CHECKMOD" ]; then
	zenity --error --text "No mp3 files named like you typed!"
else
CHOICEMOD=0
zenity --info --title "Modification" --text "Insert your id3 tags for this file: "
while [ $CHOICEMOD -ne 6 ]; do
menu=("1. Title: $TITLE" "2. Artist: $ARTIST" "3. Album: $ALBUM" "4. Track: $TRACK" "5. Insert data" "6. Exit")
CHOICEMOD=`zenity --list --column=Menu "${menu[@]}" --height 300 --width 200`
case $CHOICEMOD in 

1*) 
TITLE=`zenity --entry --title "Song title" --text "Insert song title: "`
CHOICEMOD=0 ;;

2*)
ARTIST=`zenity --entry --title "Artist" --text "Insert song artist: "`
CHOICEMOD=0 ;;

3*)
ALBUM=`zenity --entry --title "Album" --text "Insert song album: "`
CHOICEMOD=0 ;;

4*) 
TRACK=`zenity --entry --title "Track" --text "Insert song track number: "`
CHOICEMOD=0 ;;

5*)
while [ "${CHECKMOD: -1}" != "/" ]; do
	CHECKMOD=$(echo $CHECKMOD | rev | cut -c2- | rev )
done
CHECKMOD=$(echo $CHECKMOD | rev | cut -c2- | rev )
cd "$CHECKMOD"
SET=$(eyeD3 -a "$ARTIST" -A "$ALBUM" -t "$TITLE" -n "$TRACK" "$NAMEMOD") 
if [ -z "$SET" ]; then
	zenity --error --text "Something went wrong"
	CHOICEMOD=0
else
	zenity --info --title "Success" --text "Id3 tags successfully set!"
	CHOICEMOD=6
fi;;

6*)
zenity --info --title "Exit" --text "Goodbye!"
CHOICEMOD=6
;;
esac
done
fi
cd ~
CHOICE=0 ;;

2*)
NAMECHECK=`zenity --entry --title "Check" --text "Type file's name: "`
CHECKNAME=$(find -name "$NAMECHECK")
if [ -z "$CHECKNAME" ]; then
	zenity --error --text "No mp3 files named like you typed!"
else
	while [ "${CHECKNAME: -1}" != "/" ]; do
	CHECKNAME=$(echo $CHECKNAME | rev | cut -c2- | rev )
	done
	CHECKNAME=$(echo $CHECKNAME | rev | cut -c2- | rev )
	cd "$CHECKNAME"
	eyeD3 "$NAMECHECK" | zenity --text-info –height 200 –title "Songs id3 tags"
fi
cd ~
CHOICE=0 ;;

3*)
PATHORG=`zenity --entry --title "Organization" --text "Type folder's path: "`
PATHORG="$HOME/${PATHORG}"
cd $PATHORG
for i in *; do
	ARTISTORG=$(echo $i | cut -d - -f 1)
	TITLEORG=$(echo $i | cut -d - -f 2)
	ALBUMORG=$(echo $i | cut -d - -f 3)
	TRACKORG=$(echo $i | cut -d - -f 4)
	if [ ! -d "$ARTISTORG" ]; then
		mkdir "$ARTISTORG"
	fi
	cd "$ARTISTORG"
	if [ ! -d "$ALBUMORG" ]; then
		mkdir "$ALBUMORG"
	fi
	cd "$ALBUMORG"
	cd ..
	cd ..
	mv "$i" "$PATHORG/$ARTISTORG/$ALBUMORG"
	cd "$PATHORG/$ARTISTORG/$ALBUMORG"
	mv "$i" "$TITLEORG-$TRACKORG"
	cd $PATHORG
done
cd ~
zenity --info --title "Success" --text "Files successfully organized!"
CHOICE=0 ;;

4*) 
PATHAUT=`zenity --entry --title "Automatic" --text "Type folder's path: "`
PATHAUT="$HOME/${PATHAUT}"
cd "$PATHAUT"
for i in *; do
	ARTISTAUT=$i
	cd "$PATHAUT/$i"
	for j in *; do
		ALBUMAUT=$j
		cd "$PATHAUT/$i/$j"
		for p in *; do
			TITLEAUT=$(echo $p | cut -d - -f 1)
			TRACKAUT=$(echo $p | cut -d - -f 2)
			TRACKAUT=$(echo $TRACKAUT | cut -d \. -f 1)
			echo $ARTISTAUT
			echo $ALBUMAUT
			echo $TITLEAUT
			echo $TRACKAUT
			eyeD3 -a "$ARTISTAUT" -A "$ALBUMAUT" -t "$TITLEAUT" -n "$TRACKAUT" "$p"
		done
	done
done
zenity --info --title "Success" --text "Id tags successfully set!"
CHOICE=0 ;;

5*)
sudo apt install eyed3
zenity --info --title "Instalation" --text "EyeD3 successfully installed!"
CHOICE=0 ;;

6*)
zenity --info --title "Exit" --text "Goodbye!"
CHOICE=6 ;;
esac
done