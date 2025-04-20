# This is script is a free software, distributed under the license 
# GNU General Public License, Version 3 (GPLv3)
#
# Support free software, support open science.
#
# --------------------------------------------------------------------
# INSPECTOR
# --------------------------------------------------------------------
#
# Version: 1.0 (2025-04-20)
# Author: Gustavo Silveira
# If you encounter any bugs or issues, please report them via email to:
# silveira@tuta.io
#
# Note: this script is based on the Praat script used by the *ProPer*
# toolkit, by Albert Aviad, which is based on the *Mausmooth* Praat script
# by Francesco Cangemi.
#
# ProPer toolkit: https://github.com/finkelbert/ProPer_Projekt
# Mausmooth: https://ifl.phil-fak.uni-koeln.de/sites/linguistik/Phonetik/mitarbeiterdateien/fcangemi/mausmooth.praat
#
# DESCRIPTION:
# 
# This Praat script is designed to streamline the manual inspection,
# correction, and validation of acoustic data prior to analysis. It is
# particularly useful when working with multiple pairs of audio (.wav)
# and corresponding TextGrid files.
# 
# In a sequence, for each pair, the script performs the following operations:
#     1) Automatically loads the audio and TextGrid files into Praat.
#     2) Obtain derived object: Pitch, Intensity, PitchTier, and/or IntensityTier.
#     3) Opens the audio and TextGrid in the SoundEditor and each object in its 
#        respective editor, prompting the user to inspect and, if necessary,
#        correcting the measurements.
#     4) Upon user confirmation, exports the inspected objects to the specified 
#        output directory.
#     5) Repeats the process for the next file pair.
# 
# INPUT:
# A directory containing one or more pairs of audio files and their corresponding
# TextGrids.
# 
# OUTPUT: 
# For each audio/TextGrid pair, the script saves the following Praat
# objects to a user-defined output directory: Pitch, Intensity, PitchTier,
# and IntensityTier.
# 
# PARAMETERS:
# Besides the input and output directories, the user must specify
# which objects to be exported and inspected. The TIME STEP parameter
# sets how many measurements of F0 (for the Pitch and PitchTier objects)
# and intensity (for the Intensity and IntensityTier objects) are made per
# second. The default value of 0.01 means that Praat will compute one measurement
# every 10 milliseconds (0.010 seconds = 10 ms).
#
# IMPORTANT: The current version of this script supports only the filtered autocorrelation
# method of pitch detection.

form: "Inspector"
    folder: "Input directory", ""
    folder: "Output directory", ""

    real: "Time step (s)", "0.01"
    
    comment: "What do you want to export?"

    boolean: "Export TextGrid", "1"
    boolean: "Export Pitch", "1"
    boolean: "Export PitchTier", "1"
    boolean: "Export Intensity", "0"
    boolean: "Export IntensityTier", "1"

    comment: "What do you want to inspect?"

    boolean: "Inspect SoundEditor", "1"
    boolean: "Inspect TextGrid", "1"
    boolean: "Inspect Pitch", "1"
    boolean: "Inspect PitchTier", "0"
    boolean: "Inspect IntensityTier", "0"
endform

if export_Pitch or export_PitchTier or inspect_Pitch or inspect_PitchTier
    beginPause: "Filtered autocorrelation settings"
        comment: "Where to search..."
        real: "Pitch floor (Hz)", "50.0"
        real: "Pitch top (Hz)", "800.0"
        comment: "How to find candidates..."
        integer: "Max number of candidates", "15"
        boolean: "Very accurate", "no"
        comment: "How to preprocess the sound..."
        real: "Attenuation at top", "0.03"
        comment: "How to find a path through the candidates..."
        real: "Silence threshold", "0.09"
        real: "Voicing threshold", "0.50"
        real: "Octave cost", "0.055"
        real: "Octave jump cost", "0.35"
        real: "Voiced unvoiced cost", "0.14"
    clicked = endPause: "OK", "Interrupt", 1, 2
    pitch_floor_1 = pitch_floor
endif

if export_Intensity or export_IntensityTier or inspect_IntensityTier
    beginPause: "To Intensity settings"
        real: "Pitch floor (Hz)", "100.0"
        boolean: "Subtract mean", "yes"
    clicked = endPause: "OK", "Interrupt", 1, 2
    pitch_floor_2 = pitch_floor
endif

if not endsWith (input_directory$, "/")
    input_directory$ = input_directory$ + "/"
endif

if not endsWith (output_directory$, "/")
    output_directory$ = output_directory$ + "/"
endif

createFolder: output_directory$

fileList = Create Strings as file list: "fileList", input_directory$ + "*.TextGrid"
num_of_files = Get number of strings

if num_of_files = 0
    exitScript: "No TextGrid file found in the input directory."
endif

for i from 1 to num_of_files
    selectObject: fileList
    current_file$ = Get string: i
    current_file$ = current_file$ - ".TextGrid"

    tg = Read from file: input_directory$ + current_file$ + ".TextGrid"
    audio = Read from file: input_directory$ + current_file$ + ".wav"

    if export_Pitch or inspect_Pitch
        pitch = To Pitch (filtered autocorrelation): time_step, pitch_floor_1, pitch_top, max_number_of_candidates, very_accurate, attenuation_at_top, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voiced_unvoiced_cost
    endif

    if export_Intensity or export_IntensityTier or inspect_IntensityTier
        selectObject: audio
        intensity = To Intensity: pitch_floor_2, time_step, subtract_mean
        if export_Intensity
            Save as short text file: output_directory$ + current_file$ + ".Intensity"
        endif
        if export_IntensityTier or inspect_IntensityTier
            intensity_tier = Down to IntensityTier
        endif
    endif

    selectObject: audio

    if inspect_SoundEditor == 1 and inspect_TextGrid == 0
        selectObject: audio
        View & Edit
    elsif inspect_SoundEditor == 1 and inspect_TextGrid == 1
        selectObject: audio, tg
        View & Edit
    endif
    
    if inspect_Pitch
       selectObject: pitch
       View & Edit
    endif

    if inspect_IntensityTier
       selectObject: intensity_tier
       View & Edit
    endif

    beginPause: ""
        comment: "Click on Next to proceed."
    clicked = endPause: "Next", "Interrupt", 1, 2

    if clicked == 2
       num_of_files = i
    endif

    if inspect_Pitch
        editor: pitch
            Close
        endeditor
    endif

    if inspect_IntensityTier
        editor: intensity_tier
            Close
        endeditor
    endif

    if inspect_PitchTier or export_PitchTier
        selectObject: pitch
        pitch_tier = Down to PitchTier
        if inspect_PitchTier
            View & Edit
            beginPause: ""
                comment: "Click on Next to proceed."
            clicked = endPause: "Next", "Interrupt", 1, 2
            editor: pitch_tier
                Close
            endeditor
        endif
    endif

   if inspect_SoundEditor == 1 and inspect_TextGrid == 0
        editor: audio
            Close
        endeditor
    elsif inspect_SoundEditor == 1 and inspect_TextGrid == 1
        editor: tg
            Close
        endeditor
    endif

    if export_TextGrid
        selectObject: tg
        Save as short text file: output_directory$ + current_file$ + ".TextGrid"
    endif

    if export_Pitch
        selectObject: pitch
        Save as short text file: output_directory$ + current_file$ + ".Pitch"
    endif

    if export_PitchTier
        selectObject: pitch_tier
        Save as short text file: output_directory$ + current_file$ + ".PitchTier"
    endif

    if export_IntensityTier
        selectObject: intensity_tier
        Save as short text file: output_directory$ + current_file$ + ".IntensityTier"
    endif

endfor

select all
Remove

if clicked == 2
   writeInfoLine: "Script interrupted."
else
   writeInfoLine: "Script done."    
endif
