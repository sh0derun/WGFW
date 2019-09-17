class ShaderUtil{
	static combineShader(shader){
		var source = ShaderUtil.loadShaderSource(shader);
		var lines = source.split('\n');
		for(var i = 0; i < lines.length; i++){
			if(lines[i].startsWith('#include')){
				var shaderType = lines[i].substring(lines[i].indexOf("<")+1,lines[i].indexOf(".glsl>"));
				var res = ShaderUtil.loadShaderSource("./shaders/"+shaderType+".glsl");
				if(res !== null){
					lines[i] = '\n'+res+'\n';
				}
			}
		}
		source = lines.join('');
		return source;
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
}