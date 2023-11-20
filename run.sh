#!/usr/bin/env bash



projectsAbsolutePath=~/projects
selected=`ls $projectsAbsolutePath | fzf`

absPath=$projectsAbsolutePath/$selected

cd $absPath
