import * as evg from 'evg'


//metadata
filter.set_name("Sof3DTest");
filter.set_desc("Software 3D graphics overlay");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides testing of gpac's 3D software rasterizer bindings");

let width = 600;
let height = 600;
let pfmt = '';
let fps = {n:25, d:1};
let osize=0;
let cts=0;
let max_cts=100;

let frag_shader=null;
let vert_shader=null;
let matrix = new evg.Matrix();
let normal_matrix = new evg.Matrix();

let logo = new evg.Texture("../auxiliary_files/logo.png", true);
//texture.filtering = GF_TEXTURE_FILTER_HIGH_SPEED;
logo.repeat_s=true;
logo.repeat_t=true;
logo.flip_v=true;
let logo_yuv = null;

let vid_texture = null;

/*create a text*/
let text = new evg.Text();
text.font = 'Times';
text.fontsize = 0.75;
text.baseline = GF_TEXT_BASELINE_HANGING;
text.align=GF_TEXT_ALIGN_RIGHT;
text.lineSpacing=0;
text.italic=true;
text.set_text(['My awsome text']);

let txt_shader=null;

filter.initialize = function() {
 this.set_cap({id: "StreamType", value: "Video", inout: true} );
 this.set_cap({id: "CodecID", value: "raw", inout: true} );
 this.ipid=null;
}

filter.configure_pid = function(pid) {
 if (!this.ipid) {
  this.ipid = pid;
  this.opid = this.new_pid();
 }
 this.opid.copy_props(pid);
 this.canvas=null;
 width = pid.get_prop('Width');
 height = pid.get_prop('Height');
 pfmt = pid.get_prop('PixelFormat');
 vid_texture = null;
}



filter.process = function()
{
  if (max_cts && (cts>max_cts)) {
      this.opid.eos = true;
      return GF_EOS;    
  }
  let ipck = this.ipid.get_packet();
  if (!ipck) {
    if (this.ipid.eos) {
      this.opid.eos = true;
      return GF_EOS;
    }
    return GF_OK;
  }
  //create a clone of the input data
  let opck = this.opid.new_packet(ipck, false, false);

  /*create a canvas for our output data if first time, otherwise reassign internal canvas data*/
  if (!this.canvas) {
    this.canvas = new evg.Canvas3D(width, height, pfmt, opck.data);
    this.canvas.depth_buffer = new ArrayBuffer(width * height * 4);
    //create a texture from our source data
    vid_texture = new evg.Texture(ipck);
    vid_texture.filtering = GF_TEXTURE_FILTER_HIGH_SPEED;
    vid_texture.repeat_s=true;
    vid_texture.repeat_t=true;
    //convert logo to YUV
    logo_yuv = logo.rgb2yuv(this.canvas);
    logo_yuv.repeat_s=true;
    logo_yuv.repeat_t=true;
    logo_yuv.flip_v=true;
    //setup fragment shader
    setup_shader();
  } else {
    //reassign color buffer of rasterizer
    this.canvas.reassign(opck.data);
    //reassign texture buffer
    vid_texture.update(ipck);
  }

  draw_scene();

  /*send packet*/
  opck.send();
  this.ipid.drop_packet();
  cts++;
  return GF_OK;

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

const face_indices = new Int32Array([
    0, 1, 2,
    2, 3, 0,
  ]);

const cube_txcoords = new Float32Array( [
    // front tx coords
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,

    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,
    // right tx coords
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,

    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,
    //back
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,

    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,
    //left
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,

    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,
    //bottom
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,

    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,
    //top
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,

    1.0, 1.0,
    0.0, 1.0,
    0.0, 0.0,
]);


function draw_scene()
{
  let canvas = filter.canvas;

  canvas.viewport(0, 0, width, height);
  canvas.antialias = true;
  canvas.backcull=true;
  canvas.depth_test = GF_EVGDEPTH_LESS;
  canvas.clear_depth(1.0);

  const fieldOfView = Math.PI / 4;   // in radians
  const aspect = width / height;
  const zNear = 1;
  const zFar = 50;

  const projectionMatrix = new evg.Matrix().perspective(fieldOfView, aspect, zNear, zFar);
  const modelViewMatrix = new evg.Matrix().translate(2.0, 1.0, -20.0).rotate(1, 1, 1, cts*Math.PI/50);

  canvas.projection(projectionMatrix.m);
  canvas.modelview(modelViewMatrix.m);

  frag_shader.label1 = (cts>50) ? 4 : 3;
  frag_shader.update();
  canvas.fragment = frag_shader;

  canvas.draw_array(cube_indices, cube_vertices, GF_EVG_TRIANGLES);
}

function setup_shader()
{
  let txi = new evg.VertexAttribInterpolator(cube_txcoords, 2, GF_EVG_VAI_VERTEX);
  frag_shader=filter.canvas.new_shader(GF_EVG_SHADER_FRAGMENT);

  frag_shader.push('txc', '=', txi);
  frag_shader.push('goto', '.label1');
  frag_shader.push('txc', '*=', 2);
  frag_shader.label1 = frag_shader.push('txval', 'samplerYUV', vid_texture, 'txc');
  //logo_yuv is YUV but stored in an RGBA texture, use regular sampler
  frag_shader.push('optx', 'sampler', logo_yuv, 'txc');
  
  frag_shader.push('if', 'optx.a', '<', 0.5);
  frag_shader.push('txval.a', '=', 1.0);
  frag_shader.push('else');
  frag_shader.push('txval', '=', 'optx');
  frag_shader.push('end');

  frag_shader.push('fragYUVA', '=', 'txval');
}


