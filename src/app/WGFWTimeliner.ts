import { Shader } from './Shader';

export class WGFWTimeliner {

    gl: WebGL2RenderingContext;
    shader: Shader;
    timelinerCanvas: HTMLCanvasElement;
    ctx: CanvasRenderingContext2D;
    pause: boolean;

    scroller: any;

    constructor(gl: WebGL2RenderingContext, shader: Shader) {
        this.gl = gl;
        this.shader = shader;
        const canvas: HTMLCanvasElement = document.createElement('canvas');
        (<Node> gl.canvas).parentElement.appendChild(document.createElement('br'));
        (<Node> gl.canvas).parentElement.appendChild(canvas);

        this.ctx = canvas.getContext('2d');

        this.scroller = {
            x: 0,
            y: 0,
            radius: 0,
            timelabel: '',
            clicked: false
        };

        this.timelinerCanvas = canvas;
        this.timelinerCanvas.addEventListener('mousedown', (event) => {
            if (Math.sqrt(Math.pow(this.scroller.x - event.offsetX, 2) + Math.pow(this.scroller.y - event.offsetY, 2)) <= this.scroller.radius ||
            ((event.offsetY >= 0 && event.offsetY <= 25) && (event.offsetX >= 0 && event.offsetX <= this.timelinerCanvas.width))) {
                this.scroller.clicked = true;
                shader.shaderUniforms.time.value = event.offsetX / 100;
            }
        });
        this.timelinerCanvas.addEventListener('mouseup', (event) => {
            this.scroller.clicked = false;
        });
        this.timelinerCanvas.addEventListener('mousemove', (event) => {
            if (this.scroller.clicked) {
                shader.shaderUniforms.time.value = event.offsetX / 100;
            }
        });
        this.loop(this.gl, this.shader, this.timelinerCanvas);
    }

    private loop(gl: WebGL2RenderingContext, shader: Shader, canvas: HTMLCanvasElement) {
        canvas.width = document.body.clientWidth;
        canvas.height = 100;

        const timeString: string[] = ((<number> shader.shaderUniforms.time.value).toFixed(2) + '').split('.');
        const outTime: string = timeString[0] + ':' + timeString[1];
        if (!this.pause) {
            this.scroller.x = <number> shader.shaderUniforms.time.value * 100;
        }
        this.scroller.y = 20;
        this.scroller.radius = 15;
        this.scroller.timelabel = outTime;

        if (this.scroller.x >= canvas.width) {
            shader.shaderUniforms.time.value = 0.0;
        }

        this.ctx.fillStyle = '#999';
        this.ctx.fillRect(0, 0, canvas.width, canvas.height);
        this.ctx.fillStyle = '#f00';
        this.ctx.fillRect(0, 0, this.scroller.x, 5);
        this.ctx.beginPath();
        this.ctx.arc(this.scroller.x, 20, 15, 0, Math.PI * 2, true);
        this.ctx.fill();
        this.ctx.fillStyle = '#fff';
        this.ctx.fillText(outTime, this.scroller.x - 10, 23);
        for (let i = 0; i < canvas.width; i += 10) {
            this.ctx.strokeStyle = 'rgba(0,0,0,0.5)';
            this.ctx.lineWidth = 2;
            this.ctx.beginPath();
            this.ctx.moveTo(i, 0);
            if(i % 50 === 0) {
                this.ctx.lineWidth = 3.0;
                this.ctx.lineTo(i, 25);
            } else {
                this.ctx.lineTo(i, 10);
            }
            this.ctx.stroke();

            if(i % 100 === 0) {
                this.ctx.fillStyle = '#fff';
                const tickTime: string = (i * 0.01).toString() + ':00';
                this.ctx.fillText(tickTime, i > 0 ? i - tickTime.length - 3 : i , 32);
            }
        }
        requestAnimationFrame(this.loop.bind(this, gl, shader, canvas));
    }

}
