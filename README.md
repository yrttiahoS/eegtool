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
* Download the files to your Matlab-path, preserve the filestructure in the
package
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

## Interface for Interactive preprocessing

EEG signal from each electrode is displayed on a 2D "head-model" where
electrodes are placed according to the X and Y coordinates derived from a
channel location file. The interface works in two phases: continuous and
epoched. 

The continuous mode is mainly designed for overall visual inspection and
filtering. The timeline is continuous through the entire signal and the
observation point can be moved with the slider. An entire video file can be
loaded and viewed in the continuous mode. Note that in this mode the video is
not time-locked to EEG.

The epoched mode is designed for performing various pre-processing tasks.
In this mode, a signal from one epoch at a time is displayed for all
electrodes. The slider allows the user to move between epochs of the same
stimulus type and the list-box on the upper right corner to change between
different stimulus types. In the epoched mode, the video is partitioned into
segments corresponding to the EEG epoch (please, see chapter Video-EEG
integration for more details on video segmentation).
Saving files is only possible in the epoched mode. Preprocessing functions
are available under the “Preprocessing” menu on the upper left corner.

## Video-based artifact detection

Preprocessing interface enables integration of video and EEG in the epoched
mode. This feature requires both video and EEG to be sampled at a constant
sampling rate. The first event in the video trace must also be identifiable by
observing the video (eg. by light flash or by using a mirror) or known prior to
EEG integration. Multiple videos can be loaded to the program and integrated
with EEG as long as the preceding criteria are met by all the videos.

To integrate video with EEG, the user must first load both the EEG-file
and the video file(s) to the interface (eegtoolPreprocess). After that,
the user must find the frame on which the first event occurs in each video
and mark those frames with button “I” or by pressing “i” on the keyboard.
Consequently, the text “1st stimulus marker” is presented in the top-right
corner of the selected frame. Finally, the user must epoch the EEG (Epoching
the EEG will automatically epoch the uploaded videos too). Note that the
stimulus which occurred during the first stimulus frame must be included in the
stimulus set. A questionnaire appears displaying all the stimulus in selected
EEG conditions. The user must select the epoch that appears first in the video.
This stage gives the user flexibility to epoch the video even if the video was
started later than the first events. In the epoched mode, the video window
automatically displays the corresponding video frames when switching between
epochs/events in the eegtoolPreprocess main window.

After the removal of bad epochs on the basis of the video records (an epoch
can be removed by using the “Remove epoch” button in the eegtoolPreprocess
window), the user can print an output screen indicating the indices of bad
epochs from each event type. The list can be printed out by choosing
“Statistics->Display removed epochs”. By choosing “Copy summary to clipboard”,
the program automatically generates, to the clipboard, a function call for
removing epochs in the scripting mode (see below for further information about
subsequent data processing by using the graphical user interface or a
scripting mode).