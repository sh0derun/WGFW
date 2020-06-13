export class Uniform {
    public type: string;
    public name: string;
    public value: number | number[] | {};
    public location: WebGLUniformLocation | WebGLUniformLocation[];
    public lerp: number | number[];
    public fields?: string[];
    public types?: string[];
}
