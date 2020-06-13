import { Shader } from './Shader';
import { Uniform } from './models/uniform';
export default class ShaderUtils {
    static UNIFORM_TYPES = {INT: 'int', FLOAT: 'float', VEC2: 'vec2', VEC3: 'vec3', BOOL: 'bool', STRUCT: 'struct', SAMPLER_2D: 'sampler_2d'};

    static SHADER_DATA_TYPES = {UNFORM: 'uniform', ATTRIBUT: 'attribut'};

    public static parseShaderData(gl: WebGL2RenderingContext, shaderClass: Shader, programShader: WebGLProgram, canvas: HTMLCanvasElement): {[key: string]: Uniform} {
        gl.useProgram(programShader);
        const uniforms: {[key: string]: Uniform} = this.loadJSON('../assets/shaders/shader_data/uniforms.json');
        if (uniforms) {
            const uniformsValues: Uniform[] = <Uniform[]> Object.values(uniforms);
            uniformsValues.forEach(uniform => {
                const location: WebGLUniformLocation = gl.getUniformLocation(programShader, uniform.name);
                uniform.location = location;
                switch (uniform.type) {
                    case this.UNIFORM_TYPES.FLOAT || this.UNIFORM_TYPES.BOOL:
                        gl.uniform1f(location, <number> uniform.value);
                        break;
                    case this.UNIFORM_TYPES.VEC2:
                        if (uniform.name === 'resolution') {
                            uniform.value = [canvas.width, canvas.height];
                        } else if (uniform.name === 'screenRatio') {
                            const mx: number = Math.max(canvas.width, canvas.height);
                            uniform.value = [canvas.width / mx, canvas.height / mx];
                        }
                        gl.uniform2fv(location, <number[]> uniform.value);
                        break;
                    case this.UNIFORM_TYPES.VEC3:
                        gl.uniform3fv(location, <number[]> uniform.value);
                        break;
                    case this.UNIFORM_TYPES.STRUCT:
                        uniform.location = Array<WebGLUniformLocation>();
                        let index = 0;
                        for (const field of uniform.fields) {
                            (<WebGLUniformLocation[]> (uniform.location)).push(gl.getUniformLocation(programShader, uniform.name + '.' + field));
                            if (uniform.types[index] === this.UNIFORM_TYPES.INT) {
                                gl.uniform1i(uniform.location[(<WebGLUniformLocation[]> (uniform.location)).length - 1], <number> uniform.value[index++]);
                            } else {
                                gl.uniform1f(uniform.location[(<WebGLUniformLocation[]> (uniform.location)).length - 1], <number> uniform.value[index++]);
                            }
                        }
                        break;
                    case this.UNIFORM_TYPES.SAMPLER_2D:
                        const texture = this.loadTexture(gl, '../assets/textures/noisemed256.png');
                        gl.activeTexture(gl.TEXTURE0);
                        gl.bindTexture(gl.TEXTURE_2D, texture);
                        gl.uniform1i(location, 0);
                        break;
                }
            });
        }
        console.log(uniforms);
        return uniforms;
    }

    public static getUniformByName(uniforms: Uniform[], name: string): Uniform {
        return uniforms.find(uniform => uniform.name === name);
    }

    public static combineShader(shader: string): string {
        const source: string[] = this.loadShaderSource(shader).split('\n');
        for (let i = 0; i < source.length; i++) {
            if (source[i].startsWith('#include')) {
                const shaderType = source[i].substring(source[i].indexOf('<') + 1, source[i].indexOf('.glsl>'));
                const res = this.loadShaderSource('../assets/shaders/' + shaderType + '.glsl');
                if (res !== null) {
                    source[i] = '\n' + res + '\n';
                }
            }
        }
        return source.join('\n');
    }

    public static loadShaderSource(shaderSourceLocation: string): string {
        const req = new XMLHttpRequest();
        req.open('GET', shaderSourceLocation, false);
        req.overrideMimeType('text/plain');
        req.send();

        if (req.status === 200) {
            return req.responseText;
        } else {
            console.log('<%s> file loading failed !', shaderSourceLocation);
            return null;
        }
    }

    public static loadJSON(jsonLocation: string): any {
        return JSON.parse(this.loadShaderSource(jsonLocation));
    }

    public static loadTexture(gl: WebGL2RenderingContext, url: string): WebGLTexture{
        const texture = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, texture);

        const level = 0;
        const internalFormat = gl.RGBA;
        const width = 1;
        const height = 1;
        const border = 0;
        const srcFormat = gl.RGBA;
        const srcType = gl.UNSIGNED_BYTE;
        const pixel = new Uint8Array([0, 0, 255, 255]);
        gl.texImage2D(gl.TEXTURE_2D, level, internalFormat, width, height, border, srcFormat, srcType, pixel);

        const image = new Image();
        image.onload = () => {
            gl.bindTexture(gl.TEXTURE_2D, texture);
            gl.texImage2D(gl.TEXTURE_2D, level, internalFormat, srcFormat, srcType, image);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        };

        image.src = url;
        return texture;
    }
}
