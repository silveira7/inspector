**Support free software, support open science.**

---

# INSPECTOR
> [!NOTE] 
> This script builds upon the [ProPer Toolkit](https://github.com/finkelbert/ProPer_Projekt) by Aviad Albert, which itself is based on the [Mausmooth Praat script](https://ifl.phil-fak.uni-koeln.de/sites/linguistik/Phonetik/mitarbeiterdateien/fcangemi/mausmooth.praat) by Francesco Cangemi.

> [!IMPORTANT]
> The current version supports only the *filtered autocorrelation* method for pitch detection.

## Overview

**INSPECTOR** is a Praat script designed to facilitate the manual inspection, correction, and validation of acoustic data prior to analysis. It is
particularly useful when working with multiple pairs of audio (`.wav`) and corresponding TextGrid files (`.TextGrid`).


The script automates the following tasks for each audio/TextGrid pair:

1. **Automatic loading** of the audio and corresponding TextGrid into Praat.  
2. **Computation** of derived objects: `Pitch`, `Intensity`, `PitchTier`, and/or `IntensityTier`.  
3. **Interactive inspection** of the data:
   - Opens the Sound and TextGrid in the *SoundEditor*.
   - Opens each derived object in its respective editor.
   - Prompts the user to review and, if necessary, edit each object.
4. **Export** of the validated objects to a user-defined output directory.  
5. **Iteration** through all pairs in the input directory.
   

### Input:
- A directory containing one or more pairs of audio files (`.wav`) and their corresponding
TextGrids files (`.TextGrid`).

### Output: 
- For each file pair, the script exports, after user inspection, Praat objects (`Pitch`, `PitchTier`, `Intensity`, and/or `IntensityTier`) to the specified output directory.


## Parameters

Before execution, the user must define the following parameters:

- **Input directory**: Location of the `.wav` and `.TextGrid` file pairs.
- **Time step**: Determines the temporal resolution of the `Pitch`, `PitchTier`, `Intensity`, and `IntensityTier` objects.
  - Default: `0.01` seconds (i.e., 10 ms between measurements).
- **Objects to process**: Selection of which derived objects should be computed, inspected, and exported.
- **Saving method to process**: Save the output files in (i) the input directory; (ii) in a single different directory; or (iii) in different directories, one for each object type.

## State saving

Because inspecting all files in one go is often impossible, the script tracks progress automatically. If interrupted, it saves the current position, allowing the next run on the same directory to resume where it left off.
    
