class WGL{
    constructor(selector){
        this.canvas = document.querySelector(selector);
        this.ctx = this.canvas.getContext("webgl2");
        if(!this.ctx){console.error("webgl context is not avaliable !"); return null;}
        this.ctx.clearColor(1.0,1.0,1.0,1.0);

        this.ctx.getExtension('OES_standard_derivatives'); 
    }

    clear(){
        this.ctx.clear(this.ctx.COLOR_BUFFER_BIT | this.ctx.DEPTH_BUFFER_BIT);
    }

    setSize(w, h){
        this.ctx.canvas.style.width = w+"px";
        this.ctx.canvas.style.height = h+"px";
        this.ctx.canvas.width = w;
        this.ctx.canvas.height = h;
        this.ctx.viewport(0,0,w,h);
    }

    setClearColor(c){
        this.ctx.clearColor(c.r,c.g,c.b,c.a);
    }

    initBuffers(positionLocation){
        var buffer = this.ctx.createBuffer();
        this.ctx.bindBuffer(this.ctx.ARRAY_BUFFER, buffer);
        this.ctx.bufferData(this.ctx.ARRAY_BUFFER, new Float32Array([
        -1.0, -1.0,
         1.0, -1.0,
        -1.0,  1.0,
        -1.0,  1.0,
         1.0, -1.0,
         1.0,  1.0]), this.ctx.STATIC_DRAW);
        this.ctx.enableVertexAttribArray(positionLocation);
        this.ctx.vertexAttribPointer(positionLocation, 2, this.ctx.FLOAT, false, 0, 0);
    }

}

