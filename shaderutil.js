class ShaderUtil{
	static combineShader(shader){
		var source = ShaderUtil.loadShaderSource(shader).split('\n');
		for(var i = 0; i < source.length; i++){
			if(source[i].startsWith('#include')){
				var shaderType = source[i].substring(source[i].indexOf("<")+1,source[i].indexOf(".glsl>"));
				var res = ShaderUtil.loadShaderSource("./shaders/"+shaderType+".glsl");
				if(res !== null){
					source[i] = '\n'+res+'\n';
				}
			}
		}
		return source.join('');
	}

	static loadShaderSource(shaderSourceLocation){
		const req = new XMLHttpRequest();
        req.open('GET', shaderSourceLocation, false);
        req.overrideMimeType('text/plain');
        req.send();

        if (req.status === 200) {
            console.log("<%s> file loading succeded !", shaderSourceLocation);
            return req.responseText;
        } else {
            console.log("<%s> file loading failed !", shaderSourceLocation);
        }
	}

	static loadJSON(jsonLocation){
		return JSON.parse(ShaderUtil.loadShaderSource(jsonLocation));
	}
}