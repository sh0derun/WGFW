import ShaderUtils from './ShaderUtils';
import { Uniform } from './models/uniform';


export class Shader {

    vertexShaderSource: string;
    fragShaderSource: string;
    vertexShader: any;
    fragmentShader: any;
    programShader: any;
    uniforms: any;
    attributs: any;

    shaderUniforms: {[key: string]:Uniform}[];

    constructor(vertexSource: string, fragmentSource: string) {
        this.vertexShaderSource = ShaderUtils.loadShaderSource(vertexSource);
        this.fragShaderSource = ShaderUtils.combineShader(fragmentSource);
        this.vertexShader = null;
        this.fragmentShader = null;
        this.programShader = null;
        this.uniforms = {};
        this.attributs = {};
        this.shaderUniforms = Array<{[key: string]:Uniform}>();
    }

    public compileShaders(gl: WebGL2RenderingContext) {
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

    public initProgramShader(gl: WebGL2RenderingContext) {
        if (this.programShader === null) {
            this.programShader = gl.createProgram();
        }

        gl.attachShader(this.programShader, this.vertexShader);
        gl.attachShader(this.programShader, this.fragmentShader);
        gl.linkProgram(this.programShader);

        gl.deleteShader(this.vertexShader);
        gl.deleteShader(this.fragmentShader);

        if (!gl.getProgramParameter(this.programShader, gl.LINK_STATUS)) {
            console.error('WebGL - Shader Initialization Error');
            gl.deleteProgram(this.programShader);
            return;
        }
        gl.useProgram(this.programShader);
    }

    public initShaderValues(gl: WebGL2RenderingContext, canvas: HTMLCanvasElement) {
        const shaderData = ShaderUtils.parseShaderData(gl, this, this.programShader, canvas);
        console.log(shaderData);
        this.shaderUniforms = [...this.shaderUniforms,...shaderData];

        this.uniforms.time = {
            location: gl.getUniformLocation(this.programShader, 'time'),
            value: 0.0
        };
        gl.uniform1f(this.uniforms.time.location, this.uniforms.time.value);

        this.uniforms.resolution = {
            location: gl.getUniformLocation(this.programShader, 'resolution'),
            value: {
                x: canvas.width,
                y: canvas.height
            }
        };
        gl.uniform2f(this.uniforms.resolution.location, this.uniforms.resolution.value.x, this.uniforms.resolution.value.y);

        const mx: number = Math.max(canvas.width, canvas.height);
        this.uniforms.screenRatio = {
            location: gl.getUniformLocation(this.programShader, 'screenRatio'),
            value: {
                x: canvas.width / mx,
                y: canvas.height / mx
            }
        };
        gl.uniform2f(this.uniforms.screenRatio.location, this.uniforms.screenRatio.value.x, this.uniforms.screenRatio.value.y);

        this.uniforms.speed = {
            location: gl.getUniformLocation(this.programShader, 'speed'),
            value: 0.0
        };
        gl.uniform1f(this.uniforms.speed.location, this.uniforms.speed.value);

        this.uniforms.fogAmount = {
            location: gl.getUniformLocation(this.programShader, 'fogAmount'),
            value: 0.0
        };
        gl.uniform1f(this.uniforms.fogAmount.location, this.uniforms.fogAmount.value);

        this.uniforms.fogColor = {
            location: gl.getUniformLocation(this.programShader, 'fogColor'),
            value: [1.7, 0.8, 1.0]
        };
        gl.uniform3fv(this.uniforms.fogColor.location, this.uniforms.fogColor.value);

        this.uniforms.camera = {
            location: gl.getUniformLocation(this.programShader, 'camera'),
            value: [4.0, 2.0, 4.0]
        };
        gl.uniform3fv(this.uniforms.camera.location, this.uniforms.camera.value);

        this.uniforms.sphere = {
            location: gl.getUniformLocation(this.programShader, 'sphere'),
            value: [0.5, 0.5, 0.1]
        };
        gl.uniform3fv(this.uniforms.sphere.location, this.uniforms.sphere.value);

        this.uniforms.mouse = {
            location: gl.getUniformLocation(this.programShader, 'mouse'),
            value: [1.0, 3.0]
        };
        gl.uniform2fv(this.uniforms.mouse.location, this.uniforms.mouse.value);

        this.uniforms.gamma = {
            location: gl.getUniformLocation(this.programShader, 'gamma'),
            value: 0.8
        };
        gl.uniform1f(this.uniforms.gamma.location, this.uniforms.gamma.value);

        this.uniforms.overRelaxation = {
            location: gl.getUniformLocation(this.programShader, 'overRelaxation'),
            value: 0
        };
        gl.uniform1f(this.uniforms.overRelaxation.location, this.uniforms.overRelaxation.value);

        this.uniforms.showDisplacements = {
            location: gl.getUniformLocation(this.programShader, 'showDisplacements'),
            value: 0
        };
        gl.uniform1f(this.uniforms.showDisplacements.location, this.uniforms.showDisplacements.value);

        this.uniforms.phongShading = {
            location: gl.getUniformLocation(this.programShader, 'phongShading'),
            value: 0
        };
        gl.uniform1f(this.uniforms.phongShading.location, this.uniforms.phongShading.value);

        this.uniforms.pbrShading = {
            location: gl.getUniformLocation(this.programShader, 'pbrShading'),
            value: 0
        };
        gl.uniform1f(this.uniforms.pbrShading.location, this.uniforms.pbrShading.value);

        this.uniforms.textureData = {
            location: {
                thickness: gl.getUniformLocation(this.programShader, 'textureData.thickness'),
                frequency: gl.getUniformLocation(this.programShader, 'textureData.frequency'),
                amplitude: gl.getUniformLocation(this.programShader, 'textureData.amplitude')
            },
            value: {
                thickness: 0.1,
                frequency: 0.1,
                amplitude: 0.1
            }
        };
        gl.uniform1f(this.uniforms.textureData.location.thickness, this.uniforms.textureData.value.thickness);
        gl.uniform1f(this.uniforms.textureData.location.frequency, this.uniforms.textureData.value.frequency);
        gl.uniform1f(this.uniforms.textureData.location.amplitude, this.uniforms.textureData.value.amplitude);

        this.attributs.a_position = {
            location: gl.getAttribLocation(this.programShader, 'a_position'),
            value: 2
        };
    }

}
