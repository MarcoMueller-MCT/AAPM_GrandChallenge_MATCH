# AAPM_GrandChallenge_MATCH
This repository was created to update and share the analysis software that has been used in the AAPM Markerless Lung target tracking Challenge 2019/2020


function []=AnalyzeMATCH()

This script is used to quickly analyze participant submissions for MATCH
by displaying the ground truth HexaMotion trace with the Markerless tracking trace.

Optimization of the sampling rate has been included after it was found that the HexaMotion 
platform drives different motion traces with different speeds. The user has to enter an initial 
sampling rate and the optimizer tries to find a better fit withing +- 5% of that sampling rate 
by maximizing the correlation of the resampled measured motion with the ground truth motion trace. 

Instructions:
1. Save the tracked target location as distance from isocenter in mm
as a 3 coloumn numeric matrix [LR|SI|AP] with double precision in a .mat-file.
2. Run this script and enter the details of the data.
3. When Figure pops up, visually check the alignment of the ground truth with the
tracked target location trace. Use the "Pan"-tool (Hand-symbol) on the upper plot
to manually align the ground truth. Do not use the zoom function, as this
will change the start and end points of the selected trace section.

