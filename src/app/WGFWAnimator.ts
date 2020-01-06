import { Shader } from './Shader';
import { GUI } from 'dat.gui';

export class WGFWAnimator {

    start: number;
    fps: number;
    fpstime: number;
    gl: any;
    shader: Shader;
    canvas: any;

    guiData: any;
    textureData: any;
    texControls: any;
    guiControls: any;
    cameraFolder: any;
    sphereFolder: any;
    fogFolder: any;

    constructor(gl: any, shader: Shader, canvas: any) {
        this.start = 0.0;
        this.fps = 0;
        this.fpstime = 0.0;
        this.gl = gl;
        this.shader = shader;
        this.canvas = canvas;

        this.guiData = {
            speed: 0.1,
            fogAmount: 0.0,
            fogColor: [0.1, 0, 0],
            mouse: [0.0, 0.0, 0.0],
            gamma: 1.5,
            sphere: {metalic: 0.5, roughness: 0.5, reflectionOpacity: 1.0},
            overRelaxation: false,
            showDisplacements: false,
            phongShading: true,
            pbrShading: false,
            pause: false,
            camera: {x: 4.0, y: 2.0, z: 4.0},
            save: this.saveCanvasFile.bind(this),
            record: this.getRecordedAnimation.bind(this)
        };

        this.textureData = {
            thickness: 0.1,
            frequency: 0.3,
            amplitude: 0.3
        };

        this.canvas.addEventListener('mousemove', this.onMouseMove.bind(this));

        this.texControls = new GUI({name: 'Texture Data', autoPlace: false});
        const customContainer = document.getElementById('texgui');
        customContainer.appendChild(this.texControls.domElement);

        this.texControls.add(this.textureData, 'thickness', 0.01, 3.0, 0.01);
        this.texControls.add(this.textureData, 'frequency', 0.01, 5.0, 0.01);
        this.texControls.add(this.textureData, 'amplitude', 0.01, 5.0, 0.01);

        this.guiControls = new GUI({name: 'Animation Data'});
        this.guiControls.add(this.guiData, 'speed', -5.0, 5.0, 0.001);

        this.cameraFolder = this.guiControls.addFolder('Camera');
        this.cameraFolder.add(this.guiData.camera, 'x', -5.0, 5.0, 0.01);
        this.cameraFolder.add(this.guiData.camera, 'y', 1.0, 5.0, 0.01);
        this.cameraFolder.add(this.guiData.camera, 'z', -5.0, 5.0, 0.01);

        this.sphereFolder = this.guiControls.addFolder('Sphere PBR');
        this.sphereFolder.add(this.guiData.sphere, 'metalic', 0.0, 1.0, 0.001);
        this.sphereFolder.add(this.guiData.sphere, 'roughness', 0.0, 1.0, 0.001);
        this.sphereFolder.add(this.guiData.sphere, 'reflectionOpacity', 0.0, 1.0, 0.001);

        this.fogFolder = this.guiControls.addFolder('Fog');
        this.fogFolder.add(this.guiData, 'fogAmount', 0.0, 2.5, 0.0001);
        this.fogFolder.addColor(this.guiData, 'fogColor').onChange(this.onChangeFogColor.bind(this));

        this.fogFolder = this.guiControls.addFolder('Scene');
        this.fogFolder.add(this.guiData, 'gamma', 0.8, 5.0, 0.0001);
        this.fogFolder.add(this.guiData, 'overRelaxation');
        this.fogFolder.add(this.guiData, 'showDisplacements');
        this.fogFolder.add(this.guiData, 'phongShading');
        this.fogFolder.add(this.guiData, 'pbrShading');

        this.guiControls.add(this.guiData, 'pause').onChange(this.onChangePauseFlag.bind(this));
        this.guiControls.add(this.guiData, 'save');
        this.guiControls.add(this.guiData, 'record');
    }

    private onChangePauseFlag(): void {
        if (!this.guiData.pause) {
            this.render();
        }
    }

    private getRecordedAnimation(): void {
        /*if(this.recorder.mediaRecorder.state === "inactive"){
            this.recorder.mediaRecorder.start();
        }
        else{
            this.recorder.mediaRecorder.stop();
        }*/
        console.log('RecordedAnimationMethod !');
    }

    private onMouseMove(event): void {
        this.guiData.mouse = [event.clientX, event.clientY];
        this.shader.uniforms.mouse.value = this.mappingMouseCoords(this.guiData.mouse);
        this.gl.uniform2fv(this.shader.uniforms.mouse.location, this.shader.uniforms.mouse.value);
    }

    private onChangeFogColor(): void {
        this.shader.uniforms.fogColor.value = this.mappingColor(this.guiData.fogColor);
        this.gl.uniform3fv(this.shader.uniforms.fogColor.location, this.shader.uniforms.fogColor.value);
    }

    private onChangeValue(e): void {
        console.log(e);
    }

    private saveCanvasFile(): void {

    }

    private mappingColor(color: number[]): number[] {
        const mapRange = (from, to, s) => {
            return to[0] + (s - from[0]) * (to[1] - to[0]) / (from[1] - from[0]);
        };
        const newRangeColor: number[] = [];
        for (let i = 0; i < color.length; i++) {
            newRangeColor[i] = mapRange([0, 255], [0, 1], color[i]);
        }
        return newRangeColor;
    }

    private mappingMouseCoords(mouse: number[]): number[] {
        const mapRange = (from, to, s) => {
            return to[0] + (s - from[0]) * (to[1] - to[0]) / (from[1] - from[0]);
        };
        const newRangeMouse: number[] = [];
        for (let i = 0; i < mouse.length; i++) {
            newRangeMouse[i] = mapRange([this.canvas.width, this.canvas.height], [-5, 1], mouse[i]);
        }
        return newRangeMouse;
    }

    private lerp(oldValue: number, newValue: number, lerpFactor: number): number {
        return (1 - lerpFactor) * oldValue + lerpFactor * newValue;
    }

    private nlerp(oldValue: number[], newValue: number[], lerpFactor: number): number[] {
        const res: number[] = [];
        for (let i = 0; i < oldValue.length; i++) {
            res[i] = this.lerp(oldValue[i], newValue[i], lerpFactor);
        }
        return res;
    }

    public initRenderingLoop(): void {
        const requestAnimFrame = 'requestAnimFrame';
        const mozRequestAnimationFrame = 'mozRequestAnimationFrame';
        const oRequestAnimationFrame = 'oRequestAnimationFrame';
        const msRequestAnimationFrame = 'msRequestAnimationFrame';
        window[requestAnimFrame] = (() => {
            return window.requestAnimationFrame ||
                window.webkitRequestAnimationFrame ||
                window[mozRequestAnimationFrame] ||
                window[oRequestAnimationFrame] ||
                window[msRequestAnimationFrame] ||
                function (callback, element) {
                    return window.setTimeout(callback, 1000 / 60);
                };
        })();
        const cancelRequestAnimFrame = 'cancelRequestAnimFrame';
        const mozCancelRequestAnimationFrame = 'mozCancelRequestAnimationFrame';
        const oCancelRequestAnimationFrame = 'oCancelRequestAnimationFrame';
        const msCancelRequestAnimationFrame = 'msCancelRequestAnimationFrame';
        window[cancelRequestAnimFrame] = (() => {
            return window.cancelAnimationFrame ||
                window.webkitCancelAnimationFrame ||
                window[mozCancelRequestAnimationFrame] ||
                window[oCancelRequestAnimationFrame] ||
                window[msCancelRequestAnimationFrame] ||
                window.clearTimeout;
        })();
    }

    public render(): void {
        if (!this.guiData.pause) {
            const elapsedtime: number = (Date.now() - this.start) / 1000.0;
            const framespeed = 1.0;
            this.shader.uniforms.time.value += 0.01;
            this.gl.uniform1f(this.shader.uniforms.time.location, this.shader.uniforms.time.value);

            this.shader.uniforms.speed.value = this.lerp(this.shader.uniforms.speed.value, this.guiData.speed, 1.0);
            this.gl.uniform1f(this.shader.uniforms.speed.location, this.shader.uniforms.speed.value);

            this.shader.uniforms.fogAmount.value = this.lerp(this.shader.uniforms.fogAmount.value, this.guiData.fogAmount, 1.0);
            this.gl.uniform1f(this.shader.uniforms.fogAmount.location, this.shader.uniforms.fogAmount.value);

            this.shader.uniforms.gamma.value = this.lerp(this.shader.uniforms.gamma.value, this.guiData.gamma, 0.5);
            this.gl.uniform1f(this.shader.uniforms.gamma.location, this.shader.uniforms.gamma.value);

            this.shader.uniforms.overRelaxation.value = +this.guiData.overRelaxation;
            this.gl.uniform1f(this.shader.uniforms.overRelaxation.location, this.shader.uniforms.overRelaxation.value);

            this.shader.uniforms.showDisplacements.value = +this.guiData.showDisplacements;
            this.gl.uniform1f(this.shader.uniforms.showDisplacements.location, this.shader.uniforms.showDisplacements.value);

            this.shader.uniforms.phongShading.value = +this.guiData.phongShading;
            this.gl.uniform1f(this.shader.uniforms.phongShading.location, this.shader.uniforms.phongShading.value);

            this.shader.uniforms.pbrShading.value = +this.guiData.pbrShading;
            this.gl.uniform1f(this.shader.uniforms.pbrShading.location, this.shader.uniforms.pbrShading.value);

            this.shader.uniforms.camera.value = this.nlerp(this.shader.uniforms.camera.value, Object.values(this.guiData.camera), 0.01);
            this.gl.uniform3fv(this.shader.uniforms.camera.location, this.shader.uniforms.camera.value);

            this.shader.uniforms.sphere.value = this.nlerp(this.shader.uniforms.sphere.value, Object.values(this.guiData.sphere), 0.5);
            this.gl.uniform3fv(this.shader.uniforms.sphere.location, this.shader.uniforms.sphere.value);

            this.shader.uniforms.textureData.value.thickness = this.lerp(this.shader.uniforms.textureData.value.thickness,
                                                                         this.textureData.thickness, 1.0);
            this.gl.uniform1f(this.shader.uniforms.textureData.location.thickness, this.shader.uniforms.textureData.value.thickness);

            this.shader.uniforms.textureData.value.frequency = this.lerp(this.shader.uniforms.textureData.value.frequency,
                                                                         this.textureData.frequency, 1.0);
            this.gl.uniform1f(this.shader.uniforms.textureData.location.frequency, this.shader.uniforms.textureData.value.frequency);

            this.shader.uniforms.textureData.value.amplitude = this.lerp(this.shader.uniforms.textureData.value.amplitude,
                                                                         this.textureData.amplitude, 1.0);
            this.gl.uniform1f(this.shader.uniforms.textureData.location.amplitude, this.shader.uniforms.textureData.value.amplitude);

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

}
