import { Shape } from './../models/shape';
import { WGFWAnimator } from '../WGFWAnimator';
import { Shader } from './../Shader';
import { Directive, ElementRef, Input, OnInit, Output, EventEmitter } from '@angular/core';

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
    fbo: WebGLFramebuffer;
    depthBuffer: WebGLRenderbuffer;
    renderTexture: WebGLTexture;

    sphereTracingQuad: Shape;
    fullScreenQuad: Shape;

    @Output() fpsEmitter: EventEmitter<number> = new EventEmitter<number>();

    ngOnInit() {
        this.initWebglContext(this.el);
        this.initBuffers();

        this.shader = new Shader(this.vertexShaderLocation, this.fragmentShaderLocation, false);
        this.shader.compileShaders(this.canvasContext);
        this.shader.initProgramShader(this.canvasContext);
        this.shader.initShaderValues(this.canvasContext, this.el.nativeElement);

        this.animator = new WGFWAnimator(this.canvasContext, this.shader, this.fbo, this.depthBuffer, this.renderTexture, this.sphereTracingQuad, this.fullScreenQuad, this.el.nativeElement);
        this.animator.initRenderingLoop();
        this.animator.render();

        this.loop();
    }

    constructor(el: ElementRef) {
        if (el.nativeElement !== null) {
            this.el = el;
        }
    }

    private loop() {
        this.fpsEmitter.emit(Math.floor(this.animator.fps));
        requestAnimationFrame(this.loop.bind(this));
    }

    private initWebglContext(el: ElementRef): void {
        this.canvasContext = el.nativeElement.getContext('webgl2');
        if (!this.canvasContext) {
            console.error('webgl context is not avaliable !');
            return;
        }
        this.canvasContext.clearColor(1.0, 1.0, 1.0, 1.0);
        this.canvasContext.getExtension('OES_standard_derivatives');
        this.canvasContext.getExtension('OES_texture_float');
        this.canvasContext.getExtension('OES_texture_float_linear');
        this.canvasContext.getExtension('EXT_color_buffer_float');

        this.setCanvasSize(this.fullScreen);
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

    private initBuffers(): void {
        this.sphereTracingQuad = this.createShape(this.canvasContext,
            [
                -1.0, -1.0, 0.0,
                1.0, 0.0, 0.0,
                1.0, -1.0, 0.0,
                0.0, 1.0, 0.0,
                1.0, 1.0, 0.0,
                0.0, 0.0, 1.0,
                -1.0, 1.0, 0.0,
                1.0, 1.0, 1.0
            ],
            [
                0, 1, 2,
                0, 2, 3
            ]
        );
        this.fullScreenQuad = this.createShape(this.canvasContext,
            [
                -1.0, -1.0, 0.0,
                0.0, 0.0,
                1.0, -1.0, 0.0,
                1.0, 0.0,
                1.0, 1.0, 0.0,
                1.0, 1.0,
                -1.0, 1.0, 0.0,
                0.0, 1.0
            ],
            [
                0, 1, 2,
                0, 2, 3
            ]
        );

        this.fbo = this.canvasContext.createFramebuffer();

        this.depthBuffer = this.canvasContext.createRenderbuffer();
        this.canvasContext.bindRenderbuffer(this.canvasContext.RENDERBUFFER, this.depthBuffer);
        this.canvasContext.renderbufferStorage(this.canvasContext.RENDERBUFFER, this.canvasContext.RGBA32F, this.w, this.h);

        this.renderTexture = this.createFloatTexture(this.canvasContext, this.w, this.h);
    }

    private createShape(gl: WebGL2RenderingContext, vertexData: Array<number>, indexData: Array<number>): Shape {
        const shape: Shape = <any> {};

        const vertexArray: Float32Array = new Float32Array(vertexData);
        const vertexBuffer: WebGLBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
        gl.bufferData(gl.ARRAY_BUFFER, vertexArray, gl.STATIC_DRAW);
        gl.bindBuffer(gl.ARRAY_BUFFER, null);

        const indexArray: Uint16Array = new Uint16Array(indexData);
        const indexBuffer: WebGLBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indexArray, gl.STATIC_DRAW);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);

        shape.vertexBuffer = vertexBuffer;
        shape.indexBuffer = indexBuffer;
        shape.size = indexData.length;

        return shape;
    }

    private createFloatTexture(gl: WebGL2RenderingContext, width: number, height: number): WebGLTexture {
        const texture = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA32F, width, height, 0, gl.RGBA, gl.FLOAT, null);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.bindTexture(gl.TEXTURE_2D, null);
        return texture;
    }

}
