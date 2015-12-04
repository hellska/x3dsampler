// Create the loop matrix GUI plus the necessary support (arrays etc...)
~x3d_loops_win_maker = {

	var loops_height = 100;
	var loops_width = 100;
	var loops_gap = 20;
	var loops_cols = 5;
	var loops_rows = 5;
	var xwin = (loops_gap * (loops_cols+1)) + (loops_width * loops_cols);
	var ywin = (loops_gap * (loops_rows+1)) + (loops_height * loops_rows);
	~x3d_loop_number = 25; // the maximum loop number
	~x3d_loop_buttons_array = Array.fill(~x3d_loop_number,0);
	// GUI Elements
	~x3d_loop_viewer_win = Window("EEE Drum").setTopLeftBounds(Rect(0,0,xwin,ywin + 50)).front;
	~x3d_loops_view = CompositeView(~x3d_loop_viewer_win, Rect(10,10,xwin,ywin));

	~x3d_loop_number.do{|id|
		var row, col, xstart, ystart;
		col = (id%loops_cols);
		row = (id/loops_rows).asInt;
		xstart = (col * (loops_width+ loops_gap)) + loops_gap;
		ystart = (row * (loops_height+ loops_gap)) + loops_gap;
		("Col:"+col+"Row:"+row+"X:"+xstart+"Y:"+ystart).postln;
		~x3d_loop_buttons_array.put(id,
			Button(~x3d_loops_view,Rect(xstart,ystart,loops_width,loops_height))
			.states_([[id.asString],[id.asString,Color.black,Color.green]])
			.action_{|me|
				case
				{me.value==0} {~play_array[id].free}
			};
		);
	};

	~x3d_loops_killall = Button(~x3d_loop_viewer_win, Rect(10,ywin + 10,xwin - 20,30))
	.states_([[" K I L L   A L L   L O O P S "]])
	.action_{|me| ~play_array_element.do{|el|
		~play_array[el].free;
		{ ~x3d_loop_buttons_array[el].value_(0) }.defer;
		};
		~play_array_element = 0;
	};
};