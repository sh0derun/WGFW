class Shader{

	constructor(vert, frag){
		this.vertexShaderSource = this.loadShader(vert);
		this.fragShaderSource = this.loadShader(frag);
		this.vertexShader = null;
		this.fragmentShader = null;
		this.programShader = null;
	}

	loadShader(fileLocation){
        const req = new XMLHttpRequest();
        req.open('GET', fileLocation, false); 
        req.overrideMimeType('text/plain');
        req.send();

        if (req.status === 200) {
            console.log("<%s> file loading succeded !", fileLocation);
            return req.responseText;
        } else {
            console.log("<%s> file loading failed !", fileLocation);
        }
    }

    compileShaders(gl){
        this.vertexShader = gl.createShader(gl.VERTEX_SHADER);
      	gl.shaderSource(this.vertexShader, this.vertexShaderSource);
      	gl.compileShader(this.vertexShader);

      	if (!gl.getShaderParameter(this.vertexShader, gl.COMPILE_STATUS)) {
          	console.log(gl.getShaderInfoLog(this.vertexShader));
      	}

        this.fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
        gl.shaderSource(this.fragmentShader, this.fragShaderSource);
      	gl.compileShader(this.fragmentShader);

      	if (!gl.getShaderParameter(this.fragmentShader, gl.COMPILE_STATUS)) {
          	console.log(gl.getShaderInfoLog(this.fragmentShader));
      	}
    }

    initProgramShader(gl){
    	this.programShader = gl.createProgram();

	    gl.attachShader(this.programShader, this.vertexShader);
	    gl.attachShader(this.programShader, this.fragmentShader);
	    gl.linkProgram(this.programShader);
	    
	    gl.deleteShader(this.vertexShader);
	    gl.deleteShader(this.fragmentShader);
	    
	    if (!gl.getProgramParameter(this.programShader, gl.LINK_STATUS)) {
	        document.getElementById('heading').innerHTML = "WebGL - Shader Initialization Error";
	        document.getElementById('info').innerHTML = "WebGL could not initialize one, or both, shaders.";
	        gl.deleteProgram(this.programShader);
	        return;
	    }

	    gl.useProgram(this.programShader);
    }

    initShaderValues(gl,canvas){
    	this.uniforms = {};
		this.attributs = {};

		this.uniforms.time = {location:gl.getUniformLocation(this.programShader, "time"), value:0.0};
    	gl.uniform1f(this.uniforms["time"].location, this.uniforms["time"].value);
		
		this.uniforms.resolution = {location:gl.getUniformLocation(this.programShader, "resolution"),value:{x:canvas.width,y:canvas.height}};
	    gl.uniform2f(this.uniforms["resolution"].location, this.uniforms["resolution"].value.x, this.uniforms["resolution"].value.y);

	    var mx = Math.max(canvas.width, canvas.height);
	    this.uniforms.screenRatio = {location:gl.getUniformLocation(this.programShader, "screenRatio"),value:{x:canvas.width/mx,y:canvas.height/mx}};
	    gl.uniform2f(this.uniforms["screenRatio"].location, this.uniforms["screenRatio"].value.x, this.uniforms["screenRatio"].value.y);

		this.attributs.a_position = {location:gl.getAttribLocation(this.programShader, "a_position"),value:null};
    }

    setUniformsValues(gl){
    	this.uniforms = {};
    }

    setAttributsValues(gl){
    	var positionLocation = gl.getAttribLocation(this.programShader, "a_position");
		this.attributs = {};

    }

}