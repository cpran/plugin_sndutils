include ../../plugin_tap/procedures/more.proc
include ../../plugin_strutils/procedures/file_list_full_path.proc

@plan: 66

in$  = preferencesDirectory$ + "/plugin_sndutils/t/batch_in"
out$ = preferencesDirectory$ + "/plugin_sndutils/t/batch_out"

target[0] = 70
target[1] = 90

createDirectory: in$
createDirectory: out$

synth = Create SpeechSynthesizer: "English", "default"
To Sound: "This is some text", "yes"
sound = selected("Sound")
textgrid = selected("TextGrid")

Extract non-empty intervals: 3, "no"
infiles = numberOfSelected("Sound")

runScript: selection$ + "save_selection.praat"
original_sounds = selected("Table")

# Tests

@test: target[0]
result[0] = if test.all_same and test.to_reference then 1 else 0 fi
@test: target[1]
result[1] = if test.all_same and test.to_reference then 1 else 0 fi

@is_false: result[0] or result[1],
  ... "Base sounds are not normalised"

# Standard mode

for t from 0 to 1
  target = target[t]
  for from_sounds from 0 to 1
    for inline from 0 to 1
      for table from 0 to 1

        selectObject: original_sounds
        runScript: selection$ + "restore_selection.praat"
        runScript: selection$ + "copy_selected.praat"
        runScript: selection$ + "save_selection.praat"
        sounds = selected("Table")

        @diag: "Normalising from " +
          ... if from_sounds then "sounds" else "table" fi + ". " +
          ... if table  then "+" else "-" fi + "table / " +
          ... if inline then "+" else "-" fi + "inline"

        selectObject: sounds
        if from_sounds
          runScript: selection$ + "restore_selection.praat"
        endif
        runScript: sndutils$ + "rms_normalise.praat", target, table, inline

        @is: numberOfSelected("Table"), table,
          ... if table then "Kept" else "Did not keep" fi + " table"
        nocheck removeObject: selected("Table")

        first[1] = Object_'sounds'[1, "id"]
        last[1]  = Object_'sounds'[Object_'sounds'.nrow, "id"]
        first[2] = selected("Sound", 1)
        last[2]  = selected("Sound", numberOfSelected("Sound"))
        same = if first[1] == first[2] and last[1] == last[2] then 1 else 0 fi
        @is: same, inline,
          ... "Changes " + if inline then "" else "not" fi + " made inline"

        runScript: selection$ + "save_selection.praat"
        normalised = selected("Table")

        @test: target
        @is_true: test.all_same, "All sounds normalised"
        @is: test.to_reference, (1 - t),
          ... "Normalised from " +
          ... if from_sounds then "selected sounds" else "selection table" fi +
          ... ", " +
          ... if table then "with" else "without" fi + " table" +
          ... if inline then "" else " not" fi + " inline"

        selectObject: sounds, normalised
        final = Append
        runScript: selection$ + "restore_selection.praat"
        Remove
        removeObject: final, sounds, normalised

      endfor
    endfor
  endfor
endfor

selectObject: original_sounds
runScript: selection$ + "restore_selection.praat"
Remove

removeObject: original_sounds, synth, sound, textgrid

@ok_selection()

@done_testing()

procedure test: .target
  .to_reference = 1

  .table = selected("Table")
  for .i to Object_'.table'.nrow
    selectObject: Object_'.table'[.i, "id"]
    .intensity[.i] = Get intensity (dB)

    if abs(.target - .intensity[.i]) > 0.0001
      .to_reference = 0
    endif
  endfor
  selectObject: .table

  .all_same = 1
  for .i from 2 to infiles
    if abs(.intensity[.i] - .intensity[1]) > 0.0001
      .all_same = 0
    endif
  endfor
endproc
