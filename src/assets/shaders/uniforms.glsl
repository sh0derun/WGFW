uniform float time;
uniform vec2 resolution;
uniform float speed;
uniform float fogAmount;
uniform vec3 fogColor;
uniform vec3 camera;
uniform vec3 sphere;
uniform float gamma;
uniform bool overRelaxation;
uniform bool showDisplacements;
uniform vec2 mouse;
uniform bool phongShading;
uniform bool pbrShading;

uniform sampler2D noisetex;

struct TextureData {
  float thickness;
  float frequency;
  float amplitude;
};

struct Ao {
  bool enabled;
  int depth;
};

uniform TextureData textureData;
uniform Ao uao;

//sampler2D textures[1] = sampler2D[](noisetex);