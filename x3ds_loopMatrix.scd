(
~x3d_loops_matrix_creator = {|parent,xpos,ypos|
	var x3d_loops_killall;
	var loops_height = 40;
	var loops_width = 40;
	var loops_gap = 5;
	var loops_cols = 5;
	var loops_rows = 5;
	var xwin = (loops_gap * (loops_cols+1)) + (loops_width * loops_cols);
	var ywin = (loops_gap * (loops_rows+1)) + (loops_height * (loops_rows+1));
	~x3d_loop_number = 25; // the maximum loop number
	~x3d_loop_buttons_array = Array.fill(~x3d_loop_number,0);
	// window - only for standalone
	if (parent == "",
		{
			~x3d_loop_viewer_win = Window("EEE Drum").setTopLeftBounds(Rect(0,0,xwin,ywin + 50)).front;
		}, {
			~x3d_loop_viewer_win = parent;
	});
	// Othe GUI elements
	~x3d_loops_view = CompositeView(~x3d_loop_viewer_win, Rect(xpos,ypos,xwin,ywin));

	~x3d_loop_number.do{|id|
		var row, col, xstart, ystart;
		col = (id%loops_cols);
		row = (id/loops_rows).asInt;
		xstart = (col * (loops_width+ loops_gap)) + loops_gap;
		ystart = (row * (loops_height+ loops_gap)) + loops_gap;
		// ("Col:"+col+"Row:"+row+"X:"+xstart+"Y:"+ystart).postln;
		~x3d_loop_buttons_array.put(id,
			Button(~x3d_loops_view,Rect(xstart,ystart,loops_width,loops_height))
			.states_([[id.asString],[id.asString,Color.black,Color.green]])
			.action_{|me|
				case
				{me.value==0} {~play_array[id].free}
			};
		);
	};
	x3d_loops_killall = Button(~x3d_loops_view, Rect(loops_gap,ywin - loops_height,xwin-(loops_gap*2),loops_height))
	.states_([[" K I L L   A L L   L O O P S "]])
	.action_{|me| ~x3d_loop_number.do{|el|
		~play_array[el].free;
		{ ~x3d_loop_buttons_array[el].value_(0) }.defer;
		};
		~play_array_element = 0;
	};
};
)
// test: Set second and third parameters respectively to the x and y position in the parent window
// ~x3d_loops_matrix_creator.value("", 10, 20);
