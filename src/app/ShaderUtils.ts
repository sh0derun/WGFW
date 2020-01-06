import { Shader } from './Shader';
export default class ShaderUtils {
    static UNIFORM_TYPES = {FLOAT: 'float', VEC2: 'vec2', VEC3: 'vec3', BOOL: 'bool'};

    static SHADER_DATA_TYPES = {UNFORM: 'uniform', ATTRIBUT: 'attribut'};

    public static parseShaderData(gl: WebGL2RenderingContext, shaderClass: Shader) {
        const shaderData = this.loadJSON('../assets/shaders/shader_data/uniforms.json');
        console.log(shaderData);
        if (shaderData.uniforms) {
            shaderData.uniforms.forEach(uniform => {
                switch (uniform.type) {
                    case this.UNIFORM_TYPES.FLOAT:
                        console.log('uniform1f');
                        break;
                    case this.UNIFORM_TYPES.VEC2:
                        console.log('uniform2f');
                        break;
                    case this.UNIFORM_TYPES.VEC3:
                        console.log('uniform3fv');
                        break;
                    case this.UNIFORM_TYPES.BOOL:
                        console.log('uniform1f');
                        break;
                }
            });
        }
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
}
