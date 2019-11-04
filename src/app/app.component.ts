import { Component, AfterViewInit } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements AfterViewInit{
	ngAfterViewInit(){
		var gl = new WGFW("#webglcanvas");
		gl.setSize(window.innerWidth/2.0,window.innerHeight/1.1);
		//gl.setSize(window.innerWidth/3.0,window.innerHeight/2.0);
		//gl.setSize(window.innerWidth/5.0,window.innerHeight/4.0);
		//gl.setSize(window.innerWidth,window.innerHeight);
		gl.clear();
		gl.setClearColor({r:1.0,g:0.0,b:0.0,a:0.3});
		gl.clear();
		
		var shader = new Shader('../assets/shaders/vertexshader.glsl', '../assets/shaders/demo_spherestaire.glsl');

		shader.compileShaders(gl.ctx);
		shader.initProgramShader(gl.ctx);
		shader.initShaderValues(gl.ctx,gl.canvas);
		
		gl.initBuffers(shader.attributs.a_position.location);

		var anim = new Animation(gl.ctx,shader,gl.canvas);
		anim.initRenderingLoop();
		anim.render();

		console.log("hello");
	}
}
