#!/usr/bin/env bash



projectsAbsolutePath=~/projects
selected=`ls $projectsAbsolutePath | fzf`

absPath=$projectsAbsolutePath/$selected
printf "Selected: $absPath\n"


cd $absPath

