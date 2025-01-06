## What files are present here? 
binner_1_metabat2.sh --> binner script to just run metabat2 (have to run this before metabat2)
binner_2_maxbin2.sh --> binner script to just run maxbin2 (have to run metabat2 before this)
binner_3_concoct.sh --> binner script to just run concoct (will run on its own without the others) 
binner_combined.sh --> binner scripts 1,2,3 combined together in 1 script. This will run on its own. 

## Why are there different options? 
It may feel irritating in the combined one to have to wait for one binner program to finish to move on to the next one. If you'd rather be able to run multiple binners at the same time, then you can use 1,2,3 options in order to run multiple. However, you still have to run metabat2 before maxbin (only because you need the jgi summarize depth file, so once this is done you can move forward with running maxbin2). 
Happy Binning! 
