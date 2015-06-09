
selection$ = preferencesDirectory$ - "con" + "/plugin_selection/scripts/"

runScript: selection$ + "save_selection.praat"
selection = selected("Table")
Rename: "original_selection"

conversions = Create Table with column names: "conversions", 0,
  ... "filename rms_pre max_pre rms_post max_post"

@createEmptySelectionTable()
final_selection = createEmptySelectionTable.table
selectObject: final_selection
Rename: "final_selection"

selectObject: selection
if (!batch and tables) or (batch and strings)
  runScript: selection$ + "restore_selection.praat"
  removeObject: selection
endif

pass = 1
@for_each()

if max >= 1
  appendInfoLine: "# W: Target intensity reduced to " +
    ... fixed$(intensity, 2), "dB to avoid clipping"
endif

if !keep_conversion_table
  removeObject: conversions
else
  @addToSelectionTable: final_selection, conversions
endif

selectObject: final_selection
runScript: selection$ + "restore_selection.praat"
nocheck removeObject: selection, final_selection

procedure for_each.action ()
  if pass == 1
    # First pass to normalise to target intensity
    # No checks are made at this point. Clipping is possible.

    .sound = selected("Sound")
    .name$ = selected$("Sound")

    if !batch
      if !inline
        .sound = Copy: .name$ + "_normalised"
      endif
      @addToSelectionTable: final_selection, .sound
    endif

    @rms_and_max()

    selectObject: conversions
    Append row
    Set numeric value: for_each.current, "rms_pre",  rms_and_max.rms
    Set numeric value: for_each.current, "max_pre",  rms_and_max.max

    selectObject: .sound
    Scale intensity: target_intensity

    @rms_and_max()

    selectObject: conversions
    Set numeric value: for_each.current, "rms_post", rms_and_max.rms
    Set numeric value: for_each.current, "max_post", rms_and_max.max

    selectObject: .sound
    if batch
      Save as binary file: temp$ + .name$ + "_temp.Sound"
    endif

  elsif pass == 2
    # Second pass.
    # If there were any clippings, we loop back through the sounds and
    # re-scale to avoid clippings.
    # Second pass is mandatory in batch mode, to convert binary to wav

    .name$ = selected$("Sound")

    if batch
      Read from file: temp$ + .name$ + "_temp.Sound"
      deleteFile: temp$ + .name$ + "_temp.Sound"
    elsif !inline
      selectObject: Object_'final_selection'[for_each.current, "id"]
    endif

    .sound = selected("Sound")

    if max >= 1

      Formula: "self*" + string$(factor)

      @rms_and_max()

      selectObject: conversions
      Set numeric value: for_each.current, "rms_post", rms_and_max.rms
      Set numeric value: for_each.current, "max_post", rms_and_max.max

      selectObject: .sound
      intensity = Get intensity (dB)
    endif

    if batch
      selectObject: .sound
      Save as WAV file: save_to$ + .name$ + ".wav"
      removeObject: .sound
    endif

  endif
endproc

procedure for_each.at_end_iteration ()
  # After iterating forwards once, we check if there were any clippings
  # If there were any, we need to go back and re-scale the sounds.
  # If we run in batch mode, we loop back anyway to convert to wav
  if for_each.current == for_each.last
    if pass == 1
      selectObject: conversions
      max = Get maximum: "max_post"

      # Go back for a second pass
      if batch or max >= 1
        factor = if max >= 1 then 0.999 / max else 1 fi
        for_each.current = 0
        pass += 1
      endif
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
