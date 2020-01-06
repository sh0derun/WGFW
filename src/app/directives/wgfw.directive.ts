import { WGFWAnimator } from '../WGFWAnimator';
import { Shader } from './../Shader';
import { Directive, ElementRef, Input, OnInit } from '@angular/core';

@Directive({
    selector: '[wgfw]'
})
export class WgfwDirective implements OnInit {

    @Input() w: number;
    @Input() h: number;
    @Input() fullScreen: boolean;
    @Input() vertexShaderLocation: string;
    @Input() fragmentShaderLocation: string;

    el: ElementRef;
    canvasContext: WebGL2RenderingContext;
    shader: Shader;
    animator: WGFWAnimator;

    ngOnInit() {
        this.initWebglContext(this.el);
        this.shader = new Shader(this.vertexShaderLocation, this.fragmentShaderLocation);
        this.shader.compileShaders(this.canvasContext);
        this.shader.initProgramShader(this.canvasContext);
        this.shader.initShaderValues(this.canvasContext, this.el.nativeElement);
        this.initBuffers(this.shader.attributs.a_position.location);

        this.animator = new WGFWAnimator(this.canvasContext, this.shader, this.el.nativeElement);
        this.animator.initRenderingLoop();
        this.animator.render();
    }

    constructor(el: ElementRef) {
        if (el.nativeElement !== null && el.nativeElement.tagName === 'CANVAS') {
            this.el = el;
        }
    }

    private initWebglContext(el: ElementRef): void {
        this.canvasContext = el.nativeElement.getContext('webgl2');
        if (!this.canvasContext) {
            console.error('webgl context is not avaliable !');
            return;
        }
        this.canvasContext.clearColor(1.0, 1.0, 1.0, 1.0);
        this.canvasContext.getExtension('OES_standard_derivatives');
        this.setCanvasSize(this.fullScreen);
        /* tslint:disable:no-bitwise */
        this.canvasContext.clear(this.canvasContext.COLOR_BUFFER_BIT | this.canvasContext.DEPTH_BUFFER_BIT);
    }

    private setCanvasSize(fullScreen?: boolean): void {
        if (fullScreen) {
            this.setSize(window.innerWidth, window.innerHeight);
        } else {
            this.setSize(this.w, this.h);
        }
    }

    private setSize(width: number, height: number): void {
        this.canvasContext.canvas.width = width;
        this.canvasContext.canvas.height = height;
        this.canvasContext.viewport(0, 0, width, height);
    }

    private initBuffers(positionLocation: GLuint): void {
        const buffer: WebGLBuffer = this.canvasContext.createBuffer();
        this.canvasContext.bindBuffer(this.canvasContext.ARRAY_BUFFER, buffer);
        this.canvasContext.bufferData(this.canvasContext.ARRAY_BUFFER, new Float32Array([
        -1.0, -1.0,
         1.0, -1.0,
        -1.0,  1.0,
        -1.0,  1.0,
         1.0, -1.0,
         1.0,  1.0]), this.canvasContext.STATIC_DRAW);
        this.canvasContext.enableVertexAttribArray(positionLocation);
        this.canvasContext.vertexAttribPointer(positionLocation, 2, this.canvasContext.FLOAT, false, 0, 0);
    }

}
