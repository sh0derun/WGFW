import ShaderUtils from './ShaderUtils';
import { Uniform } from './models/uniform';


export class Shader {

    vertexShaderSource: string;
    fragShaderSource: string;
    vertexShader: WebGLShader;
    fragmentShader: WebGLShader;
    programShader: WebGLProgram;
    shaderUniforms: {[key: string]: Uniform};
    attributs: any;

    constructor(vertexSource: string, fragmentSource: string) {
        this.vertexShaderSource = ShaderUtils.loadShaderSource(vertexSource);
        this.fragShaderSource = ShaderUtils.combineShader(fragmentSource);
        this.vertexShader = null;
        this.fragmentShader = null;
        this.programShader = null;
        this.attributs = {};
        this.shaderUniforms = {};
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
        this.shaderUniforms = Object.assign(shaderData);
        this.attributs.a_position = {
            location: gl.getAttribLocation(this.programShader, 'a_position'),
            value: 2
        };
    }

}
