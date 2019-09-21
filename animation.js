class Animation {
    constructor(gl, shader, canvas) {
        this.start = 0.0;
        this.fps = 0;
        this.fpstime = 0.0;
        this.gl = gl;
        this.shader = shader;
        this.canvas = canvas;

        this.guiData = {speed: 0.1, fogAmount: 0.016, pause: false, save:this.saveCanvasFile.bind(this)};
        this.guiControls = new dat.GUI({name:'Animation Data'});
        this.guiControls.add(this.guiData, 'speed', 0.0, 5.0, 0.01).onChange(this.onChangeValue.bind(this));
        this.guiControls.add(this.guiData, 'fogAmount', 0.0, 20.0, 0.0001).onChange(this.onChangeValue.bind(this));
        this.guiControls.add(this.guiData, 'pause').onChange(this.onChangePauseFlag.bind(this));
        this.guiControls.add(this.guiData, 'save');
    }

    onChangePauseFlag(){
        if(!this.guiData.pause){
            this.render();
        }
    }

    onChangeValue(){
        
    }

    saveCanvasFile(){
        var img_b64 = this.canvas.toDataURL('image/png');
        var png = img_b64.split(',')[1];

        var the_file = new Blob([window.atob(png)],  {type: 'image/png', encoding: 'utf-8'});

        var fr = new FileReader();
        fr.onload = function ( oFREvent ) {
            var v = oFREvent.target.result.split(',')[1];
            v = atob(v);
            var good_b64 = btoa(decodeURIComponent(escape(v)));
            console.log("data:image/png;base64," + good_b64);
        };
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
        if(!this.guiData.pause){
            var elapsedtime = (Date.now() - this.start) / 1000.0;
            var framespeed = 1.0;
            this.shader.uniforms.time.value += 0.01;
            this.gl.uniform1f(this.shader.uniforms.time.location, this.shader.uniforms.time.value);

            var lerpFactor = 0.03;
            this.shader.uniforms.speed.value = (1 - lerpFactor) * this.shader.uniforms.speed.value + lerpFactor * this.guiData.speed;
            this.gl.uniform1f(this.shader.uniforms.speed.location, this.shader.uniforms.speed.value);

            var lerpFactorF = 0.05;
            this.shader.uniforms.fogAmount.value = (1 - lerpFactorF) * this.shader.uniforms.fogAmount.value + lerpFactorF * this.guiData.fogAmount;
            this.gl.uniform1f(this.shader.uniforms.fogAmount.location, this.shader.uniforms.fogAmount.value);

            this.gl.drawArrays(this.gl.TRIANGLES, 0, 6);

            this.fps++;
            this.fpstime += elapsedtime;
            if (this.fpstime >= 1.0) {
                this.fpstime -= 1.0;
                this.fps = 0;
            }

            this.start = Date.now();

            /*
            var img_b64 = this.canvas.toDataURL('image/png');

            fetch(img_b64).then(res => res.blob()).then(blob => {
                blob.lastModifiedDate = new Date();
                blob.name = "fileName"+this.shader.uniforms.time.value;
                console.log(blob);
            });
            */

            window.requestAnimationFrame(this.render.bind(this));
        }
    }
}