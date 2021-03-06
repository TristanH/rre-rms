#!/bin/bash
# Rider Rider Evolution build script
# Github: https://github.com/ddol/rre-rms
# 
# Usage:
# ./build.sh              : Builds rider.txt, the current version of the rider
# ./build.sh 20050601     : Builds the rider as it was on Jun 1, 2005
# ./build.sh 20030502.txt : Inserts a new version of the rider into the history

old_man=20530316 #  I'm assuming RMS won't release riders after he is 100

init_diffs () {

  cd diffs
  diff_array=(`ls *`)
  cd ../
  max_index=$(( ${#diff_array[@]} -1 ))  #  Wild Voodoo Majik, takes number of 
                                            #+ array elements and subtracts one
}

build () {
  #  Optional argument
  #  1) Date(yyyymmdd): Will build the rider that existed on this date. If 
  #+    missing, will build the current rider. Filename is also based on this.
  
  init_diffs

  if [ -z "$1" ]
  then
    break_date=$old_man 
    base_file="rider.txt"
  else
    break_date=$1
    base_file=$1".txt"
  fi
  
  >| $base_file # Touch or overwrite if exists to null 

  for patch in ${diff_array[*]}
  do
    if [ $patch -gt $break_date ]
    then
      break
    fi
    
    patch -s $base_file diffs/$patch
  done
}

if [ -n "$1" ]
then
  if [ ${1:(-4)} = ".txt" ]
  then
    cp $1 fulltext/
    date="${1%.txt}" #  Serious funk, strips '.txt' from the end of $1 (arg 1)
    build # We need to have a finished rider.txt to diff against if newest
      
    if [ $date -gt ${diff_array[$max_index]} ]
    # Find out if the new file is appended or inserted

    then
      echo "Your addition is the latest we have, thanks!"  
      diff rider.txt $1 > diffs/$date

    else
      echo "Super, we can enhance the past's resolution!"
      i=0

      # Now to find out where this new file fits in
      for diff_date in ${diff_array[*]}
      do
        if [ $diff_date -gt $date ]
        then
          date_after_index=$i # Index of rider closest to new file
          break
        else
          i=$((i+1))
        fi
      done
   
      # We have the position it fits in, time to make the new diffs
      date_before=${diff_array[$((date_after_index -1))]}
      date_after=${diff_array[$date_after_index]} 

      #  Build two full riders, either side of the new one.
      build $date_before 
      build $date_after 
      diff $date_before".txt" $date".txt" > diffs/$date
      diff $date".txt" $date_after".txt" > diffs/$date_after #  Here we update
                                                             #+ the old diff
      rm $date_before".txt" $date_after".txt"
    fi
  else
    build $1
  fi
fi

build

# Copyright (c) 2012, David Dolphin
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied, of the FreeBSD Project.
