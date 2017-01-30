// sounds from various forders
~soundFileDrumkit = SoundFile.collect(path: "/Volumes/ssdData/soundsAndSamples/Industrial-autoprodotti/*".standardizePath);
// collect soundfiles into buffer
~bufDrumkit =       SoundFile.collectIntoBuffers("/Volumes/ssdData/soundsAndSamples/Industrial-autoprodotti/*".standardizePath);
~ticGaber =         SoundFile.collectIntoBuffers("/Volumes/ssdData/soundsAndSamples/tic_gaber/*".standardizePath);
~mwvoices900 =      SoundFile.collectIntoBuffers("/Volumes/ssdData/soundsAndSamples/900-marghera-workers-voices/*".standardizePath);
~tzunami =          SoundFile.collectIntoBuffers("/Volumes/ssdData/soundsAndSamples/tzunami/*".standardizePath);
~blo_samples =      SoundFile.collectIntoBuffers("/Volumes/ssdData/soundsAndSamples/BLO/*".standardizePath);
// setup into another path
~infiniteorchestra = SoundFile.collectIntoBuffers("/Volumes/ssdData/infiniteorchestra/convertedwav/*".standardizePath);
~planb_fs =         SoundFile.collectIntoBuffers("/Volumes/ssdData/infiniteorchestra/planb/*".standardizePath);

~nowsounds = SoundFile.collectIntoBuffers("/Users/hellska/x3dLooper/20160918/*".standardizePath);