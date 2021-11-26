import {WebGLContext} from 'webgl'
import {Texture, Matrix} from 'evg'


//metadata
filter.set_name("Super WebGL Test !");
filter.set_desc("WebGL graphics generator");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides testing of gpac's WebGL bindings");

filter.set_arg({ name: "cov", desc: "perform coverage test for EVG bindings", type: GF_PROP_BOOL, def: "false"} );

let width = 600;
let height = 600;
let fps = {n:25, d:1};
let osize=0;
let cts=0;
let max_cts=100;
let pid;

let gl = new WebGLContext(width, height);

//for coverage, test FBO and RBO
let obj = gl.createFramebuffer();
if (obj) {
    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, null);
    gl.deleteFramebuffer(obj);
  }

obj = gl.createRenderbuffer();
if (obj)
    gl.deleteRenderbuffer(obj);

//cov
gl.pixelStorei(gl.UNPACK_ALIGNMENT, true);

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
pid.set_prop('PixelFormat', 'rgba');
cts=0;
filter.frame_pending=false;
print('init done !');
}

filter.update_arg = function(name, val)
{
}


filter.process = function()
{
	if (filter.frame_pending) return GF_OK;
  if (cts>max_cts) {
      pid.eos = true;
      return GF_EOS;
  }
	gl.activate(true);

	  // Draw the scene
	  drawScene(gl, programInfo, buffers);

	gl.flush();

	gl.activate(false);

	//create packet from webgl framebuffer
	let opck = pid.new_packet(gl, () => { filter.frame_pending=false; } );
	this.frame_pending = true;
	opck.cts = cts;
	cts += 1;
	opck.send();
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
uniform sampler2D txSampler;
uniform int alphaInt;
void main(void) {
  vec4 col = texture2D(txSampler, vTextureCoord);
  if (alphaInt==1) {
      col.a = 0.1;
  } else {
      col.a = 1.0;
  }
  gl_FragColor = col;
}
`;

const shaderProgram = initShaderProgram(gl, vsSource, fsSource);

const programInfo = {
    program: shaderProgram,
    attribLocations: {
      vertexPosition: gl.getAttribLocation(shaderProgram, 'aVertexPosition'),
      textureCoord: gl.getAttribLocation(shaderProgram, 'aTextureCoord'),
    },
    uniformLocations: {
      projectionMatrix: gl.getUniformLocation(shaderProgram, 'uProjectionMatrix'),
      modelViewMatrix: gl.getUniformLocation(shaderProgram, 'uModelViewMatrix'),
      txSampler: gl.getUniformLocation(shaderProgram, 'txSampler'),
      alphaInt: gl.getUniformLocation(shaderProgram, 'alphaInt'),
    },
};

 const buffers = initBuffers(gl);


function initBuffers(gl) {
  const positionBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
  const positions = [
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,
    
    -1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0, -1.0, -1.0,
    
    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0, -1.0,
    
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0, -1.0,  1.0,
    -1.0, -1.0,  1.0,
    
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0,  1.0,  1.0,
     1.0, -1.0,  1.0,
    
    -1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
    -1.0,  1.0,  1.0,
    -1.0,  1.0, -1.0
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
  gl.clearColor(cts/100, 0.4, 0.4, 1.0);
  gl.clearDepth(1.0);
  gl.enable(gl.DEPTH_TEST);
  gl.depthFunc(gl.LEQUAL);
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

  const fieldOfView = Math.PI / 4;   // in radians
  const aspect = width / height;
  const zNear = 0.1;
  const zFar = 100.0;
  const projectionMatrix = new Matrix().perspective(fieldOfView, aspect, zNear, zFar);

  const modelViewMatrix = new Matrix().translate(0.0, 0.0, -6.0).rotate(1, 1, 0, cts*Math.PI/100);

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
  //for coverage
  gl.getActiveUniform(shaderProgram, 0);
  gl.getActiveAttrib(shaderProgram, 0);
  gl.getVertexAttrib(0, gl.VERTEX_ATTRIB_ARRAY_SIZE);
  gl.getVertexAttribOffset(0, gl.VERTEX_ATTRIB_ARRAY_POINTER);
  gl.getUniform(programInfo.program, programInfo.uniformLocations.projectionMatrix);

  //set uniforms
  gl.uniformMatrix4fv(programInfo.uniformLocations.projectionMatrix, false, projectionMatrix.m);
  gl.uniformMatrix4fv( programInfo.uniformLocations.modelViewMatrix, false, modelViewMatrix.m);

  //set texture
  gl.activeTexture(gl.TEXTURE0);
  gl.bindTexture(gl.TEXTURE_2D, texture);
  gl.uniform1i(programInfo.uniformLocations.txSampler, 0);
  let alphas = [0];
  gl.uniform1iv(programInfo.uniformLocations.alphaInt, alphas);

  //bind indices and draw
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffers.indices);
  const vertexCount = 36;
  const type = gl.UNSIGNED_SHORT;
  const offset = 0;
  gl.drawElements(gl.TRIANGLES, vertexCount, type, offset);
}

const texture = loadTexture(gl);

function loadTexture(gl) {
  const texture = gl.createTexture();
  //for coverage
  gl.textureName(texture);
  gl.bindTexture(gl.TEXTURE_2D, texture);
  const level = 0;
  const internalFormat = gl.RGBA;
  const border = 0;
  const srcFormat = gl.RGBA; //ignored, overriden by texImage2D from object
  const srcType = gl.UNSIGNED_BYTE;  //ignored, overriden by texImage2D from object
  let tx = new Texture("../auxiliary_files/logo.jpg", true);
  gl.texImage2D(gl.TEXTURE_2D, level, internalFormat, srcFormat, srcType, tx);
  //for coverage
  gl.texSubImage2D(gl.TEXTURE_2D, level, 0, 0, srcFormat, srcType, tx);

  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);

  //for coverage
  gl.getTexParameter(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER);

  return texture;
}


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
  //for coverage
  print('Prog info: ' + gl.getProgramInfoLog(shaderProgram));
  gl.getShaderPrecisionFormat(gl.FRAGMENT_SHADER, gl.LOW_FLOAT);
  gl.getRenderbufferParameter(gl.RENDERBUFFER, gl.RENDERBUFFER_WIDTH);
  gl.getFramebufferAttachmentParameter(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE);
  gl.getParameter(gl.ACTIVE_TEXTURE);
  gl.getBufferParameter(gl.ARRAY_BUFFER, gl.BUFFER_SIZE);
  gl.getSupportedExtensions();
  gl.getExtension('EXT_sRGB');
  gl.isContextLost();
  gl.getContextAttributes();
  gl.getAttachedShaders(shaderProgram);
  let w = gl.drawingBufferWidth;
  let buf = new ArrayBuffer(width * height * 3);
  gl.readPixels(0, 0, width, height, gl.RGB, gl.UNSIGNED_BYTE, buf);
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
  //for coverage
  print('Shader info: ' + gl.getShaderInfoLog(shader));
  print('Shader source: ' + gl.getShaderSource(shader));
  return shader;
}

