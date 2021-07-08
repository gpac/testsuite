import * as evg from 'evg'


//metadata
filter.set_name("Sof3DTest");
filter.set_desc("Software 3D graphics generator");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides testing of gpac's 3D software rasterizer bindings");
filter.set_arg({name: "pfmt", desc: "output pixel format", type: GF_PROP_PIXFMT, def: "rgb"} );

let width = 300;
let height = 300;
let fps = {n:25, d:1};
let osize=0;
let cts=0;
let max_cts=100;
let pid;
let frag_shader=null;
let vert_shader=null;
let matrix = new evg.Matrix();
let normal_matrix = new evg.Matrix();

let txt_shader=null;

filter.initialize = function() {

  this.set_cap({id: "StreamType", value: "Video", output: true} );
  this.set_cap({id: "CodecID", value: "raw", ouput: true} );

  pid = this.new_pid();
  pid.set_prop('StreamType', 'Visual');
  pid.set_prop('CodecID', 'raw');
  pid.set_prop('Width', width);
  pid.set_prop('Height', height);
  pid.set_prop('FPS', fps);
  pid.set_prop('Timescale', fps.n);
  pid.set_prop('PixelFormat', filter.pfmt);
  osize = evg.PixelSize(filter.pfmt);
  osize *= width*height;
  this.canvas=null;
}

const cube_vertices = new Float32Array( [
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,
    
    -1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0, -1.0, -1.0,
  ] );

const cube_indices = new Int32Array([
    // front
    0, 1, 2,
    2, 3, 0,
    // right
    1, 7, 6,
    6, 2, 1,
    // back
    7, 4, 5,
    5, 6, 7,
    // left
    4, 0, 3,
    3, 5, 4,
    // bottom
    4, 7, 1,
    1, 0, 4,
    // top
    3, 2, 6,
    6, 5, 3
  ]);

filter.process = function()
{

  if (cts) {
    return GF_EOS;
  }
  let pck = pid.new_packet(osize);

  /*create a canvas for our output data if first time, otherwise reassign internal canvas data*/
  if (!this.canvas) {
    this.canvas = new evg.Canvas(width, height, filter.pfmt, pck.data);
    this.canvas.enable_3d();
    this.canvas.depth_buffer = new ArrayBuffer(width * height * 4);
    setup_shader();
  } else {    
    this.canvas.reassign(pck.data);
  }

  draw_scene();
  
  /*set packet properties and send it*/
  pck.cts = cts;
  pck.sap = GF_FILTER_SAP_1;
  pck.send();
  cts ++;

  pid.eos = true;
  return GF_EOS;
}

function draw_scene()
{
  let canvas = filter.canvas;

  canvas.clearf('blue');
  canvas.viewport(0, 0, width, height);
  canvas.antialias = true;
  canvas.clip_zero = true;
  canvas.depth_test = GF_EVGDEPTH_LESS;
  canvas.clear_depth(1.0);

  const fieldOfView = Math.PI / 4;   // in radians
  const aspect = width / height;
  const zNear = 1;
  const zFar = 120;

  const projectionMatrix = new evg.Matrix().perspective(fieldOfView, aspect, zNear, zFar);
  const modelViewMatrix = new evg.Matrix().translate(0.0, 0.0, -10.0).rotate(1, 1, 0, Math.PI/4);

  if (!vert_shader) {
    canvas.projection(projectionMatrix.m);
    canvas.modelview(modelViewMatrix.m);
  } else {
    matrix.copy(projectionMatrix);
    matrix.add(modelViewMatrix, true);

    normal_matrix.copy(modelViewMatrix);
    let m = normal_matrix.m;
    m[12] = m[13] = m[14] = 0.0;
    normal_matrix.m = m;
    normal_matrix.inverse();
    normal_matrix.transpose();

//    vert_shader.update();
    canvas.vertex = vert_shader;
  }

  canvas.backcull=true;

  frag_shader.update();
  canvas.fragment = frag_shader;

  canvas.draw_array(cube_indices, cube_vertices, GF_EVG_TRIANGLES);
}

function setup_shader()
{
  vert_shader=filter.canvas.new_shader(GF_EVG_SHADER_VERTEX);
  vert_shader.push('vertex', '*=', matrix);
  vert_shader.push('vertexOut', '=', 'vertex');

  frag_shader=filter.canvas.new_shader(GF_EVG_SHADER_FRAGMENT);

  frag_shader.alpha = 1;

  frag_shader.push('color', '=', [1.0, 0.0, 0.0, 1.0]);
  frag_shader.push('color.a', '=', '.alpha');
  frag_shader.push('fragColor', '=', 'color');
}


