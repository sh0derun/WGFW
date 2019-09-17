class Animation {
    constructor(gl, shader) {
        this.start = 0.0;
        this.fps = 0;
        this.fpstime = 0.0;
        this.gl = gl;
        this.shader = shader;

        this.guiData = {speed: 0.1};
        this.guiControls = new dat.GUI({name:'Animation Data'});
        this.guiControls.add(this.guiData, 'speed', 0.0, 5.0, 0.01).onChange(this.onChangeValue.bind(this));
    }

    onChangeValue(){
        console.log(this);
    }

    initRenderingLoop() {
        window.requestAnimFrame = (function() {
            return window.requestAnimationFrame ||
                window.webkitRequestAnimationFrame ||
                window.mozRequestAnimationFrame ||
                window.oRequestAnimationFrame ||
                window.msRequestAnimationFrame ||
                function(callback, element) {
                    return window.setTimeout(callback, 1000 / 60);
                };
        })();

        window.cancelRequestAnimFrame = (function() {
            return window.cancelCancelRequestAnimationFrame ||
                window.webkitCancelRequestAnimationFrame ||
                window.mozCancelRequestAnimationFrame ||
                window.oCancelRequestAnimationFrame ||
                window.msCancelRequestAnimationFrame ||
                window.clearTimeout;
        })();
    }

    render() {
        var elapsedtime = (Date.now() - this.start) / 1000.0;
        var framespeed = 1.0;
        this.shader.uniforms.time.value += 0.01;
        this.gl.uniform1f(this.shader.uniforms.time.location, this.shader.uniforms.time.value);

        console.log(this.guiData.speed);

        var lerpFactor = 0.3;
        this.shader.uniforms.speed.value = (1 - lerpFactor) * this.shader.uniforms.speed.value + lerpFactor * this.guiData.speed;
        this.gl.uniform1f(this.shader.uniforms.speed.location, this.shader.uniforms.speed.value);

        this.gl.drawArrays(this.gl.TRIANGLES, 0, 6);

        this.fps++;
        this.fpstime += elapsedtime;
        if (this.fpstime >= 1.0) {
            this.fpstime -= 1.0;
            this.fps = 0;
        }

        this.start = Date.now();

        window.requestAnimationFrame(this.render.bind(this));
    }
}