float cross(vec3 p, float size){
    float barx = box(p, vec3(9999.0,size,size));
    float bary = box(p, vec3(size,9999.0,size));
    float barz = box(p, vec3(size,size,9999.0));
    return min(barx,min(bary,barz));
}

vec2 sdf(vec3 p){
    vec3 q = p;
    vec2 plane = vec2(pln(q*rotateX(PI), 0.0),2.0);
    plane.x += abs(noise(textureData.frequency*2.0*q.xz+vec2(time*3.0,0.0))*textureData.amplitude);
    plane.x *= 0.25;
    vec2 sphere = vec2(sp(q, textureData.thickness*1.25),2.0);
    vec2 sea = vec2(box(q-vec3(0.0,0.14,0.0),vec3(textureData.thickness*1.25,0.25,textureData.thickness*1.25)),1.0);
    sphere.x = max(sphere.x,-plane.x);
    sea.x = max(max(sea.x,-sphere.x),sp(q,textureData.thickness*1.25-0.01));
    sphere = sphere.x < sea.x ? sphere : sea;
    return sphere;
}