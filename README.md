# Synchronization
Synchronization Software for Miniscope and Behavioral Camera

%Matlab Codes to Synchronyze the Data
Download and extract the file Miniscope_20220804_JOVE.zip

https://olucdenver-my.sharepoint.com/:u:/g/personal/fabio_simoesdesouza_cuanschutz_edu/EaVgndfgcLFOvP00Hk1R18EBhulFjhhW8ADyeLVSem-Bww?e=dGtcHV

1) Convert the odor arena flir mp4 file to AVI. You need ffmpeg instaled in your computer.

ffmpeg -i 20210525_unitR02_session003_topCam-0000.mp4 -f avi -vcodec mjpeg 20210525_unitR02_session003_topCam-0000.avi

2) Input the paths and File Names of the odor arena metadata, miniscope files, and Intan files into a Choices File (ChoicesFiles_JOVE.m).

3) Syncronyze the frames of the FLIR camera (odor arena) with the miniscope frames.

This processing steps takes several minutes!

The miniscope and Flir camera data are synchronized by the intan file (with matlab code).
The file chooses thenearest neighbor FLIR frames within 100ms to match the miniscope frames.
Brain and behavior are synchronized with the same number of frames.

Synchronyze_Files_JOVE.m

This script reads Convert_Arena_Metadata_JOVE.m and ChoicesFiles_JOVE.m
The file Convert_Arena_Metadata_JOVE.m converts the odor arena metadata into a matlab format. Then, it syncronizes the Miniscope and FLIR files.

4) Perform motion correction in the miniscope synchronized file with NormCorr

5) Extract the ROIs from the NormCorr file with EXTRACT

6) Run drgDecodeOdorArenav2.m on the EXTRACT file and OdorArena Metadata to analyze the data.
