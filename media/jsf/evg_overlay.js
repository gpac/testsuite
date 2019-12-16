import * as evg from 'evg'

filter.pids = [];

//metadata
filter.set_name("EVGGen");
filter.set_desc("JS-based vector graphics generator");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides testing of gpac's vector graphics bindings");

let width = 320;
let height = 240;
let pfmt='';

let cts=0;
let max_cts=100;
let opid = null;
let ipid = null;

let tx = null;

/*create a path containing one centered ellipses*/
let path = new evg.Path();
path.ellipse(0, 0, 600, 400);
/*get the strike (line) outline path for this path*/
let dashes=[];
let strikepath = path.outline({width: 5.0, align: GF_PATH_LINE_OUTSIDE, join: GF_LINE_JOIN_BEVEL, dash: GF_DASH_STYLE_DASH_DASH_DOT, dashes: [0.5, 2.5, 1.0, 5.0] });

let brush = new evg.SolidBrush();

/*create a text*/
let text = new evg.Text();
text.font = 'Times';
text.fontsize = 20;
text.baseline = GF_TEXT_BASELINE_HANGING;
text.align=GF_TEXT_ALIGN_CENTER;
text.lineSpacing=0;
//text.italic=true;
text.set_text(['My awsome text', 'Powered by GPAC 1.0']);

let centered=true;
/*matrix used to animate the ellipse*/
let mx = new evg.Matrix2D();
mx.translate(0, -200);

/*get a matrix for the text*/
let mxtxt = new evg.Matrix2D();
mxtxt.translate(-500, 250);


filter.initialize = function() {

this.set_cap({id: "StreamType", value: "Video", inout: true} );
this.set_cap({id: "CodecID", value: "raw", inout: true} );

}

filter.configure_pid = function(pid) 
{
	if (!opid)
		opid = this.new_pid();
	ipid = pid;

	opid.copy_props(ipid);

width = pid.get_prop('Width');
height = pid.get_prop('Height');
pfmt = pid.get_prop('PixelFormat');

this.canvas=null;
}

filter.update_arg = function(name, val)
{
}


filter.process = function()
{
	if (max_cts && (cts>max_cts)) {
		ipid.discard = true;
		opid.eos = true;
		return GF_EOS;
	}


  let ipck = ipid.get_packet();
  if (!ipck) {
    if (ipid.eos) {
      opid.eos = true;
      return GF_EOS;
    }
    return GF_OK;
  }
  //create a clone of the input data, requesting inplace processing 
  let opck = opid.new_packet(ipck, false, false);

  /*create a canvas for our output data if first time, otherwise reassign internal canvas data*/
  if (!this.canvas) {
    this.canvas = new evg.Canvas(width, height, pfmt, opck.data);
	this.canvas.centered = centered;
  } else {		
	this.canvas.reassign(opck.data);
  }
  //create a texture from input packet - if we are the only user of the packet, the destination packet buffer will be the source packet buffer
  //in other words we will texture the shape with the canvas itself
  tx = new evg.Texture(ipck);

  draw_scene(this.canvas);

  /*send packet*/
  opck.send();
  ipid.drop_packet();
  cts++;
  return GF_OK;
}

function draw_scene(canvas)
{
	//animate ellipse matrix
	mx.rotate(0, -200, 0.1);

	//solid paint of the outline 
	canvas.matrix = mx;
	brush.set_color('green');
	canvas.path = strikepath;
	canvas.fill(brush);

	/*draw text*/
	canvas.matrix = mxtxt;
	canvas.path = text;
	brush.set_color('red');
	canvas.fill(brush);	

	//assign path, clipper and matrix
	canvas.path = path;
	canvas.clipper = null;
	canvas.matrix = mx;

	//compute object matrix to scale the texture to the object bounds and translate it in the middle of the object bounds (in object local coor system)
	let mmx = new evg.Matrix2D();
	mmx.scale(600/tx.width, 400/tx.height);
	mmx.translate(300, 200);
	//and apply the same transfor as the object
	mmx.add(mx);
	tx.mx = mmx;
	canvas.fill(tx);

}

