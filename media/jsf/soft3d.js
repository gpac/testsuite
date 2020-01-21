import * as evg from 'evg'


//metadata
filter.set_name("Sof3DTest");
filter.set_desc("Software 3D graphics generator");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides testing of gpac's 3D software rasterizer bindings");

let width = 600;
let height = 600;
let fps = {n:25, d:1};
let osize=0;
let cts=0;
let max_cts=100;
let pid;
let frag_shader=null;
let vert_shader=null;
let matrix = new evg.Matrix();
let normal_matrix = new evg.Matrix();

let texture = new evg.Texture("../auxiliary_files/logo.png", true);
texture.filtering = GF_TEXTURE_FILTER_HIGH_SPEED;
texture.repeat_s=true;
texture.repeat_t=true;
texture.flip_v=true;


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

this.set_cap({id: "StreamType", value: "Video", output: true} );
this.set_cap({id: "CodecID", value: "raw", ouput: true} );

pid = this.new_pid();
pid.set_prop('StreamType', 'Visual');
pid.set_prop('CodecID', 'raw');
pid.set_prop('Width', width);
pid.set_prop('Height', height);
pid.set_prop('FPS', fps);
pid.set_prop('Timescale', fps.n);
pid.set_prop('PixelFormat', 'rgb');
osize = 3*width*height;
this.canvas=null;
}

filter.update_arg = function(name, val)
{
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


const cube_normals_face = new Float32Array([
    // front
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    // right
    1.0, 0.0, 0.0,
    1.0, 0.0, 0.0,
    // back
    0.0, 0.0, -1.0,
    0.0, 0.0, -1.0,
    // left
    -1.0, 0.0, 0.0,
    -1.0, 0.0, 0.0,
    // bottom
    0.0, -1.0, 0.0,
    0.0, -1.0, 0.0,
    // top
    0.0, 1.0, 0.0,
    0.0, 1.0, 0.0,
  ]);



const hcube_indices = new Int32Array([
    // front
//    0, 1, 2,
//    2, 3, 0,
    // back
//    7, 5, 6,
    5, 7, 4,
    // left
    4, 0, 3,
//    3, 5, 4,
    // bottom
    4, 7, 1,
//    1, 0, 4,
  ]);

const cube_quad_indices = new Int32Array([
    0,  1,  2, 3,
//    4,  5,  6, 7,
  ]);

const points_indices = new Int32Array([
    0, 1, 2, 3, 4, 5, 6, 7
  ]);

const lines_indices = new Int32Array([
    0, 1, 2, 3, 5, 6, 7, 4, 0
  ]);

const face_indices = new Int32Array([
    0,  1,  2,      
    2,  3,  0,
  ]);

const face2_indices = new Int32Array([
    1, 7, 6,
    6, 2, 1,
  ]);

const faces_indices = new Int32Array([
    0,  1,  2,      
    0,  2,  3,

    7, 6, 5,
    5, 4, 7,
  ]);

const faces2_indices = new Int32Array([
    0,  2,  3,
    4, 0, 3,
  ]);

const faces3_indices = new Int32Array([
    0,  2,  3,
    7, 6, 5,
//    5, 4, 7,
  ]);

const tri_strip_indices = new Int32Array([
    0, 2, 3, 6 
  ]);

const tri_fan_indices = new Int32Array([
    0, 1, 2, 3 
  ]);

const tri_indices = new Int32Array([
    0,  1,  2
 ] );

const tri2_vertices = new Float32Array( [
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,

    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,

] );
const tri2_indices = new Int32Array([
    0, 1, 2,
//    2, 3, 0,
    3, 2, 6,
//    6, 5, 3,
//    1, 7, 6,
   6, 2, 1,
 ] );

const faces_colors = new Float32Array( [
   // front colors
    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0,
    1.0, 0.0, 1.0,
    // back colors
    1.0, 1.0, 1.0,
    0.0, 1.0, 1.0,
    1.0, 1.0, 0.0,
    0.0, 0.0, 0.0,


    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0,
    1.0, 0.0, 1.0,
]);



const faces_txcoords = new Float32Array( [
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


filter.process = function()
{

  if (cts >= max_cts) {
    return GF_EOS;
  }
  let pck = pid.new_packet(osize);

  /*create a canvas for our output data if first time, otherwise reassign internal canvas data*/
  if (!this.canvas) {
    this.canvas = new evg.Canvas3D(width, height, 'rgb', pck.data);
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
  if (cts == max_cts) {
    pid.eos = true;
    return GF_EOS;
  }
  return GF_OK;

}

function draw_scene()
{
  let canvas = filter.canvas;

  canvas.clearf('green');
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
  const modelViewMatrix = new evg.Matrix().translate(0.0, 0.0, -10.0).rotate(0, 1, 0, cts*Math.PI/50);

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

/*  let myci = new evg.VertexAttribInterpolator(faces_colors, 3, false);
  canvas.fragment = function(frag) {
    frag.rgb = myci.lerp(frag);
  }
*/

//  frag_shader.limit = 100 + cts*300.0/100;

  frag_shader.update();
  canvas.fragment = frag_shader;

 canvas.draw_array(cube_indices, cube_vertices, GF_EVG_TRIANGLES);

// return;

 modelViewMatrix.identity = true;
 modelViewMatrix.translate(-1.0, 0.0, -8.0).rotate(0, 1, 0, -cts*Math.PI/50);
 canvas.projection(projectionMatrix.m);
 canvas.modelview(modelViewMatrix.m);
 canvas.vertex = null;
 canvas.fragment = txt_shader;
 canvas.draw_path(text);

 return;

  for (let i=0; i<50; i++) {
  for (let j=0; j<50; j++) {
    modelViewMatrix.identity = true;
    modelViewMatrix.translate((-25+i)*3, (-25+j)*3, -50.0).rotate(0, 1, 0, cts*Math.PI/100);
//    canvas.modelview(modelViewMatrix.m);
    canvas.vertex = vert_shader;
    canvas.fragment = frag_shader;
    matrix.copy(projectionMatrix);
    matrix.add(modelViewMatrix, true);

    normal_matrix.copy(modelViewMatrix);
    let m = normal_matrix.m;
    m[12] = m[13] = m[14] = 0.0;
    normal_matrix.m = m;
    normal_matrix.inverse();
    normal_matrix.transpose();

    canvas.draw_array(cube_indices, cube_vertices);
  }
  }

/*
  const modelViewMatrix2 = new evg.Matrix().translate(1.0, 0.0, -8.0).rotate(1, 1, 0, cts*Math.PI/100);
  canvas.modelview(modelViewMatrix2.m);
  canvas.fragment = function(frag) {
    frag.g = 1.0;
  }
  canvas.draw_array(cube_indices, cube_vertices);
*/
}

function setup_shader()
{
//  let ci = new evg.VertexAttribInterpolator(faces_colors, 3);
//  let txi = new evg.VertexAttribInterpolator(faces_txcoords, 2, GF_EVG_VAI_VERTEX);
  let gfEye = new evg.VertexAttribInterpolator(3);

  let ni = new evg.VertexAttribInterpolator(3);
  ni.normalize=true;
  let normals = new evg.VertexAttrib(cube_normals_face, 3, GF_EVG_VAI_PRIMITIVE);
  normals.normalize = true;

  vert_shader=filter.canvas.new_shader(GF_EVG_SHADER_VERTEX);
  vert_shader.push('normal', '=', normals);
  vert_shader.push('normal', '*=', normal_matrix);
  vert_shader.push(ni, '=', 'normal');
  vert_shader.push('vertex', '*=', matrix);
  vert_shader.push('vertexOut', '=', 'vertex');
  //for coverage
  vert_shader.push('dummy', 'inversesqrt', [3, 2, 3]);
  vert_shader.push('dummy', 'sign', [-1, 1, 2]);
  vert_shader.push('dummy', 'fract', [-1.5, 1.1, 2.9]);
  vert_shader.push('modul', '=', [3,3,3]);
  vert_shader.push('dummy', 'mod', [-1.5, 1.1, 2.9], 'modul');
  //end coverage
  vert_shader.push(gfEye, '=', 'vertex');


  frag_shader=filter.canvas.new_shader(GF_EVG_SHADER_FRAGMENT);

  frag_shader.limit = 300.0;
  frag_shader.light_dir = [0, -1, -1];
  frag_shader.matEmissive = [0.2, 0.2, 0.2, 1];
  frag_shader.matAmbiant = [1, 1, 1, 1];
  frag_shader.matDiffuse = [1, 1, 1, 1];
  frag_shader.matSpecular = [1, 0, 0, 1];
  frag_shader.matShininess = 1;
  frag_shader.lightDiffuse = [0, 0, 1, 1];
  frag_shader.lightSpecular = [1, 1, 1, 1];

/*  frag_shader.push('someval', '=', ci);

  frag_shader.push('if', 'fragX', '>', '.limit');
  frag_shader.push(' if', 'fragY', '>', '.limit');
  frag_shader.push('  txval', 'sampler', texture, txi);
  frag_shader.push('  someval.a', '=', 'txval.a');
  frag_shader.push(' else');
  frag_shader.push('  someval.rgb', '=', 1);
  frag_shader.push(' end');
  frag_shader.push('else');
  frag_shader.push(' if', 'fragY', '>', '.limit');
  frag_shader.push('  someval.rgb', '*=', 0.5);
  frag_shader.push(' else');
  frag_shader.push('someval', 'sampler', texture, txi);
//  frag_shader.push('  someval.rgb', '=', 0.5);
  frag_shader.push(' end');
  frag_shader.push('end');
*/
/*
  frag_shader.push('if', 'fragX', '!=', 'fragY');
  frag_shader.push(' someval.rgb', '*=', 0.5);
  frag_shader.push('end');
*/
//  frag_shader.push('someval', '=', 'fragDepth');

//  frag_shader.push('txc', '=', txi);
//  frag_shader.push('txc.x', '*=', 0.5);
/*
  frag_shader.push('someval', 'sampler', texture, txi);
  frag_shader.push('if', 'someval.a', '==', 0.0);
  frag_shader.push('someval.a', '=', 1);
  frag_shader.push('someval.rgb', '=', 0.2);
  frag_shader.push('end');
  frag_shader.push('fragColor', '=', 'someval');
*/


  frag_shader.push('lightVnorm', 'normalize', '.light_dir');
  frag_shader.push('halfVnorm', '=', 'lightVnorm');
  frag_shader.push('halfVnorm', '+=', gfEye);
  frag_shader.push('halfVnorm', 'normalize', 'halfVnorm');
  frag_shader.push('normal', '=', ni);
  frag_shader.push('light_cos', 'dot', 'normal', 'lightVnorm');
  frag_shader.push('half_cos', 'dot', 'normal', 'halfVnorm');

  frag_shader.push('lightColor', '=', '.matDiffuse');
  frag_shader.push('lightColor', '*=', '.lightDiffuse');
  frag_shader.push('lightColor', '*=', 'light_cos');

  frag_shader.push('if', 'half_cos', '>', 0);
  frag_shader.push('col', '=', '.matSpecular');
  frag_shader.push('col', '*=', '.lightSpecular');
  frag_shader.push('shine', '=', '.matShininess');
  frag_shader.push('coef', 'pow', 'half_cos', 'shine');
  frag_shader.push('col', '*=', 'coef');
  frag_shader.push('lightColor', '+=', 'col');
  frag_shader.push('end');


  frag_shader.push('lightColor.a', '=', '.matDiffuse.a');
  frag_shader.push('lightColor', '+=', '.matEmissive');
  //for coverage, test clamp
  frag_shader.push('max', '=', [1.0,1.0,1.0,1.0]);
  frag_shader.push('lightColor', 'clamp', [0.0,0.0,0.0,1.0], 'max');
  frag_shader.push('fragColor', '=', 'lightColor');


//  frag_shader.push('fragColor', '=', 'fragDepth');
//  frag_shader.push('fragColor.a', '=', 1.0);
//  frag_shader.push('fragColor', '=', ci);


  txt_shader = filter.canvas.new_shader(GF_EVG_SHADER_FRAGMENT);
  txt_shader.push('interp', '=', 'fragX');
  txt_shader.push('interp', '/=', 600);
  txt_shader.push('fragColor.r', '=', 'interp');
  txt_shader.push('fragColor.gb', '=', 0.0);
  txt_shader.push('fragColor.a', '=', 1.0);
//  txt_shader.push('someval', 'sampler', texture, txi);
//  txt_shader.push('someval.a', '=', 1);
//  txt_shader.push('fragColor', '=', 'someval');
}


