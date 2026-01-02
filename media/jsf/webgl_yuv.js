import {WebGLContext} from 'webgl'
import {Texture, Matrix} from 'evg'


//metadata
filter.set_name("WebGL_YUV");
filter.set_desc("WebGL graphics generator");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides testing of gpac's WebGL bindings");

//raw video in and out
filter.set_cap({id: "StreamType", value: "Video", inout: true} );
filter.set_cap({id: "CodecID", value: "raw", inout: true} );

filter.set_arg({ name: "depth", desc: "output depth rather than color", type: GF_PROP_BOOL, def: "false"} );

let use_primary = false;
let width=600;
let height=400;
let ipid=null;
let opid=null;
let nb_frames=0;
let pix_fmt = '';
let programInfo = null;

let gl = null;
let pck_tx = null;
let img_tx = null;
let buffers = null;

filter.initialize = function() {

  gl = new WebGLContext(width, height, {depth: filter.depth ? "texture" : true, primary: use_primary});
  pck_tx = gl.createTexture('vidTx');
  img_tx = gl.createTexture('imgTx');
  img_tx.upload(new Texture("../auxiliary_files/logo.png", true));
  pck_tx.pbo = false;
  buffers = initBuffers(gl);
}

filter.configure_pid = function(pid) {

  if (!opid) {
    opid = this.new_pid();
  }
  ipid = pid;
  opid.copy_props(pid);
  opid.set_prop('PixelFormat', 'rgba');
  opid.set_prop('Stride', null);
  opid.set_prop('StrideUV', null);
  let n_width = pid.get_prop('Width');
  let n_height = pid.get_prop('Height');
  let pf = pid.get_prop('PixelFormat');
  if ((n_width != width) || (n_height != height)) {
    width = n_width;
    height = n_height;
    gl.resize(width, height);
  }
  if (pf != pix_fmt) {
    pix_fmt = pf;
    programInfo = null;
    pck_tx.reconfigure();
  }
  print(`pid and WebGL configured: ${width}x${height} source format ${pf}`);
}

filter.update_arg = function(name, val)
{
}


filter.process = function()
{
  let ipck = ipid.get_packet();
  if (!ipck) return GF_OK;
  if (filter.frame_pending) {
//    print('frame pending, waiting');
    return GF_OK;
  }
  gl.activate(true);

//  pck_tx.upload(ipck);
  gl.bindTexture(gl.TEXTURE_2D, pck_tx);
  gl.texImage2D(gl.TEXTURE_2D, 0, 0, 0, 0, ipck);

  if (!programInfo) programInfo = setupProgram(gl, vsSource, fsSource);

  // Draw the scene
  drawScene(gl, programInfo, buffers);
	gl.flush();
	gl.activate(false);

	//create packet from webgl framebuffer
	let opck = opid.new_packet(gl, () => { filter.frame_pending=false; }, filter.depth );
	this.frame_pending = true;
  opck.copy_props(ipck);

  ipid.drop_packet();
	opck.send();
  nb_frames++;
	return GF_OK;
}


/*inspired from MDN samples
https://github.com/mdn/webgl-examples/tree/gh-pages/tutorial
*/

const vsSource = `
attribute vec4 aVertexPosition;
attribute vec2 aTextureCoord;
uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;
varying vec2 vTextureCoord;
void main() {
  gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
  vTextureCoord = aTextureCoord;
}
`;


const fsSource = `
varying vec2 vTextureCoord;
uniform sampler2D vidTx;
uniform sampler2D imgTx;
void main(void) {
  vec2 tx= vTextureCoord;
  tx.y = 1.0 - tx.y;
  vec4 vid = texture2D(vidTx, tx);
  vec4 img = texture2D(imgTx, tx);
  vid.a = img.a;
  gl_FragColor = vid;
}
`;


function setupProgram(gl, vsSource, fsSource)
{
  const shaderProgram = initShaderProgram(gl, vsSource, fsSource);
  return {
    program: shaderProgram,
    attribLocations: {
      vertexPosition: gl.getAttribLocation(shaderProgram, 'aVertexPosition'),
      textureCoord: gl.getAttribLocation(shaderProgram, 'aTextureCoord'),
    },
    uniformLocations: {
      projectionMatrix: gl.getUniformLocation(shaderProgram, 'uProjectionMatrix'),
      modelViewMatrix: gl.getUniformLocation(shaderProgram, 'uModelViewMatrix'),
      txVid: gl.getUniformLocation(shaderProgram, 'vidTx'),
    },
  };
}



function initBuffers(gl) {
  const positionBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
  
  const positions = [
    // Front face
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,

    // Back face
    -1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0, -1.0, -1.0,

    // Top face
    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0, -1.0,

    // Bottom face
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0, -1.0,  1.0,
    -1.0, -1.0,  1.0,

    // Right face
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0,  1.0,  1.0,
     1.0, -1.0,  1.0,

    // Left face
    -1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
    -1.0,  1.0,  1.0,
    -1.0,  1.0, -1.0,
  ];


  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

  const indexBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
  const indices = [
    0,  1,  2,      0,  2,  3,
    4,  5,  6,      4,  6,  7,
    8,  9,  10,     8,  10, 11,
    12, 13, 14,     12, 14, 15,
    16, 17, 18,     16, 18, 19,
    20, 21, 22,     20, 22, 23,
  ];
  gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indices), gl.STATIC_DRAW);

  const textureCoordBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, textureCoordBuffer);
  const textureCoordinates = [
    // Front
    0.0,  0.0,
    1.0,  0.0,
    1.0,  1.0,
    0.0,  1.0,
    // Back
    0.0,  0.0,
    1.0,  0.0,
    1.0,  1.0,
    0.0,  1.0,
    // Top
    0.0,  0.0,
    1.0,  0.0,
    1.0,  1.0,
    0.0,  1.0,
    // Bottom
    0.0,  0.0,
    1.0,  0.0,
    1.0,  1.0,
    0.0,  1.0,
    // Right
    0.0,  0.0,
    1.0,  0.0,
    1.0,  1.0,
    0.0,  1.0,
    // Left
    0.0,  0.0,
    1.0,  0.0,
    1.0,  1.0,
    0.0,  1.0,
  ];
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(textureCoordinates), gl.STATIC_DRAW);

  return {
    position: positionBuffer,
    indices: indexBuffer,
    textureCoord: textureCoordBuffer,
  };
}


function drawScene(gl, programInfo, buffers) {
  gl.viewport(0, 0, width, height);
  gl.clearColor(0.8, 0.4, 0.8, 1.0);
  gl.clearDepth(1.0);
  gl.enable(gl.DEPTH_TEST);
  gl.enable(gl.BLEND);
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
  gl.depthFunc(gl.LEQUAL);
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

  const fieldOfView = Math.PI / 4;   // in radians
  const aspect = width / height;
  const zNear = 0.1;
  const zFar = 100.0;
  const projectionMatrix = new Matrix().perspective(fieldOfView, aspect, zNear, zFar);

  const modelViewMatrix = new Matrix().translate(-0.0, 0.0, -6.0).rotate(0, 1, 0, nb_frames*Math.PI/100);

  //bind vertex position
  {
    const numComponents = 3;
    const type = gl.FLOAT;
    const normalize = false;
    const stride = 0;
    const offset = 0;
    gl.bindBuffer(gl.ARRAY_BUFFER, buffers.position);
    gl.vertexAttribPointer(
        programInfo.attribLocations.vertexPosition,
        numComponents,
        type,
        normalize,
        stride,
        offset);
    gl.enableVertexAttribArray(
        programInfo.attribLocations.vertexPosition);
  }

  //bind texture coordinates
  {
    const num = 2; // chaque coordonnée est composée de 2 valeurs
    const type = gl.FLOAT; // les données dans le tampon sont des flottants 32 bits
    const normalize = false; // ne pas normaliser
    const stride = 0; // combien d'octets à récupérer entre un jeu et le suivant
    const offset = 0; // à combien d'octets du début faut-il commencer
    gl.bindBuffer(gl.ARRAY_BUFFER, buffers.textureCoord);
    gl.vertexAttribPointer(programInfo.attribLocations.textureCoord, num, type, normalize, stride, offset);
    gl.enableVertexAttribArray(programInfo.attribLocations.textureCoord);
  }

  gl.useProgram(programInfo.program);

  //set uniforms
  gl.uniformMatrix4fv(programInfo.uniformLocations.projectionMatrix, false, projectionMatrix.m);
  gl.uniformMatrix4fv( programInfo.uniformLocations.modelViewMatrix, false, modelViewMatrix.m);

  //set image
/*  gl.activeTexture(gl.TEXTURE0);
  gl.bindTexture(gl.TEXTURE_2D, texture);
  gl.uniform1i(programInfo.uniformLocations.txLogo, 0);
*/

  //set video texture
  gl.activeTexture(gl.TEXTURE0);
  gl.bindTexture(gl.TEXTURE_2D, pck_tx);
  //this one is ignored for gpac named textures, just kept to make sure we don't break usual webGL programming 
  gl.uniform1i(programInfo.uniformLocations.txVid, 0);

  //set image texture
  gl.activeTexture(gl.TEXTURE0+pck_tx.nb_textures);
  gl.bindTexture(gl.TEXTURE_2D, img_tx);

  //bind indices and draw
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffers.indices);
  const vertexCount = 36;
  const type = gl.UNSIGNED_SHORT;
  const offset = 0;
  gl.drawElements(gl.TRIANGLES, vertexCount, type, offset);
}

function loadTexture(gl) {
  const texture = gl.createTexture();
  gl.bindTexture(gl.TEXTURE_2D, texture);
  const level = 0;
  const internalFormat = gl.RGBA;
  const srcFormat = gl.RGBA; //ignored, overridden by texImage2D from object
  const srcType = gl.UNSIGNED_BYTE;  //ignored, overridden by texImage2D from object
  let tx = new Texture("../auxiliary_files/logo.png", true);
  gl.texImage2D(gl.TEXTURE_2D, level, internalFormat, srcFormat, srcType, tx);

  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
  return texture;
}

//const texture = loadTexture(gl);

function initShaderProgram(gl, vsSource, fsSource) {
  const vertexShader = loadShader(gl, gl.VERTEX_SHADER, vsSource);
  const fragmentShader = loadShader(gl, gl.FRAGMENT_SHADER, fsSource);

  const shaderProgram = gl.createProgram();
  gl.attachShader(shaderProgram, vertexShader);
  gl.attachShader(shaderProgram, fragmentShader);
  gl.linkProgram(shaderProgram);

  if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
    alert('Unable to initialize the shader program: ' + gl.getProgramInfoLog(shaderProgram));
    return null;
  }
  return shaderProgram;
}

function loadShader(gl, type, source) {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    alert('An error occurred compiling the shaders ' + type + ' : ' + gl.getShaderInfoLog(shader));
    gl.deleteShader(shader);
    return null;
  }
  return shader;
}
