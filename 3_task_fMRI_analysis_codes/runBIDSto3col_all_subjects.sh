#!/bin/bash
#
# Script: BIDSto3col.sh
# Purpose: Run BIDSto3col.sh script on all the participants to convert BIDS event TSV
# files to 3 column FSL files.
# Made by: Rani
# January 2020
# 
# One input argument: modelName.
#
# Change the paths as necessary (note that the separators are for mac/linux)
# If the study does not include sessions change the areSessions to 0.
#

# Parameters:
# ----------------------------------------------------------------------------------------
BIDSto3colPath="/export2/DATA/HIS/HIS_server/codes/"
participantsListFile="/export2/DATA/HIS/HIS_server/BIDS/participants.tsv"
BIDSpath="/export2/DATA/HIS/HIS_server/BIDS/"
OutputPath="/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/" # The relevant derivative folder
modelsPath="models" #The mother folder of models inside each subject and session
onsetsPath="onsets"
areSessions=1
modelNamePrefix="model"
modelName=$modelNamePrefix$1
# ----------------------------------------------------------------------------------------

# Check that exactly one argument was entered:
if [ $# -lt 1 ]; then
  echo 1>&2 "$0: not enough arguments"
  exit 2
elif [ $# -gt 1 ]; then
  echo 1>&2 "$0: too many arguments"
  exit 2
fi

# create subject list
listOfSubjects=()
re='^[0-9]+$' # regex to test if a number
for i in `cat ${participantsListFile}`; do
    if [[ ${i: -3} =~ $re ]] ; then
        listOfSubjects+=($i)
    fi
done 

if [[ $areSessions == 1 ]]; then # a flag for whether the experiment includes sessions.
    for subject in ${listOfSubjects[@]}; do	
        for session in `ls ${BIDSpath}${subject}`; do # iterate over sessions
            mkdir -p ${OutputPath}${subject}/${session}/${modelsPath}/${modelName}/${onsetsPath} # make directory if is not exist.
            for eventsFile in `ls ${BIDSpath}${subject}/${session}/func/*.tsv`; do
            	threeColumnFile=${eventsFile##*/}
            	threeColumnFile=${threeColumnFile%_events.tsv}
                ${BIDSto3colPath}./BIDSto3col.sh ${eventsFile} ${OutputPath}${subject}/${session}/${modelsPath}/${modelName}/${onsetsPath}/$threeColumnFile
            done			
        done
    done
else
    for subject in ${listOfSubjects[@]}; do	
        mkdir -p ${OutputPath}${subject}/${modelsPath}/${modelName}/${onsetsPath} # make directory if is not exist.
        for eventsFile in `ls ${BIDSpath}${subject}/func/*.tsv`; do
        	threeColumnFile=${eventsFile##*/}
        	threeColumnFile=${threeColumnFile%_events.tsv}
            ${BIDSto3colPath}./BIDSto3col.sh ${eventsFile} ${OutputPath}${subject}/${modelsPath}/${modelName}/${onsetsPath}/$threeColumnFile
        done			
    done
fi
