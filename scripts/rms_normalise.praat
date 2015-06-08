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
include ../../plugin_selection/procedures/selection.proc

form RMS normalisation...
  positive Target_intensity_(dB) 70
  boolean  Keep_conversion_table no
  boolean  Make_changes_inline no
endform

batch = 0
inline = make_changes_inline
sounds = numberOfSelected("Sound")
tables = numberOfSelected("Table")
strings = 0
if !sounds and !tables
  exitScript: "Running in standard mode without suitable objects"
endif

include _rms_normalise.praat
