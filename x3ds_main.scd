// Use With Junxion Software and the file x3dLoopControl.j4xml
// put the subfolder name you want
// ~changeFolder.value("industr", "wav");
// ~changeFolder.value("20141026", "aiff");
// ~changeFolder.value("20150325", "aiff");
// restart interpreter and quit server
// thisProcess.recompile;
// boot the local server
// s.boot;
// first of all load all needed Bus and variables [[[ONLY ONCE]]]
///////// Global Variables
~currentFolder = "date +\"%Y%m%d\"".unixCmdGetStdOutLines;
~currentFolder = "~/x3dLooper/"++~currentFolder[0]++"/";
~recFile = ~currentFolder++"x3dL_1.aiff";
~stdHeader = ~currentFolder++"x3dL_";
~ext = "aiff";
// check current folder and create a new one for each day session
if ( File.exists(~currentFolder.standardizePath) )
{ ("Folder for sample record: "++~currentFolder).postln }
{ "mkdir ~/x3dLooper/`date +\"%Y%m%d\"`".unixCmd } ;
// defines wich bus are used for audio input
~inch1 = 0;
~inch2 = 6;
// other startup values
~startPos = 0;
~panpot = 0;
~currentRecNo = 1;
///////// Audio Bus
~input = Bus.audio(s, 1);
~sampleOut = Bus.audio(s, 4);
~mute = Bus.audio(s, 2);
// ~fxBus = Bus.audio(s, 2);
~pitchBus = Bus.audio(s, 4);
~delayBus = Bus.audio(s, 4);
~compBus = Bus.audio(s, 4);
~fxCount = 0;
~inputVol = 0.9;
~maxDelTime = 4;
///////// Control Bus
~pitchRatio = Bus.control(s,1);
~delTime = Bus.control(s,1);
~cursorBus = Bus.control(s,1);
///////// Buffers
~recordBuff = Buffer.alloc(s, 65536);
~currentFile = "~/x3dLooper/x3dL_default.aiff";
~playBuff = Buffer.read(s, ~currentFile.standardizePath, 0);
///////// F Control
~fx1 = 0;
~fx2 = 0;
~fx3 = 0;
~fx4 = 0;
//// audio routing
~sampleGroup = Group.new(s, \addToHead);
~efxGroup = Group.new(s, \addToTail);
//// define setup 2 or 4 speakers
// ~setup=2 // default
~setup = 2;
~loop = 0;
// defines slider control
// if = 0 slider controls delay time, if 0 1 slider controls sample position (used in 4 channel layout)
// ~sliderDelay = 1;
~sliderDelay = 0;
////////////////////////////////////
// SynthDef Definition - \soundinMono, \rec, \play, \play4, \picthShifter, \deldelay \mixer
////////////////////////////////////
// read input signal
SynthDef.new(\soundinMono, {arg inBus, outBus=0,amp=0.9;
	var source, out;
	source = SoundIn.ar(inBus);
	out = source * amp;
	Out.ar(outBus, out)
}).send(s);
// this will record to the disk
SynthDef(\rec, {arg bufnum, inbus;
	var source;
	source = In.ar(inbus,1);
    DiskOut.ar(bufnum, source);
}).send(s);
// this will play it back mono file (default panpot center)
SynthDef(\play, {| outBus = 0, bufnum, start = 0, loop = 0, panpot = 0, attack = 0.003, decay = 0.003, time = 0.1 |
	var source, out;
	source = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, start, loop, doneAction:2) *
	EnvGen.kr(Env.linen(attack, time, decay));
	out = Pan2.ar(source, panpot);
    Out.ar(outBus, out)
}).send(s);
SynthDef(\playLoop, {| outBus = 0, bufnum, start = 0, loop = 0, panpot = 0 |
	var source, out, env, envdur;
	envdur = 0.5;
	env = Env.asr(attackTime:0.02,sustainLevel:1,releaseTime:envdur,curve:\lin);
	source = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, start, loop, doneAction:2) *
	EnvGen.ar(env);
	out = Pan2.ar(source,panpot);
    Out.ar(outBus, out)
}).send(s);
// 4 channels player
SynthDef(\play4, {| outBus = 0, bufnum, start = 0, loop = 0, xpos = 0, ypos = 0, attack = 0.003, decay = 0.003, time = 0.1|
	var source, out;
	source = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, start, loop, doneAction:2) *
	EnvGen.kr(Env.linen(attack, time, decay));
	out = Pan4.ar(source,xpos,ypos);
    Out.ar(outBus, out)
}).send(s);
SynthDef(\play4Loop, {| outBus = 0, bufnum, start = 0, loop = 0, xpos = 0, ypos = 0 |
	var source, out, env, envdur;
	envdur = start / 44100 - 0.02 - 0.5;
	env = Env.asr(attackTime:0.02,sustainLevel:1,releaseTime:envdur,curve:\lin);
	source = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, start, loop, doneAction:2) *
	EnvGen.ar(env);
	out = Pan4.ar(source,xpos,ypos);
    Out.ar(outBus, out)
}).send(s);
// Very simple Pitch Shifter
SynthDef.new(\picthShifter, {|inBus, outBus, pshift, pRndVar = 0, trndVar = 0|
	var source, out;
	source = In.ar(inBus, 4);
	out = PitchShift.ar(source, 0.2, pshift, pRndVar, trndVar);
	Out.ar(outBus, out)
}).send(s);
SynthDef(\deldelay, {|inBus, outBus, repeat = 15, maxDelTime = 4, delaytime|
	var source, out;
	source = In.ar(inBus, 4);
	out = source + CombC.ar(source,maxdelaytime: maxDelTime, delaytime: delaytime,decaytime: delaytime * repeat);
	Out.ar(outBus, out)
}).send(s);
// compressor
SynthDef(\compressor, {
	|inbus,
	outbus = 0,
	thresh = 1|
	var source, out;
	source = In.ar(inbus, 4);
	out = Compander.ar(source, source, thresh, 1, 0.5, 0.002, 0.01);
	Out.ar(outbus, out)
}).send(s);
// Otput Mixer for Al Samples
SynthDef.new(\mixer, {|inBus, outBus = 0|
	var source;
	source = In.ar(inBus, 4);
	Out.ar(outBus, source)
}).send(s);
// granulator on current buffer
SynthDef.new(\granulaSample, {
	|dur = 0.1,
	ratio = 1,
	maxGrains = 30,
	outBus = 0,
	sndBuf,
	overlap = 0.1,
	amp = 0.7|
	var env, source, out;
	source = GrainBuf.ar(2, Impulse.ar(ratio/dur-overlap), dur, sndBuf, SinOsc.kr(23)+1/2, maxGrains: maxGrains);
	out = Resonz.ar(source, Saw.kr(0.5)*200+300);
	Out.ar(outBus, out)
}).send(s);
////////////////////////////////////
// Functions - ~play, ~rec, ~stop
////////////////////////////////////
// recording soundin
~rec = {|filein, source|
	// comment this to record from a synthdef
	i = Synth.new(\soundinMono, [\inBus, source, \outBus, ~input, \amp, ~inputVol]);
	r = Buffer.alloc(s, 65536, 1);
//	r.write(filein.standardizePath, ~ext, "int16", 0, 0, true);

	r.write(filein.standardizePath, ~ext, "int24", 0, 0, true);
	b = Synth.tail(nil,\rec, [\bufnum, r, \inbus, ~input]);
};
// stop recording soundin
~stop = {
	b.free;
	i.free;
	r.close;
	r.free;
};
~x3d_play_array = Array.fill(25,0);
~x3d_play_array_element = 0;
~play = {|buffer, startPos, time|
	if (~setup==2){
		if (~loop==1) { // behaviour when loop is set
			if (~x3d_play_array_element<~x3d_loop_number) {
				~x3d_play_array.put(~x3d_play_array_element,Synth.new(\playLoop, [\bufnum, buffer, \start, startPos, \panpot, ~panpot, \outBus, ~sampleOut, \loop, ~loop],~sampleGroup, addAction: \addToHead));
				{ ~x3d_loop_buttons_array[~x3d_play_array_element].value_(1);
					~x3d_play_array_element = ~x3d_play_array_element + 1; }.defer;
				"added new element".postln;
			} {
				"No other loop permitted!".postln;
			};
		} { // behaviour when loop is switched off
			Synth.new(\play, [\bufnum, buffer, \start, startPos, \panpot, ~panpot, \outBus, ~sampleOut, \loop, ~loop, \time, time],~sampleGroup, addAction: \addToHead);
		};
	};
	if (~setup==4){
		Synth.new(\play4, [\bufnum, buffer, \start, startPos, \xpos, ~panpot, \ypos, ~panpotY, \outBus, ~sampleOut,\loop, ~loop, \time, time],~sampleGroup, addAction: \addToHead);
	}
};
// end of Synth Def
////////////////////////////////////
// Actions trigger - play,rec,stop,samplePosition
////////////////////////////////////

// Joystik controlled looper functions via OSC protocol
OSCdef(\play, {|msg, time, addr, port|
	if (msg[1]==1) {
		var time;
		time = (~playBuff.numFrames - ~startPos) / 44100;
		time = time * ~timescale;
		time.postln;
		~play.value(~playBuff, ~startPos, time);
	};
 },
	'/jXcontrol/1'
);
// recording control
OSCdef(\rec, {|msg, time, addr, port|
	if (msg[1]==1){
		~recFile = ~stdHeader++~currentRecNo++"."++~ext;
		~rec.value(~recFile, ~currentInputSource);
		// set GUI
		~x3d_rec_string = "R E C O R D I N G => "++~currentRecNo;
		{ ~x3d_rec_viewer.backColor_(Color.red).string_(~x3d_rec_string) }.defer;
		("Recording sample: "++~recFile).postln;
		} {
		~stop.value();
		("Stop Recording sample: "++~recFile).postln;
		if (~currentRecNo<6) { ~currentRecNo = ~currentRecNo + 1 } { ~currentRecNo = 1 };
		~x3d_rec_string = "R E C O R D E D => "++~currentRecNo;
		{ ~x3d_rec_viewer.backColor_(Color.white).string_(~x3d_rec_string) }.defer;
	};
	},
	'/jXcontrol/2'
);
// Sample start Pos control
OSCdef(\startPos, {|msg, time, addr, port|
	if (~sliderDelay==0){
		~startPos = (msg[1] * ~playBuff.numFrames).floor.asInt;
		// set the cursor of the viewer
		~cursorBus.set(msg[1]);
	}
	},
	'/jXcontrol/3'
);
// second control from /jXcontrol/3 to control position in Pan4
OSCdef(\panpotY, {|msg, time, addr, port|
	~panpotY = (msg[1] * 2 - 1) * - 1; // change range -1/1
	}, '/jXcontrol/3'
);
// Sample panpot control
//// set here the buffer
OSCdef(\panpot, {|msg, time, addr, port|
	~panpot = msg[1] * 2 - 1; // change range -1/1
	}, '/jXcontrol/Xaxis'
);
// Pitch Shifter Mapping Function And Range Definition
~minPitch = 0.02;
~mulPitch = 2.5;
OSCdef(\pitch, {|msg, time, addr, port|
	~pitchRatio.set(msg[1] * ~mulPitch + ~minPitch);
	~timescale = msg[1];
	// (msg[1] * ~mulPitch + ~minPitch).postln;
}, '/jXcontrol/Zrotation');
// receive slider values
OSCdef(\deltime, {|msg, time, addr, port|
	if (~sliderDelay==0){
		~delTime.set(msg[1] * ~maxDelTime + 0.02);
	} {
		~startPos = (msg[1] * ~playBuff.numFrames).floor.asInt;
		// set the cursor of the viewer
		~cursorBus.set(msg[1]);
	}
	// (msg[1] * 4 + 0.02).postln;
}, '/jXcontrol/slider');
// Bus selection for Sample Recording
OSCdef(\inputSource, {|msg, time, addr, port|
	var sourceNo = (msg[1]*127).floor;
	if ((msg[1]*127).floor == 36)
	{ ~currentInputSource = ~inch1; ("Audio source selected: "++~currentInputSource).postln };
	if ((msg[1]*127).floor == 108)
	{ ~currentInputSource = ~inch2; ("Audio source selected: "++~currentInputSource).postln };
	},
	'/jXcontrol/10'
);
////////////////////////////////////
// Functions and OSC def for Sample Selection
////////////////////////////////////
~sampleSelection = {|sampleNo|
	~currentFile = ~stdHeader++sampleNo++"."++~ext;
	~recFile = ~stdHeader++sampleNo++"."++~ext;
	if (File.exists(~currentFile.standardizePath)) {
		("Selected File: "++~currentFile).postln;
	} {
		~currentFile = "~/x3dLooper/x3dL_default.aiff";
		("SAMPLE NOT RECORDED YET! Selected default file: "++~currentFile).postln;
	};
	~playBuff = Buffer.read(s, ~currentFile.standardizePath);
	// show waveshape in lobotomixGUI file viewer
	{ ~x3d_updateSoundFile.value(~currentFile.standardizePath) }.defer;
};

OSCdef(\selsample1, {|msg, time, addr, port|
	// transform message input into toggle ;)
	if (msg[1]!=0) {
		~sampleSelection.value(1);
	} },
	'/jXcontrol/4'
);
OSCdef(\selsample2, {|msg, time, addr, port|
	// transform message input into toggle ;)
	if (msg[1]!=0) {
		~sampleSelection.value(2);
	} },
	'/jXcontrol/5'
);
OSCdef(\selsample3, {|msg, time, addr, port|
	// transform message input into toggle ;)
	if (msg[1]!=0) {
		~sampleSelection.value(3);
	} },
	'/jXcontrol/6'
);
OSCdef(\selsample4, {|msg, time, addr, port|
	// transform message input into toggle ;)
	if (msg[1]!=0) {
		~sampleSelection.value(4);
	} },
	'/jXcontrol/7'
);
OSCdef(\selsample5, {|msg, time, addr, port|
	// transform message input into toggle ;)
	if (msg[1]!=0) {
		~sampleSelection.value(5);
	} },
	'/jXcontrol/8'
);
OSCdef(\selsample6, {|msg, time, addr, port|
	// transform message input into toggle ;)
	if (msg[1]!=0) {
		~sampleSelection.value(6);
	} },
	'/jXcontrol/9'
);
// perform fx 1 on/off
~fx1func = {|in|
	if (in==1) {
		if (~fx1 == 1) {
			~fxCount = ~fxCount - 1;
			if (~fx2 == 0) {
				~mixer.set(\outBus, ~compBus);
			} {
				~mixer.set(\outBus, ~delayBus);
			};
			~pitchshifter.set(\outBus, ~mute);
			"FX 1 (pitch shifter) off!".postln;
			{ ~x3d_pitchfx.value = 0 }.defer;
			~fxCount.postln;
			~fx1 = 0;
		}
	} {
		if (~fx1 != 1) {
			~fxCount = ~fxCount + 1;
			//				~mixer.set(\inBus, ~fxBus);
			~mixer.set(\outBus, ~pitchBus);
			if (~fx2==0) {
				~pitchshifter.set(\outBus, ~compBus);
			} {
				~pitchshifter.set(\outBus, ~delayBus);
			};
			"FX 1 (pitch shifter) on!".postln;
			{ ~x3d_pitchfx.value = 1 }.defer;
			~fxCount.postln;
			~fx1 = 1;
		};
	};
};
OSCdef(\fx1, {|msg, time, addr, port|
	~fx1func.value(msg[1]);
}, '/jXcontrol/fx1');
// second fx
~fx2func = {|in|
	if (in==1) {
		~fxCount = ~fxCount - 1;
		if (~fx1 == 0) {
			~mixer.set(\outBus, ~compBus);
		} {
			~mixer.set(\outBus, ~pitchBus);
			// change pitchshifter routing here
			~pitchshifter.set(\outBus, ~compBus);
		};
		~delay.set(\outBus, ~mute);
		"FX 2 (delay) off!".postln;
		{ ~x3d_delayfx.value = 0 }.defer;
		~fxCount.postln;
		~fx2 = 0;
	} {
		~delay.map(\delaytime, ~delTime);
		~fxCount = ~fxCount + 1;
//		~mixer.set(\inBus, ~fxBus);
		if (~fx1==0) {
			~mixer.set(\outBus, ~delayBus);
			~delay.set(\outBus, ~compBus);
		} {
			~pitchshifter.set(\outBus, ~delayBus);
			~delay.set(\outBus, ~compBus);
		};
		"FX 2 (delay) on!".postln;
		{ ~x3d_delayfx.value = 1 }.defer;
		~fxCount.postln;
		~fx2 = 1;
	};
};
OSCdef(\fx2, {|msg, time, addr, port|
	~fx2func.value(msg[1]);
}, '/jXcontrol/fx2');
// third fx
OSCdef(\fx3, {|msg, time, addr, port|

	var thisBuf;
	msg[1].postln; 	// Type new code here
	// insert a gentle fade out when switch off the instrument
	if (~loop==0) {
		~loop = 1;
		{ ~x3d_loop_control_button.value_(1) }.defer;
	} {
		~loop = 0;
		{ ~x3d_loop_control_button.value_(0) }.defer;
	};
}, '/jXcontrol/fx3');
// fourth fx
OSCdef(\fx4, {|msg, time, addr, port|



	msg[1].postln; 	// Type new code here



}, '/jXcontrol/fx4');
~startup = {
	"Starting default Synths and values mapping.......".postln;
	~pitchshifter = Synth.new(\picthShifter,
		[\inBus, ~pitchBus, \pshift, 2.3, \outBus, ~mute],~efxGroup, addAction: \addToHead);
	~delay = Synth.new(\deldelay,
		[\inBus, ~delayBus, \outBus, ~mute, \delaytime, 0.2],~efxGroup,addAction: \addToTail);
	~compressor = Synth(\compressor, [\inbus, ~compBus], ~efxGroup, \addToTail);
	~mixer = Synth.new(\mixer, [\inBus, ~sampleOut, \outBus, ~compBus],~sampleGroup, addAction: \addToTail);
	~pitchshifter.map(\pshift, ~pitchRatio);
};
// select sample folder
~changeFolder = {|folder, ext|
~currentFolder = "~/x3dLooper/"++folder++"/";
~recFile = ~currentFolder++"x3dL_1.aiff";
~stdHeader = ~currentFolder++"x3dL_";
~stdHeader.postln;
~ext = ext;
~ext.postln;
};
