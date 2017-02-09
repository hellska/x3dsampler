s.makeGui;
s.meter;
// Function to get file info from a soundfile array
~fileInfo = {|fileNum, sndFileArray|
	~cdur = sndFileArray[fileNum].numFrames/sndFileArray[fileNum].sampleRate;
	("Name: "+sndFileArray[fileNum].path
	+"\nDur"+(sndFileArray[fileNum].numFrames/sndFileArray[fileNum].sampleRate))
	+"\nIndex: "+fileNum
	+"\nChannels: "+sndFileArray[fileNum].numChannels
	+"\nSample Rate: "+sndFileArray[fileNum].sampleRate
	+"\nFrames: "+sndFileArray[fileNum].numFrames;
};
// Load Items from sound collection into the ListView
~setListViewContent = {|buffColl|
	~ticItems = Array.new(buffColl.size);
	buffColl.do({|item, idx|
		//	postln(idx+": "+~bufDrumkit[idx].path);
		var pathObj = PathName(buffColl[idx].path);
		~ticItems.add(pathObj.fileName);
		~ticView.items_(~ticItems)
	});
};
// Set the main window
~loboMain = Window("Lobotomix Controls").setTopLeftBounds(Rect(600,0,840,900)).front ;
~mainVol = s.volume.gui(~loboMain);
// MIDI keyboard synth selection
~synth_list = TextField(~loboMain, Rect(80,10,50,22)).focus(true) ;
~synth_active = TextField(~loboMain, Rect(135,10,220,22)).string_("Select a Synth");
// keyboard input
~synth_list.keyDownAction_{|i, char|
	char.switch(
		// the functions are in the file: midi_control_functions.scd
		$1, { ~simple.value; ~synth_active.string = "MIDI Func: ~simple"  },
		$2, { ~rumble.value; ~synth_active.string = "MIDI Func: ~rumble" },
		$3, { ~randomDelay.value; ~synth_active.string = "MIDI Func: ~randomDelay" },
		$4, { ~ranDelaySwipe.value; ~synth_active.string = "MIDI Func: ~ranDelaySwipe" },
		$5, { ~particleSin.value; ~synth_active.string = "Synth Selected: ~particleSin" },
		$6, { ~greenGlitch.value; ~synth_active.string = "Synth Selected: ~greenGlitch" },
		$7, { ~rumbledrone.value; ~synth_active.string = "Synth Selected: ~rumbledrone" }
	);
	~synth_list.string = ""
};
// Sound collection list viewer and selector
~ticView = ListView(~loboMain,Rect(80,60,300,100))
    .items_( ~ticItems )
    .background_(Color.white)
    .hiliteColor_(Color.green(alpha:0.6))
    .action_({ arg sbs;
	// [sbs.value, ~ticView.items[sbs.value]].postln; // .value returns the integer
	~info = ~fileInfo.value(sbs.value, ~lobo_CurrentSoundFileList);
	~ticInfo.string = ~info;
	// update the file viewer
	if (~ticViewButton.value == 1) {
		~x3d_updateSoundFile.value(~lobo_CurrentSoundFileList[sbs.value].path.standardizePath);
	};
	// set the sample of x3dlooper if external src is enabled (Button in ~x3dViewer)
	if (~x3d_externalSample.value == 1) {
		~currentSampleNo = 0;
		~playBuff = ~lobo_CurrentSoundFileList[~ticView.value];
		~x3d_updateSoundFile.value(~lobo_CurrentSoundFileList[sbs.value].path.standardizePath);
	};
}).keyDownAction_({|i, char, uni, key|
	if ( key == 13 ) {
		~lobo_CurrentSoundFileList[~ticView.value].play
	}
});
// populate the list with the default soundFile buffer
~lobo_CurrentSoundFileList = SoundFile.collect(path: "/Volumes/ssdData/soundsAndSamples/Industrial-autoprodotti/*".standardizePath);
~setListViewContent.value(~lobo_CurrentSoundFileList);
~lobo_Popup = PopUpMenu(~loboMain, Rect(80, 38, 200, 22))
.items_(["Industrial-autoprodotti", "tic_gaber", "900-marghera-workers-voices", "tzunami", "BLO", "planb", "convertedwav", ])
.action_({|me|
	var path, basepath;
	basepath = "/Volumes/ssdData/soundsAndSamples/";
	if ( me.item == "planb" , { basepath = "/Volumes/ssdData/infiniteorchestra/"; });
	if ( me.item == "convertedwav", { basepath = "/Volumes/ssdData/infiniteorchestra/"; });
	path = basepath++me.item++"/*";
	~lobo_CurrentSoundFileList.size.do{|me| ~lobo_CurrentSoundFileList.at(me).free };
	~lobo_CurrentSoundFileList = ();
	("Load audio files from: "+path).postln;
	~lobo_CurrentSoundFileList = SoundFile.collectIntoBuffers(path.standardizePath);
	~setListViewContent.value(~lobo_CurrentSoundFileList);
});
//// Load current sound collection into SoundFileView
~ticInfo = TextView(~loboMain, Rect(385, 60, 300, 100))
.string_(~fileInfo.value(~ticView.value, ~lobo_CurrentSoundFileList));

//// This button play sounds from ListView ~ticView
~ticPlay = Button(~loboMain, Rect(300, 70, 50, 22))
.states_([["Play", Color.black, Color.white]])
.action_({arg me;
	~lobo_CurrentSoundFileList[~ticView.value].play;
});
//// Enable visualization of waveshape of the looper when Internal Src is selected
~ticViewButton = Button(~loboMain,Rect(300,98,50,22))
.states_([["View",Color.black,Color.gray],["View",Color.yellow,Color.red]])
.action_({|me|
	switch (me.value,
		0, {~x3d_Label.string_("x3d Looper");
		~x3d_updateSoundFile.value(~currentFile.standardizePath) },
		1, {~x3d_Label.string_("Industrial Drum Kit");
			~x3d_updateSoundFile.value(~lobo_CurrentSoundFileList[~ticView.value].path.standardizePath) }
	);
});
//////////// x3dLooper GUI
~x3d_guiCreator = {|title, parent|

	~x3d_rec_string = "N O T  R E C O R D I N G";

	~x3dView = CompositeView(parent, Rect(80,170,605,200)).background_(Color.new255);
	~x3d_Label = StaticText(~x3dView, Rect(10,0,150,22))
	.string_(title)
	.stringColor_(Color.red);
	~x3d_fileView = SoundFileView(~x3dView, Rect(10,22,350,178))
	.timeCursorOn_(true)
	.timeCursorColor_(Color.red);

	// efault set to 1 in startup
	~x3d_externalSample = Button(~x3dView, Rect(390,22,90,20))
	.states_([["Internal src",Color.black,Color.white],
		["External src",Color.black,Color.red]]);
	~x3d_chansetup = Button(~x3dView,Rect(490,22,90,20))
	.states_([
		["Stereo Out",Color.black,Color.gray],
		["4 Channel",Color.black,Color.gray]])
	.action_({|me|
		if (me.value==0){~setup=2; ~sliderDelay=0};
		if (me.value==1){~setup=4; ~sliderDelay=1};
	});

	~x3d_delay_control_button = Button(~x3dView, Rect(390,52,90,20))
	.states_([["Weel 2 delay",Color.black,Color.white],
		["Weel 2 pointer",Color.black,Color.red]])
	.action_({|me|
		case
		{me.value==0} { ~sliderDelay = 0 }
		{me.value==1} { ~sliderDelay = 1 };
	});
	~x3d_loop_control_button = Button(~x3dView, Rect(490,52,90,20))
	.states_([["NO LOOP"],["L O O P",Color.black,Color.red]])
	.action_{|me|
		case
		{me.value==0} { ~loop = 0 }
		{me.value==1} { ~loop = 1 }
	};
	~x3d_pitchfx = Button(~x3dView, Rect(390, 82, 90, 20))
	.states_([["PitchShift", Color.black, Color.gray],["PitchShift", Color.black, Color.red]]);
	~x3d_delayfx = Button(~x3dView, Rect(490, 82, 90, 20))
	.states_([["Delay", Color.black, Color.gray],["Delay", Color.black, Color.red]]);
	// recording viewer - show if recording and sample number
	~x3d_rec_viewer = StaticText(~x3dView, Rect(400,160,170,30))
	.string_(~x3d_rec_string)
	.backColor_(Color.white)
	.align_(\center);
	// load the default sample file of x3dlooper
	~x3d_soundFile = SoundFile.new;
	~x3d_soundFile.openRead(~currentFile.standardizePath);
	~x3d_fileView.soundfile = ~x3d_soundFile;            // set soundfile
	~x3d_fileView.read(0, ~x3d_soundFile.numFrames);     // read in the entire file.
	~x3d_fileView.refresh;                  // refresh to display the file.
	~x3d_fileView.timeCursorPosition_(~x3d_soundFile.numFrames/2);
	//// Infinite Routine Coninuous update the cursor position in file viewer
	{
		inf.do{
			~cursorBus.get({ |frame|
				{~x3d_fileView.timeCursorPosition_(frame * ~x3d_soundFile.numFrames)}.defer;
				{~x3d_fileView.refresh}.defer;
			});
			0.02.wait;
		}
	}.fork;
	//// Function that updates the file viewer and restart the cursor process
	~x3d_updateSoundFile = {|filePath|
//		~cursorPlay.free;
		~x3d_soundFile.close;
		~x3d_soundFile = SoundFile.new;
		~x3d_soundFile.openRead(filePath);
		~x3d_fileView.soundfile = ~x3d_soundFile;            // set soundfile
		~x3d_fileView.read(0, ~x3d_soundFile.numFrames);     // read in the entire file.
		~x3d_fileView.refresh;                  // refresh to display the file.
		~x3d_fileView.timeCursorPosition_(~x3d_soundFile.numFrames/2);

	};


}; //// end of function ~x3d_guiCreator
// Notes
~x3d_netesGUI = {|parent,xpos,ypos|
	~x3d_notes = TextView(parent, Rect( xpos, ypos, 300, 250));
	~x3d_writeNotes = Button(parent, Rect(xpos + 150, ypos, 150, 10))
	.states_([["save me"],["SAVE ME"]])
	.action_({|me|
		var outfile, outext;
		me.value.postln;
		~x3d_notes.string.postln;

		outext = Date.getDate;
		outext.dayStamp.postln;
		outfile = File(("/Users/hellska/Documents/IcePick/"++outext.dayStamp++".txt").standardizePath, "w+");
		outfile.write(~x3d_notes.string);
		outfile.close;
	});
};
//// tap tempo GUI
~tapTempoGuiCreator = {|title,parent|
	~tapTempo_view = CompositeView(parent, Rect(685,60,150,210)).background_(Color.yellow);
	~tapTempo_max_BPM = 4000;
	~lastTap = nil;
	~tapTempo = {
		var estim;
        ~lastTap.isNil.if({~lastTap = Main.elapsedTime}, {
            estim = Main.elapsedTime;
			~taptime = estim - ~lastTap;
			~tapbpm = 60 / (estim - ~lastTap);
			~lastTap = estim;
			~tapTempo_text.string_("BPM: "++~tapbpm.round(0.01)++"\nTime: "++~taptime.round(0.01));
			if (~tapTempo_2Delay.value==1) {
				if (~taptime < ~tapTempo_max_BPM) {
					~delTime.set(~taptime);
				}
			}
		})
    };
	~tapTempo_tapButton = Button.new(~tapTempo_view, Rect(0, 0, 150, 100))
	.states_([["Tap me or space bar", Color.black, Color.grey]])
    .action_({~tapTempo.value});
	~tapTempo_text = StaticText.new(~tapTempo_view, Rect(10, 105, 150, 50))
    .string_("No tempo")
    .font_(Font("Monaco", 15));
	~tapTempo_2Delay = Button.new(~tapTempo_view,Rect(130,105,20,20))
	.states_([["x",Color.black,Color.gray],["D",Color.black,Color.red]]);
	~tapTempoInsert = NumberBox(~tapTempo_view, Rect(10, 180, 130, 30))
	.decimals_(7).clipLo_(0.0000001).clipHi_(~tapTempo_max_BPM)
	.action_{|me|
		var input = me.value;
		if (input > ~tapTempo_max_BPM, { input = ~tapTempo_max_BPM; me.value = input; }); // clip tempo
		if (~tapTempo_2Delay.value==1, { ~delTime.set(input); input.postln;});
	};
};