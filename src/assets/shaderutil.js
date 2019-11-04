class ShaderUtil{
	static UNIFORM_TYPES = {
		FLOAT:"float",
		VEC2:"vec2",
		VEC3:"vec3",
		BOOL:"bool"
	};

	static SHADER_DATA_TYPES = {
		UNFORM:"uniform",
		ATTRIBUT:"attribut"
	};

	static parseShaderData(gl, shaderClass){
		var shaderData = ShaderUtil.loadJSON("../assets/shaders/shader_data/uniforms.json");
		console.log(shaderData);
		if(shaderData.uniforms){
			for(var i = 0; i < shaderData.uniforms.length; i++){
				var uniform = shaderData.uniforms[i];
				switch(uniform.type){
					case ShaderUtil.UNIFORM_TYPES.FLOAT:
						console.log("uniform1f");
						break;
					case ShaderUtil.UNIFORM_TYPES.VEC2:
						console.log("uniform2f");
						break;
					case ShaderUtil.UNIFORM_TYPES.VEC3:
						console.log("uniform3fv");
						break;
					case ShaderUtil.UNIFORM_TYPES.BOOL:
						console.log("uniform1f");
						break;
				}
			}
		}
	}

	static combineShader(shader){
		var source = ShaderUtil.loadShaderSource(shader).split('\n');
		for(var i = 0; i < source.length; i++){
			if(source[i].startsWith('#include')){
				var shaderType = source[i].substring(source[i].indexOf("<")+1,source[i].indexOf(".glsl>"));
				var res = ShaderUtil.loadShaderSource("../assets/shaders/"+shaderType+".glsl");
				if(res !== null){
					source[i] = '\n'+res+'\n';
				}
			}
		}
		return source.join('\n');
	}

	static loadShaderSource(shaderSourceLocation){
		const req = new XMLHttpRequest();
        req.open('GET', shaderSourceLocation, false);
        req.overrideMimeType('text/plain');
        req.send();

        if (req.status === 200) {
            //console.log("<%s> file loading succeded !", shaderSourceLocation);
            return req.responseText;
        } else {
            console.log("<%s> file loading failed !", shaderSourceLocation);
        }
	}

	static loadJSON(jsonLocation){
		return JSON.parse(ShaderUtil.loadShaderSource(jsonLocation));
	}
}