Version 8d, master.  January 2019.  This is the latest stable release of HAS.
======
Version 8e, master.  July 2019.
 - in this version, Doug has added phase aberation correction functionality
 - he also made it mandatory for the dimensions of the input model to be an odd number
 - added a function to (pad?) models that are not odd (makeModelOdd.m)
====== 
PAC_iss14-15 branch. July 2019.
This branch of the code was created by Sam Adams, UCAIR.  The purpose was to update v. 8e to correct PhCorrMethod1 indexing.
"Updated files to include Dr. Christensen's latest additions and improvements (manual merge with e8e9494)
Updated indexing into ROI in both CalcHAS and PhCorrMethod1. In PhCorrMethod1clean I corrected an error that would cause it to simply store the ROI dimensions in x and y rather than the coordinates in x and y, causing out of bounds issues. CalcHAS updated to round focus and ROI to a voxel for the case when the geometric focus is offset by a value not a multiple of the voxel spacing."

Doug subsequently incorporated the changes from this branch into his main version of the code (see version 8e2 below) 
Therefore, this branch was deleted instead of merged with master.
======
Version 8e1, master. July 2019.
This version contains some bug fixes by Doug to v. 8e.
======
Version 8e2, master. July 2019.
In this version, Doug has incorporated Sam Adams' changes from the PAC_iss14-15 branch.  