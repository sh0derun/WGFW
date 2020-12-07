struct Material {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
    vec3 emissive;
	bool reflective;
	float reflectance;
};

struct PBRMaterial {
	vec3 albedo;
	float metalic;
	float roughness;
	vec3 emissive;
};

struct SdfPhongResult {
	float d;
	Material m;
};

struct SdfPbrResult{
	float d;
	PBRMaterial m;
};

//some IOR Values
//void 1
//Air 1.000293
//Helium  1.000036
//Hydrogen 1.000132
//Carbon dioxide  1.00045
//Water 1.333
//Ethanol 1.36
//Olive oil 1.47
//Glass 1.309
//Soda water  1.46
//PMMA (Plexiglas)  1.49
//Crown glass (typical) 1.52
//Flint glass (typical) 1.62
//Diamond 2.42

PBRMaterial simpleMatOrange = PBRMaterial(vec3(0.9,0.1,0.0),0.8,0.4,vec3(0.0));
PBRMaterial simpleMatGreen = PBRMaterial(vec3(0.0,1.0,0.0),0.8,0.6,vec3(0.0));
PBRMaterial simpleMatRed = PBRMaterial(vec3(1.0,0.0,0.0),0.6,0.1,vec3(0.0));
PBRMaterial simpleMatWhite = PBRMaterial(vec3(1.0),0.9,0.9,vec3(0.0));
PBRMaterial simpleMatGray = PBRMaterial(vec3(0.4),0.6,0.1,vec3(0.0));
PBRMaterial simpleMatBrown = PBRMaterial(vec3(0.8, 0.271, 0.075),0.6,0.1,vec3(0.0));
PBRMaterial simpleMatBlue = PBRMaterial(vec3(0.000, 0.000, 0.9),0.8,0.4,vec3(0.0));

//some Colors
//brown 0.545, 0.271, 0.075
//ice 0.686, 0.933, 0.933
//ocean   0.275, 0.510, 0.706
PBRMaterial mixPBRMterial(PBRMaterial a, PBRMaterial b, float x){
	return PBRMaterial(mix(a.albedo, b.albedo, x),
					   mix(a.metalic, b.metalic, x),
					   mix(a.roughness, b.roughness, x),
					   mix(a.emissive, b.emissive, x));
}

float combineSmooth(float d1, float d2, float r) {
 	float m = min(d1, d2);
  	if (d1 < r && d2 < r) {
    	return min(m, r - length(r - vec2(d1, d2)));
  	} else {
    	return m;
  	}
}
//23
Material materials[23] = Material[](Material(vec3(0.0215, 0.1745, 0.0215)      ,vec3(0.07568, 0.61424, 0.07568),		vec3(0.633, 0.727811, 0.633),			 0.6, vec3(0.0), false, 0.0),
									Material(vec3(0.135, 0.2225, 0.1575)       ,vec3(0.54, 0.89, 0.63),				vec3(0.316228, 0.316228, 0.316228),		 0.1, vec3(0.0), false, 0.0),
									Material(vec3(0.05375, 0.05, 0.06625)		 ,vec3(0.18275, 0.17, 0.22525),			vec3(0.332741, 0.328634, 0.346435),		 0.3, vec3(0.0), false, 0.0),
									Material(vec3(0.25, 0.20725, 0.20725)		 ,vec3(1.0, 0.829, 0.829),				vec3(0.296648, 0.296648, 0.296648),		 0.088, vec3(0.0), false, 0.0),
									Material(vec3(0.1745, 0.01175, 0.01175)	 ,vec3(0.61424, 0.04136, 0.04136),		vec3(0.727811, 0.626959, 0.626959),		 0.6, vec3(0.0), false, 0.0),
									Material(vec3(0.1, 0.18725, 0.1745)		 ,vec3(0.396, 0.74151, 0.69102),		vec3(0.297254, 0.30829, 0.306678),		 0.1, vec3(0.0), false, 0.0),
									Material(vec3(0.2125, 0.1275, 0.054),		  vec3(0.714, 0.4284, 0.18144),			vec3(0.393548, 0.271906, 0.166721),		 0.2, vec3(0.0), false, 0.0),
									Material(vec3(0.25, 0.25, 0.25),			  vec3(0.4, 0.4, 0.4),					vec3(0.774597, 0.774597, 0.774597),		 0.6, vec3(0.0), false, 0.0),
									Material(vec3(0.19125, 0.0735, 0.0225),	  vec3(0.7038, 0.27048, 0.0828),		vec3(0.256777, 0.137622, 0.086014),		 0.1, vec3(0.0), false, 0.0),
									Material(vec3(0.24725, 0.1995, 0.0745),	  vec3(0.75164, 0.60648, 0.22648),		vec3(0.628281, 0.555802, 0.366065),		 0.4, vec3(0.0), false, 0.0),
									Material(vec3(0.19225, 0.19225, 0.19225),	  vec3(0.50754, 0.50754, 0.50754),		vec3(0.508273, 0.508273, 0.508273),		 0.4, vec3(0.0), false, 0.0),
									Material(vec3(0.0, 0.0, 0.0),				  vec3(0.01, 0.01, 0.01),				vec3(0.50, 0.50, 0.50),					 0.25, vec3(0.0), false, 0.0),
									Material(vec3(0.0, 0.1, 0.06),			  vec3(0.0, 0.50980392, 0.50980392),	vec3(0.50196078, 0.50196078, 0.50196078),0.25, vec3(0.0), false, 0.0),
									Material(vec3(0.0, 0.0, 0.0),				  vec3(0.1, 0.35, 0.1),					vec3(0.45, 0.55, 0.45),					 0.25, vec3(0.0), false, 0.0),
									Material(vec3(0.0, 0.0, 0.0),				  vec3(0.5, 0.0, 0.0),					vec3(0.7, 0.6, 0.6),					 0.25, vec3(0.0), false, 0.0),
									Material(vec3(0.0, 0.0, 0.0),				  vec3(0.55, 0.55, 0.55),				vec3(0.70, 0.70, 0.70),					 0.25, vec3(0.0), false, 0.0),
									Material(vec3(0.0, 0.0, 0.0),				  vec3(0.5, 0.5, 0.0),					vec3(0.60, 0.60, 0.50),					 0.25, vec3(0.0), false, 0.0),
									Material(vec3(0.02, 0.02, 0.02),			  vec3(0.01, 0.01, 0.01),				vec3(0.4, 0.4, 0.4),					 0.078125, vec3(0.0), false, 0.0),
									Material(vec3(0.0, 0.05, 0.05),			  vec3(0.4, 0.5, 0.5),					vec3(0.04, 0.7, 0.7),					 0.078125, vec3(0.0), false, 0.0),
									Material(vec3(0.0, 0.05, 0.0),			  vec3(0.4, 0.5, 0.4),					vec3(0.04, 0.7, 0.04),					 0.078125, vec3(0.0), false, 0.0),
									Material(vec3(0.05, 0.0, 0.0),			  vec3(0.5, 0.4, 0.4),					vec3(0.7, 0.04, 0.04),					 0.078125, vec3(0.0), false, 0.0),
									Material(vec3(0.05, 0.05, 0.05),			  vec3(0.5, 0.5, 0.5),					vec3(0.7, 0.7, 0.7),					 0.078125, vec3(0.0), false, 0.0),
									Material(vec3(0.05, 0.05, 0.0),			  vec3(0.5, 0.5, 0.4),					vec3(0.7, 0.7, 0.04),					 0.078125, vec3(0.0), false, 0.0));

Material emerald 	        = Material(vec3(0.0215, 0.1745, 0.0215)      ,vec3(0.07568, 0.61424, 0.07568),		vec3(0.633, 0.727811, 0.633),			 0.6, vec3(0.0), false, 0.0);
Material jade		       	= Material(vec3(0.135, 0.2225, 0.1575)       ,vec3(0.54, 0.89, 0.63),				vec3(0.316228, 0.316228, 0.316228),		 0.1, vec3(0.0), false, 0.0);
Material obsidian		    = Material(vec3(0.05375, 0.05, 0.06625)		 ,vec3(0.18275, 0.17, 0.22525),			vec3(0.332741, 0.328634, 0.346435),		 0.3, vec3(0.0), false, 0.0);
Material pearl			    = Material(vec3(0.25, 0.20725, 0.20725)		 ,vec3(1.0, 0.829, 0.829),				vec3(0.296648, 0.296648, 0.296648),		 0.088, vec3(0.0), false, 0.0);
Material ruby			      = Material(vec3(0.1745, 0.01175, 0.01175)	 ,vec3(0.61424, 0.04136, 0.04136),		vec3(0.727811, 0.626959, 0.626959),		 0.6, vec3(0.0), false, 0.0);
Material turquoise		  = Material(vec3(0.1, 0.18725, 0.1745)		 ,vec3(0.396, 0.74151, 0.69102),		vec3(0.297254, 0.30829, 0.306678),		 0.1, vec3(0.0), false, 0.0);
Material bronze			    = Material(vec3(0.2125, 0.1275, 0.054),		  vec3(0.714, 0.4284, 0.18144),			vec3(0.393548, 0.271906, 0.166721),		 0.2, vec3(0.0), false, 0.0);
Material chrome			    = Material(vec3(0.25, 0.25, 0.25),			  vec3(0.4, 0.4, 0.4),					vec3(0.774597, 0.774597, 0.774597),		 0.6, vec3(0.0), false, 0.0);
Material copper			    = Material(vec3(0.19125, 0.0735, 0.0225),	  vec3(0.7038, 0.27048, 0.0828),		vec3(0.256777, 0.137622, 0.086014),		 0.1, vec3(0.0), false, 0.0);
Material gold			      = Material(vec3(0.24725, 0.1995, 0.0745),	  vec3(0.75164, 0.60648, 0.22648),		vec3(0.628281, 0.555802, 0.366065),		 0.4, vec3(0.0), false, 0.0);
Material silver			    = Material(vec3(0.19225, 0.19225, 0.19225),	  vec3(0.50754, 0.50754, 0.50754),		vec3(0.508273, 0.508273, 0.508273),		 0.4, vec3(0.0), false, 0.0);
Material black_plastic	= Material(vec3(0.0, 0.0, 0.0),				  vec3(0.01, 0.01, 0.01),				vec3(0.50, 0.50, 0.50),					 0.25, vec3(0.0), false, 0.0);
Material cyan_plastic	  = Material(vec3(0.0, 0.1, 0.06),			  vec3(0.0, 0.50980392, 0.50980392),	vec3(0.50196078, 0.50196078, 0.50196078),0.25, vec3(0.0), false, 0.0);
Material green_plastic	= Material(vec3(0.0, 0.0, 0.0),				  vec3(0.1, 0.35, 0.1),					vec3(0.45, 0.55, 0.45),					 0.25, vec3(0.0), false, 0.0);
Material red_plastic	  = Material(vec3(0.0, 0.0, 0.0),				  vec3(0.5, 0.0, 0.0),					vec3(0.7, 0.6, 0.6),					 0.25, vec3(0.0), false, 0.0);
Material white_plastic  = Material(vec3(0.0, 0.0, 0.0),				  vec3(0.55, 0.55, 0.55),				vec3(0.70, 0.70, 0.70),					 0.25, vec3(0.0), false, 0.0);
Material yellow_plastic = Material(vec3(0.0, 0.0, 0.0),				  vec3(0.5, 0.5, 0.0),					vec3(0.60, 0.60, 0.50),					 0.25, vec3(0.0), false, 0.0);
Material black_rubber   = Material(vec3(0.02, 0.02, 0.02),			  vec3(0.01, 0.01, 0.01),				vec3(0.4, 0.4, 0.4),					 0.078125, vec3(0.0), false, 0.0);
Material cyan_rubber    = Material(vec3(0.0, 0.05, 0.05),			  vec3(0.4, 0.5, 0.5),					vec3(0.04, 0.7, 0.7),					 0.078125, vec3(0.0), false, 0.0);
Material green_rubber	  = Material(vec3(0.0, 0.05, 0.0),			  vec3(0.4, 0.5, 0.4),					vec3(0.04, 0.7, 0.04),					 0.078125, vec3(0.0), false, 0.0);
Material red_rubber		  = Material(vec3(0.05, 0.0, 0.0),			  vec3(0.5, 0.4, 0.4),					vec3(0.7, 0.04, 0.04),					 0.078125, vec3(0.0), false, 0.0);
Material white_rubber	  = Material(vec3(0.05, 0.05, 0.05),			  vec3(0.5, 0.5, 0.5),					vec3(0.7, 0.7, 0.7),					 0.078125, vec3(0.0), false, 0.0);
Material yellow_rubber	= Material(vec3(0.05, 0.05, 0.0),			  vec3(0.5, 0.5, 0.4),					vec3(0.7, 0.7, 0.04),					 0.078125, vec3(0.0), false, 0.0);


Material mixMaterial(Material a, Material b, float x){
  return Material(mix(a.ambient, b.ambient, x),
             mix(a.diffuse, b.diffuse, x),
             mix(a.specular, b.specular, x),
             mix(a.shininess, b.shininess, x),
             mix(a.emissive, b.emissive, x), false, 0.0);
}

Material mixMaterial(Material a, Material b, float x, bool isReflecting){
  return Material(mix(a.ambient, b.ambient, x),
             mix(a.diffuse, b.diffuse, x),
             mix(a.specular, b.specular, x),
             mix(a.shininess, b.shininess, x),
             mix(a.emissive, b.emissive, x), 
			 isReflecting,
			 mix(a.reflectance, b.reflectance, x));
}

SdfPhongResult minop(SdfPhongResult a, SdfPhongResult b){
	if(a.d < b.d) return a; else return b;
}

SdfPbrResult minop(SdfPbrResult a, SdfPbrResult b){
	if(a.d < b.d) return a; else return b;
}