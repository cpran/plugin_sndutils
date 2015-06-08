
pass = 1
selection$ = preferencesDirectory$ - "con" + "/plugin_selection/scripts/"

strings = numberOfSelected("Strings")

# If a list of files is selected, then we are in batch mode.
# Temporary copies of the sound files are saved to disk before
# checking for clippings, so we need a temporary directory
# If this is the case, inline is disabled
if batch and !strings
  exitScript: "Running in batch mode without file list"
elsif strings
  inline = 0
  @mktemp: "rms_XXXXXX"
  temp$ = mktemp.return$
else
  inline = make_changes_inline
endif

# tables = numberOfSelected("Table")
# sounds = numberOfSelected("Sound")

runScript: selection$ + "save_selection.praat"
selection = selected("Table")

conversions = Create Table with column names: "conversions", 0,
  ..."filename rms_pre max_pre rms_post max_post"

selectObject: selection

if tables
  runScript: selection$ + "restore_selection.praat"
endif

@for_each()

removeObject: selection
if !keep_conversion_table
  removeObject: conversions
endif

if batch
  deleteFile: temp$
endif

procedure for_each.action ()
  if pass == 1
    # First pass to normalise to target intensity
    # No checks are made at this point. Clipping is possible.

    .sound = selected("Sound")
    .name$ = selected$("Sound")

    @rms_and_max()

    selectObject: conversions
    Append row
    Set numeric value: for_each.item, "rms_pre",  rms_and_max.rms
    Set numeric value: for_each.item, "max_pre",  rms_and_max.max

    selectObject: .sound
    Scale intensity: target_intensity

    @rms_and_max()

    selectObject: conversions
    Set numeric value: for_each.item, "rms_post", rms_and_max.rms
    Set numeric value: for_each.item, "max_post", rms_and_max.max

    selectObject: .sound
    if batch
      Save as binary file: temp$ + .name$ + "Sound"
    elsif !inline
      copy[for_each.item] = Copy: .name$ + "_normalised"
    endif

  elsif pass == 2
    # Second pass.
    # If there were any clippings, we loop back through the sounds and
    # re-scale to avoid clippings.

    if batch
      deleteFile: temp$ + .name$ + "Sound"
    elsif !inline
      selectObject: copy[for_each.item]
    endif

    .sound = selected("Sound")
    .name$ = selected$("Sound")

    Formula: "self*" + string$(factor)

    @rms_and_max()

    selectObject: conversions
    Set numeric value: for_each.item, "rms_post", rms_and_max.rms
    Set numeric value: for_each.item, "max_post", rms_and_max.max

    selectObject: .sound

    if batch
      selectObject: .sound
      Save as WAV file: save_to$ + .name$ + ".wav"
      removeObject: .sound
    endif

  endif
endproc

procedure for_each.at_end_iteration ()
  # After iterating forwards once, we check if there were any clippings
  # If there were any, we need to go back and re-scale the sounds
  if for_each.next > 0 and for_each.item == for_each.total_items
    selectObject: conversions
    max = Get maximum: "max_post"

    if max >= 1
      factor = 0.999 / max

      for_each.item += 1
      for_each.next = -1
      pass = 2
    endif
  endif
endproc

include ../../plugin_vieweach/procedures/for_each.proc

procedure rms_and_max ()
  .rms = Get root-mean-square: 0, 0
  .max = Get maximum: 0, 0, "None"
  .min = Get minimum: 0, 0, "None"
  .max = if abs(.max) > abs(.min) then abs(.max) else abs(.min) fi
endproc
