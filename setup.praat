# Setup script for sndutils
#
# Find the latest version of this plugin at
# https://gitlab.com/cpran/plugin_sndutils
#
# Written by José Joaquín Atria
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

## Static commands:

# Base menu
nocheck Add menu command: "Objects", "Praat", "sndutils", "CPrAN", 1, ""

nocheck Add menu command: "Objects", "Praat", "Batch RMS normalisation...", "sndutils", 2, "scripts/batch_rms_normalise.praat"

# Sound commands
Add action command: "Sound", 0, "", 0, "", 0, "Filter and center...", "Filter -", 1, "scripts/filter_and_center.praat"
Add action command: "Sound", 0, "", 0, "", 0, "Normalise (RMS)...",   "Modify -", 1, "scripts/rms_normalise.praat"
