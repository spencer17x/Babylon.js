import { Effect } from "../Materials/effect";

let name = 'spriteMapPixelShader';
let shader = `precision highp float;
varying vec3 vPosition;
varying vec2 vUV;
varying vec2 tUV;
uniform float time;
uniform float spriteCount;
uniform sampler2D spriteSheet;
uniform vec2 spriteMapSize;
uniform vec2 outputSize;
uniform vec2 stageSize;
uniform float maxAnimationFrames;
uniform sampler2D frameMap;
uniform sampler2D tileMaps[LAYERS];
uniform sampler2D animationMap;
uniform vec3 colorMul;
#ifdef EDITABLE
uniform vec2 mousePosition;
uniform float curTile;
#endif
float mt;
float fdStep=1./4.;
mat4 getFrameData(float frameID){
float fX=frameID/spriteCount;
return mat4(
texture(frameMap,vec2(fX,0.),0.),
texture(frameMap,vec2(fX,fdStep*1.),0.),
texture(frameMap,vec2(fX,fdStep*2.),0.),
vec4(0.)
);
}
void main(){
vec4 color=vec4(0.);
vec2 tileUV=fract(tUV);
#ifdef FLIPU
tileUV.y=1.0-tileUV.y;
#endif
vec2 tileID=floor(tUV);
vec2 sheetUnits=1./spriteMapSize;
float spriteUnits=1./spriteCount;
vec2 stageUnits=1./stageSize;
for(int i=0; i<LAYERS; i++){
float frameID=texture(tileMaps[i],(tileID+0.5)/stageSize,0.).x;
vec4 animationData=texture(animationMap,vec2((frameID+0.5)/spriteCount,0.),0.);
if(animationData.y>0.){
mt=mod(time*animationData.z,1.0);
float aFrameSteps=1./maxAnimationFrames;
for(float f=0.; f<maxAnimationFrames; f++){
if(animationData.y>mt){
frameID=animationData.x;
break;
}
animationData=texture(animationMap,vec2((frameID+0.5)/spriteCount,aFrameSteps*f),0.);
}
}

mat4 frameData=getFrameData(frameID+0.5);
vec2 frameSize=(frameData[0].wz)/spriteMapSize;
vec2 offset=frameData[0].xy*sheetUnits;
vec2 ratio=frameData[2].xy/frameData[0].wz;

if(frameData[2].z == 1.){
tileUV.xy=tileUV.yx;
}
if(i == 0){
color=texture(spriteSheet,tileUV*frameSize+offset);
} else {
vec4 nc=texture(spriteSheet,tileUV*frameSize+offset);
float alpha=min(color.a+nc.a,1.0);
vec3 mixed=mix(color.xyz,nc.xyz,nc.a);
color=vec4(mixed,alpha);
}
}
color.xyz*=colorMul;
#ifdef EDITABLE
if(tileID == floor(mousePosition*stageSize)){
vec2 eUV=fract(tUV);
#ifdef FLIPU
eUV.y=1.0-eUV.y;
#endif
mat4 eframeData=getFrameData(curTile+0.5);
vec2 eframeSize=(eframeData[0].wz)/spriteMapSize;
vec2 eoffset=eframeData[0].xy*sheetUnits;
vec2 eratio=eframeData[2].xy/eframeData[0].wz;

if(eframeData[2].z == 1.){
eUV.xy=eUV.yx;
}
vec4 nt=texture(spriteSheet,eUV*eframeSize+eoffset);
color.a=max(max(color.a ,0.5),nt.a*0.5);
color.rgb=mix(color.rgb,nt.rgb,0.85);
color.r*=2.5;
color.g*=2.5;
color.b*=0.5;
}
#endif
gl_FragColor=color;
}`;

Effect.ShadersStore[name] = shader;
/** @hidden */
export var spriteMapPixelShader = { name, shader };
