import { Shader } from './Shader';

export class WGFWTimeliner {

    gl: WebGL2RenderingContext;
    shader: Shader;
    timelinerCanvas: HTMLCanvasElement;

    scroller: any;

    constructor(gl: WebGL2RenderingContext, shader: Shader) {
        this.gl = gl;
        this.shader = shader;
        const canvas: HTMLCanvasElement = document.createElement('canvas');
        (<Node> gl.canvas).parentElement.appendChild(document.createElement('br'));
        (<Node> gl.canvas).parentElement.appendChild(canvas);

        this.scroller = {
            x: 0,
            y: 0,
            radius: 0,
            timelabel: ''
        };

        this.timelinerCanvas = canvas;
        this.timelinerCanvas.addEventListener('click', (event) => {
            console.log(Math.sqrt(Math.pow(this.scroller.x - event.clientX, 2) + Math.pow(this.scroller.y - event.clientY, 2)));
        });
        this.loop(this.gl, this.shader, this.timelinerCanvas);
    }

    private loop(gl: WebGL2RenderingContext, shader: Shader, canvas: HTMLCanvasElement) {
        canvas.width = document.body.clientWidth;
        canvas.height = 100;
        const ctx: CanvasRenderingContext2D = canvas.getContext('2d');
        ctx.fillStyle = '#999';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = '#f00';
        ctx.fillRect(0, 0, <number> shader.shaderUniforms.time.value * 100, 5);
        const timeString: string[] = ((<number> shader.shaderUniforms.time.value).toFixed(2) + '').split('.');
        const outTime: string = timeString[0] + ':' + timeString[1];
        this.scroller.x = <number> shader.shaderUniforms.time.value * 100;
        this.scroller.y = 20;
        this.scroller.radius = 15;
        this.scroller.timelabel = outTime;
        ctx.beginPath();
        ctx.arc(<number> shader.shaderUniforms.time.value * 100, 20, 15, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.fillStyle = '#fff';
        ctx.fillText(outTime, <number> shader.shaderUniforms.time.value * 100 - 10, 23);
        for (let i = 0; i < canvas.width; i += 10) {
            ctx.strokeStyle = 'rgba(0,0,0,0.5)';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(i, 0);
            if(i % 50 === 0) {
                ctx.lineTo(i, 25);
            } else {
                ctx.lineTo(i, 10);
            }
            ctx.stroke();

            if(i % 100 === 0) {
                ctx.fillStyle = '#fff';
                const tickTime: string = (i * 0.01).toString() + ':00';
                ctx.fillText(tickTime, i > 0 ? i - tickTime.length - 3 : i , 32);
            }
        }
        requestAnimationFrame(this.loop.bind(this, gl, shader, canvas));
    }

}
