#!/bin/bash

# This script is used to reset the numbering from Canon family cameras
# which restart numbering on new storage card insert or reformat.  It
# re-establishes the incremental numbering and by putting the last
# image back on camera card, will re-establish sequential number to
# avoid collisions and maintain sort by name and other coherencies.


OFFSET=3000

#for FOO in *.JPG ; do
for FOO in MVI_00*.MP4 ; do
#for FOO in *.MP4 ; do
    echo "Processing $FOO"
    BASE=${FOO:4:4}
    echo -n "$FOO : "
    echo "$BASE"
    #    if (( "${BASE#0}"  >= "1" )) && (( "${BASE#0}" <= "64" ))
    if [ "${BASE}"  -ge "1" ] && [ "${BASE}" -le "64" ]
    then
	NEWBASE=$(( 10#${BASE} + 10#$OFFSET ))
	NEWBASESTR=`printf %s_%04d.%s ${FOO%_*} ${NEWBASE} ${FOO##*.}`
	echo "renaming $FOO ${NEWBASESTR}"
	mv -i "$FOO" "${NEWBASESTR}"
    fi
done


       
