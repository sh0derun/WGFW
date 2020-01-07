# WGFW

This project is about an angular directive that allow creative coders and shader coders to code theirs 3D scenes using the famous sphere tracing rendering technique. 

The only thing that the coders needs to do is implementing the distance function of the scene that he wants to render, and specify material identifier of each object in order to shade objects in a unique way.

Coders can find in the glsl library lot of utility functions that allow coders to apply some operators to 3D object(union, intersection, substraction, domain repetition, ...).

There is a rish list of materials in a glsl file that can be used when shading te scene. Note that currently, their is two shading techniques that were already implemented namely Phong Shading and Physically Based Rendering Shading(pbr).

GUIs are implemented using dat.gui library.

**Disclaimer : _Only modern browsers that supports webgl2 can run this project !_**

those are some screenshots of some running demos:

![wgfw1](images/wgfw1.PNG)

![wgfw1](images/wgfw2.PNG)

![wgfw1](images/wgfw3.PNG)

![wgfw1](images/wgfw4.PNG)
