#!/bin/bash
# BASH Script to identify higher elevation stations from StationData, highlight locations, and convert to TIFF format
# kushpaliwal  04/04/2020

module load gmt

Datadirectory=StationData
Newdirectory=HigherElevation

# Check if the directory: HigherElevation exists?
if [ ! -d ./$Newdirectory  ]
then
    mkdir $Newdirectory
fi

# identify the file with elevation equal to or greater than 200 feet

for file in $Datadirectory/*
do
  filepath=$(awk '/Altitude/ && $NF >=  200 {print FILENAME}' $file)

# copy file to HigherElevation if filepath is not null
  if [ -n "$filepath" ]
  then
     cp  $filepath $Newdirectory
  fi

done

# Extract Latitude and Longitude from files in StationData

awk '/Longitude/ {print -1 * $NF}' $Datadirectory/Station_*.txt > Long.list
awk '/Latitude/ {print  $NF}' $Datadirectory/Station_*.txt > Lat.list

# Create new file for Latitude and Longitude

paste Long.list Lat.list > AllStations.xy

# Obtain Latitude and Longitude from files in HigherElevation

awk '/Longitude/ {print -1 * $NF}' $Newdirectory/Station_*.txt > HELong.list
awk '/Latitude/ {print  $NF}' $Newdirectory/Station_*.txt > HELat.list

# Create new file for Latitude and Longitude

paste HELong.list HELat.list > HEStations.xy

# Draw blue lakes, blue rivers, and orange boundaries

gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Dh -Ia/blue -Na/orange -P -Sblue -K -V > SoilMoistureStations.ps

# Small black circles for all station locations

gmt psxy AllStations.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps

# Smaller red circles for all higher elevation stations

gmt psxy HEStations.xy -J -R -Sc0.08 -Gred -O -V >> SoilMoistureStations.ps

# convert PS file into EPSI file

ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi

# convert EPSI file into TIF file with 150 dpi

convert -density 150 SoilMoistureStations.epsi SoilMoistureStations.tif

echo "Task Completed"
