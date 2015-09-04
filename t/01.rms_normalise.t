include ../../plugin_testsimple/procedures/test_simple.proc

preferencesDirectory$ = replace_regex$(preferencesDirectory$, "(con)?(\.(EXE|exe))?$", "", 0)

# Setup

@no_plan()

selection$ = preferencesDirectory$ + "/plugin_selection/scripts/"
sndutils$  = preferencesDirectory$ + "/plugin_sndutils/scripts/"
strutils$  = preferencesDirectory$ + "/plugin_strutils/scripts/"
target[0]  = 70
target[1]  = 90

procedure for_each.action ()
  .intensity[for_each.item] = Get intensity (dB)
  if abs(test.target - .intensity[for_each.item]) > 0.0001
    test.to_reference = 0
  endif
endproc

include ../../plugin_vieweach/procedures/for_each.proc

procedure test: .target
  .to_reference = 1
  @for_each()
  .all_same = 1
  for .i from 2 to infiles
    if abs(for_each.action.intensity[.i] - for_each.action.intensity[1]) > 0.0001
      .all_same = 0
    endif
  endfor
endproc

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
@ok: !result[0] and !result[1],
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

        appendInfoLine: "# Normalising from " +
          ... if from_sounds then "sounds" else "table" fi + ". " + 
          ... if table then "+" else "-" fi + "table / " +
          ... if inline then "+" else "-" fi + "inline"

        selectObject: sounds
        if from_sounds
          runScript: selection$ + "restore_selection.praat"
        endif
        runScript: sndutils$ + "rms_normalise.praat", target, table, inline

        @ok: numberOfSelected("Table") == table,
          ... if table then "Kept" else "Did not keep" fi + " table"
        nocheck removeObject: selected("Table")

        first[1] = Object_'sounds'[1, "id"]
        last[1]  = Object_'sounds'[Object_'sounds'.nrow, "id"]
        first[2] = selected("Sound", 1)
        last[2]  = selected("Sound", numberOfSelected("Sound"))
        same = if first[1] == first[2] and last[1] == last[2] then 1 else 0 fi
        @ok: same == inline,
          ... "Changes " + if inline then "" else "not" fi + " made inline"

        runScript: selection$ + "save_selection.praat"
        normalised = selected("Table")

        @test: target
        @ok: test.all_same and (test.to_reference == (1 - t)),
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

# Batch mode

selectObject: original_sounds
runScript: selection$ + "restore_selection.praat"

in$  = preferencesDirectory$ + "/plugin_sndutils/t/batch_in"
out$ = preferencesDirectory$ + "/plugin_sndutils/t/batch_out"

createDirectory: in$
createDirectory: out$

for i to infiles
  selectObject: Object_'original_sounds'[i, "id"]
  Save as WAV file: in$ + "/" + selected$("Sound") + ".wav"
endfor

nocheck selectObject: undefined
for t from 0 to 1
  target = target[t]
  for table from 0 to 1
    runScript: sndutils$ + "batch_rms_normalise.praat",
      ... in$, out$, "wav", target, table

    @ok: numberOfSelected("Table") == table,
      ... if table then "Kept" else "Did not keep" fi + " table"
    @ok: numberOfSelected() == numberOfSelected("Table"),
      ... if table then "Only table" else "No objects" fi + " selected"
    nocheck removeObject: selected("Table")

    runScript: strutils$ + "file_list_full_path.praat", "batch", out$, "*wav", 0
    files = selected("Strings")
    outfiles = Get number of strings

    @ok: infiles == outfiles,
      ... "Same number of files in input and output directories"

    @test: target
    @ok: test.all_same and (test.to_reference == (1 - t)),
    ... "Normalised in batch mode, " +
    ... if table then "with" else "without" fi + " table"

    for i to outfiles
      file$ = Get string: i
      deleteFile: file$
    endfor

    removeObject: files
  endfor
endfor
deleteFile: out$

files = Create Strings as file list: "in", in$ + "/*wav"
for i to infiles
  file$ = Get string: i
  deleteFile: in$ + "/" + file$
endfor
deleteFile: in$

selectObject: original_sounds
runScript: selection$ + "restore_selection.praat"
Remove

removeObject: original_sounds, synth, sound, textgrid, files

@done_testing()
