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

form RMS normalisation (old)...
  positive Target_intensity_(dB) 70
  boolean  Keep_conversion_table no
  boolean  Make_changes_inline no
  boolean  Verbose no
endform

appendInfoLine: "# This script is deprecated. Use rms_normalise.praat instead"

runScript: "rms_normalise.praat", target_intensity,
  ... keep_conversion_table, make_changes_inline
