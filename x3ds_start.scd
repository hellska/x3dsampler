[
"/Volumes/ssdData/GIT_repos_cloned/x3dSampler/grainSynthDefs.scd",
"/Volumes/ssdData/GIT_repos_cloned/x3dSampler/midi_control_functions.scd",
"/Volumes/ssdData/GIT_repos_cloned/x3dSampler/sound_control_synths.scd",
"/Volumes/ssdData/GIT_repos_cloned/x3dSampler/soundfilesCollections.scd",
"/Volumes/ssdData/GIT_repos_cloned/x3dSampler/subtractiveSynthetizers.scd",
"/Volumes/ssdData/GIT_repos_cloned/x3dSampler/x3dLooper_loops_GUI.scd",
"/Volumes/ssdData/GIT_repos_cloned/x3dSampler/x3dLooper.scd"
]
(
~x3ds_start = {
	var ldir;
	ldir = "".resolveRelative.asString;
	(ldir++"x3ds_collections.scd").standardizePath.load;
	(ldir++"x3ds_main.scd").standardizePath.load;
	(ldir++"x3ds_GUI.scd").standardizePath.load;
}
)
~x3ds_start.value();