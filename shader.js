class Shader {

    constructor(vert, frag) {
        this.vertexShaderSource = ShaderUtil.loadShaderSource(vert);
        this.fragShaderSource = ShaderUtil.combineShader(frag);
        this.vertexShader = null;
        this.fragmentShader = null;
        this.programShader = null;
        this.uniforms = {};
        this.attributs = {};
    }

    compileShaders(gl) {
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

    initProgramShader(gl) {
        if(this.programShader === null){
            this.programShader = gl.createProgram();
        }

        gl.attachShader(this.programShader, this.vertexShader);
        gl.attachShader(this.programShader, this.fragmentShader);
        gl.linkProgram(this.programShader);

        gl.deleteShader(this.vertexShader);
        gl.deleteShader(this.fragmentShader);

        if (!gl.getProgramParameter(this.programShader, gl.LINK_STATUS)) {
            console.log("WebGL - Shader Initialization Error");
            gl.deleteProgram(this.programShader);
            return;
        }
        gl.useProgram(this.programShader);
    }

    initShaderValues(gl, canvas) {
        var shaderData = ShaderUtil.loadJSON("./shaders/shader_data/uniforms.json");

        if(shaderData.uniforms){

        }

        this.uniforms.time = {
            location: gl.getUniformLocation(this.programShader, "time"),
            value: 0.0
        };
        gl.uniform1f(this.uniforms["time"].location, this.uniforms["time"].value);

        this.uniforms.resolution = {
            location: gl.getUniformLocation(this.programShader, "resolution"),
            value: {
                x: canvas.width,
                y: canvas.height
            }
        };
        gl.uniform2f(this.uniforms["resolution"].location, this.uniforms["resolution"].value.x, this.uniforms["resolution"].value.y);

        var mx = Math.max(canvas.width, canvas.height);
        this.uniforms.screenRatio = {
            location: gl.getUniformLocation(this.programShader, "screenRatio"),
            value: {
                x: canvas.width / mx,
                y: canvas.height / mx
            }
        };
        gl.uniform2f(this.uniforms["screenRatio"].location, this.uniforms["screenRatio"].value.x, this.uniforms["screenRatio"].value.y);

        this.uniforms.speed = {
            location: gl.getUniformLocation(this.programShader, "speed"),
            value: 0.0
        };
        gl.uniform1f(this.uniforms["speed"].location, this.uniforms["speed"].value);

        this.uniforms.fogAmount = {
            location: gl.getUniformLocation(this.programShader, "fogAmount"),
            value: 0.016
        };
        gl.uniform1f(this.uniforms["fogAmount"].location, this.uniforms["fogAmount"].value);

        this.attributs.a_position = {
            location: gl.getAttribLocation(this.programShader, "a_position"),
            value: 2
        };
    }

}