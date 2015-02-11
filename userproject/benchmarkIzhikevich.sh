#!/bin/bash
set -e #exit if error or segfault. Turn it off for benchmarking -- big networks are expected to fail on the GPU
# bash benchmarkIzhikevich.sh bmtest 4 1000 "what is new" 2>&1 |tee bmout_izhikevich #fails at ntimes=6 (hits global mem limit) 
BMPATH=$GENN_PATH/userproject/benchmark
CONNPATH=$(pwd);
echo "model path:" $CONNPATH
OUTNAME=$1;
echo "output name:" $OUTNAME
cd Izh_sparse_project;


#if [ -d "$BmDir" ]; then
#  echo "benchmarking directory exists. Using input data from" $BmDir 
#  printf "\n"
#else
#  mkdir -p $BmDir
#  echo "Benchmarking directory does not exist. Creating a new one at" $BmDir " and running the test only once (first run for reference)."
#  printf "\n"
#  firstrun=true;
#fi

ntimes=$2
nNeuronsFirst=$3
custommsg=$4

echo "running " ${ntimes} " times starting from " ${nNeuronsFirst}

((nTotal=${nNeuronsFirst}/2))

for ((ttest = 1; ttest <= ${ntimes}; ttest++));  
do
  ((nTotal=2*${nTotal}))
  echo "nTotal is " ${nTotal}
  printf "\n\n***********************Izhikevich GPU generating code ****************************\n"
  
  if [ -d ${OUTNAME}_output ]; then
    echo ${custommsg} >> ${OUTNAME}_output/${OUTNAME}.time
  else  
    printf "Running for the first time"
  fi
  
  if [ -d "$BMPATH/Izhikevich_results/${OUTNAME}_output/inputfiles_${nTotal}" ]; then 
    echo "Dir exists. Copying files and running with the reference input..."
    cp -R $BMPATH/Izhikevich_results/${OUTNAME}_output/inputfiles_${nTotal}/* inputfiles/
    ./generate_run 1 ${nTotal} 1000 1 ${OUTNAME} Izh_sparse 0 FLOAT 1
  else
    echo "Running with new input files."
    ./generate_run 1 ${nTotal} 1000 1 ${OUTNAME} Izh_sparse 0 FLOAT 0
  fi
  
  #printf "\n #\n # copying \n #\n #\n"
  #cp ${OUTNAME}_output/${OUTNAME}.kcdn* ../MBody_userdef_project/${OUTNAME}_output/ -R
  #cp ${OUTNAME}_output/${OUTNAME}.pnkc* ../MBody_userdef_project/${OUTNAME}_output/ -R
  #cp ${OUTNAME}_output/${OUTNAME}.pnlhi* ../MBody_userdef_project/${OUTNAME}_output/ -R
  #cp ${OUTNAME}_output/${OUTNAME}.inpat* ../MBody_userdef_project/${OUTNAME}_output/ -R
  
  #do the following only once
  if [ -d "$BMPATH/Izhikevich_results/${OUTNAME}_output/inputfiles_${nTotal}" ]; then 
    echo "Dir exists. not copying."
  else
    echo "making directory and copying input files..."
    mkdir -p $BMPATH/Izhikevich_results/${OUTNAME}_output/inputfiles_${nTotal}
    cp -R inputfiles/* $BMPATH/Izhikevich_results/${OUTNAME}_output/inputfiles_${nTotal}/
    #cp ${OUTNAME}_output/${OUTNAME}.pnkc* ~/benchmark/Izhikevich_results/${OUTNAME}_output/${nTotal}/ -R
    #cp ${OUTNAME}_output/${OUTNAME}.pnlhi* ~/benchmark/Izhikevich_results/${OUTNAME}_output/${nTotal}/ -R
    #cp ${OUTNAME}_output/${OUTNAME}.inpat* ~/benchmark/Izhikevich_results/${OUTNAME}_output/${nTotal}/ -R
  fi


  for dumbcntr in {1..2}
    do
      printf "\n\n***********************Izhikevich GPU "${dumbcntr}" nTotal = ${nTotal} ****************************\n"
      printf "With ref setup... \n"  >> ${OUTNAME}_output/${OUTNAME}.time
      model/Izh_sim_sparse ${OUTNAME} 1
      printf "\n\n***********************Izhikevich CPU "${dumbcntr}" nTotal = ${nTotal} ****************************\n"
      model/Izh_sim_sparse ${OUTNAME} 0	
    
 
  done
  echo "ntimes is" ${ntimes} 
done
  cd ..

  #cp Izh_sparse_project ~/benchmark/Izhikevich_results -R
  tail -n 15 Izh_sparse_project/${OUTNAME}_output/${OUTNAME}.time
 
  echo "Benchmarking complete!"

