include ../../plugin_tap/procedures/more.proc
include ../../plugin_selection/procedures/tiny.proc
include ../../plugin_strutils/procedures/file_list_full_path.proc

sndutils$ = preferencesDirectory$ - "con" + "/plugin_sndutils/scripts/"

@plan: 21

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

@saveSelection()
for i to saveSelection.n
  selectObject: saveSelection.id[i]
  Save as WAV file: in$ + "/" + selected$("Sound") + ".wav"
  Remove
endfor

nocheck selectObject: undefined
for t from 0 to 1
  target = target[t]
  for table from 0 to 1
    runScript: sndutils$ + "batch_rms_normalise.praat",
      ... in$, out$, "wav", target, table

    @is: numberOfSelected("Table"), table,
      ... if table then "Kept" else "Did not keep" fi + " table"

    @is: numberOfSelected(), numberOfSelected("Table"),
      ... if table then "Only table" else "No objects" fi + " selected"

    nocheck removeObject: selected("Table")

    @fileListFullPath: "batch", out$, "*wav", 0
    files = selected("Strings")
    outfiles = Get number of strings

    @is: infiles, outfiles,
      ... "Same number of files in input and output directories"

    @test: target
    @is_true: test.all_same, "All sounds normalised"
    @is: test.to_reference, (1 - t),
    ... "Normalised in batch mode, " +
    ... if table then "with" else "without" fi + " table"

    for i to outfiles
      file$ = Get string: i
      deleteFile: file$
    endfor

    removeObject: files
  endfor
endfor

@remove_tree: in$
@remove_tree: out$

removeObject: synth, sound, textgrid

@ok_selection()

@done_testing()

procedure test: .target
  .to_reference = 1

  .strings = selected("Strings")
  .n = Get number of strings
  for .i to .n
    .name$ = Get string: .i
    .snd = Read from file: .name$
    .intensity[.i] = Get intensity (dB)
    Remove

    if abs(.target - .intensity[.i]) > 0.0001
      .to_reference = 0
    endif

    selectObject: .strings
  endfor

  .all_same = 1
  for .i from 2 to infiles
    if abs(.intensity[.i] - .intensity[1]) > 0.0001
      .all_same = 0
    endif
  endfor
endproc

procedure remove_tree: .path$
  runScript: preferencesDirectory$ + "/plugin_strutils/scripts/" +
    ... "recursive_file_list_full_path.praat", "batch", .path, "*", 0
  .n = Get number of strings
  for .i to .n
    .file$ = Get string: .i
    deleteFile: .file$
  endfor
  nocheck Remove

  runScript: preferencesDirectory$ + "/plugin_strutils/scripts/" +
    ... "recursive_directory_list_full_path.praat", "batch", .path, "*", 0
  .n = Get number of strings
  for .i to .n
    .dir$ = Get string: .i
    deleteFile: .dir$
  endfor
  nocheck Remove

  deleteFile: .path$
endproc
