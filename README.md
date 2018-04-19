# eegtool
EEG analysis tool for Matlab. eegtool is a program that facilitates certain
types of EEG analyses. The program uses eeglab as a base and in many cases the
features of eegtool are wrapping eeglab functions.

eegtool consists of two main parts:
* eegtoolPreprocess - preprocessing EEG on a visually pleasing GUI or through 
scripting API.
* eegtoolAnalysis - perform different analyses on preprocessed EEG.

Transferring project codes to github in progress. Some features may be missing
or not work like expected yet. The latest major updates to eegtool are few
years ago.

## Usage
* Download eeglab and add eeglab to Matlab-path
* Download the files to your Matlab-path, preserve the filestructure in the package
* run by typing the following in Matlab command-line:
```
eegtoolPreprocess
```

## Accepted data types
Currently Eegtool can read EEG data from EGI and Neuroscan systems. 
eegtoolAnalysis reads also EEGLAB’s set files. All video types readable	by
Matlabs VideoReader-function are usable in eegtool.

## Importing data
### NetStation (Electrical Geodesics, Inc.)
1. Bring raw Data file to NetStation’s Segmentation Marker Tool.
Mark the stimuli by using the tool according to the needs of your study.

2. Bring the file with marked segments to
file-export tool. Output options:
Name: Append ".raw"
Destination: "Same as Source"
File Export Settings:
Format: NetStation Simple Binary (Epoch Marked)
Precision: Floating Point
Export These Auxiliary    Files:
Calibration Information
History information
Calibrate Data
Export Reference Channel

### Neuroscan
Save the information in continuous .cnt-format and include the stimulus
information in the file.

### EEGLAB
Continuous EEG data with event information can be imported to eegtoolPreprocess
tool as .set-files.
Segmented files can be imported to eegtoolAnalysis as .set files. Preferably
use the event name from your experiment as the value of the EEG.setname field
in the EEGLAB’s data structure as some analyses included in eegtoolAnalysis
allow structuring your data based on the content of EEG.setname.