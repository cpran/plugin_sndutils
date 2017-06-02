# Normalise all sounds in a given directory using RMS normallisation
#
# Written by Jose J. Atria (29 May 2014)
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.
#
# TODO: set sounds to specified RMS

include ../../plugin_utils/procedures/utils.proc
include ../../plugin_utils/procedures/check_directory.proc
include ../../plugin_selection/procedures/selection.proc

form RMS normalisation...
  sentence Read_from
  sentence Save_to
  comment Normalised sounds will be saved in specified directory. Leave empty for GUI selector
  word Sound_extension wav
  positive Target_intensity_(dB) 70
  boolean Keep_conversion_table no
endform

@checkDirectory(read_from$, "Read sounds from...")
read_from$ = checkDirectory.name$

@checkDirectory(save_to$, "Save sounds to...")
save_to$ = checkDirectory.name$

@mktemp: "rms_XXXXXX"
temp$ = mktemp.return$

runScript: preferencesDirectory$ + "/plugin_strutils/scripts/" +
  ... "file_list_full_path.praat", "files", read_from$, "*" + sound_extension$, 0
files = selected("Strings")

batch = 1
strings = numberOfSelected("Strings")
tables = 0
sounds = 0

include _rms_normalise.praat

deleteFile: temp$
removeObject: files
