class Animation {
    constructor(gl,shader) {
        this.start = 0.0;
        this.fps = 0;
        this.fpstime = 0.0;
        this.gl = gl;
        this.shader = shader;
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
        this.shader.uniforms.time.value += framespeed * elapsedtime;
        this.gl.uniform1f(this.shader.uniforms.time.location, this.shader.uniforms.time.value);

        //gl.clearColor(1.0, 0.0, 0.0, 1.0)
        this.gl.drawArrays(this.gl.TRIANGLES, 0, 6);

        this.fps++;
        this.fpstime += elapsedtime;
        if (this.fpstime >= 1.0) {
            this.fpstime -= 1.0;
            this.fps = 0;
        }

        this.start = Date.now();

        window.requestAnimationFrame(this.render);
    }
}