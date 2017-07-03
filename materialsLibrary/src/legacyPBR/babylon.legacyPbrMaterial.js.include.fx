BABYLON.Effect.IncludesShadersStore['legacyPbrFragmentDeclaration'] = "uniform vec3 vReflectionColor;\nuniform vec4 vAlbedoColor;\n\nuniform vec4 vLightingIntensity;\n#ifdef OVERLOADEDVALUES\nuniform vec4 vOverloadedIntensity;\nuniform vec3 vOverloadedAmbient;\nuniform vec3 vOverloadedAlbedo;\nuniform vec3 vOverloadedReflectivity;\nuniform vec3 vOverloadedEmissive;\nuniform vec3 vOverloadedReflection;\nuniform vec3 vOverloadedMicroSurface;\n#endif\n#ifdef OVERLOADEDSHADOWVALUES\nuniform vec4 vOverloadedShadowIntensity;\n#endif\n#if defined(REFLECTION) || defined(REFRACTION)\nuniform vec2 vMicrosurfaceTextureLods;\n#endif\nuniform vec4 vReflectivityColor;\nuniform vec3 vEmissiveColor;\n\n#ifdef ALBEDO\nuniform vec2 vAlbedoInfos;\n#endif\n#ifdef AMBIENT\nuniform vec3 vAmbientInfos;\n#endif\n#ifdef BUMP\nuniform vec3 vBumpInfos;\n#endif\n#ifdef OPACITY \nuniform vec2 vOpacityInfos;\n#endif\n#ifdef EMISSIVE\nuniform vec2 vEmissiveInfos;\n#endif\n#ifdef LIGHTMAP\nuniform vec2 vLightmapInfos;\n#endif\n#if defined(REFLECTIVITY) || defined(METALLICWORKFLOW) \nuniform vec3 vReflectivityInfos;\n#endif\n#ifdef MICROSURFACEMAP\nuniform vec2 vMicroSurfaceSamplerInfos;\n#endif\n#ifdef OPACITYFRESNEL\nuniform vec4 opacityParts;\n#endif\n#ifdef EMISSIVEFRESNEL\nuniform vec4 emissiveLeftColor;\nuniform vec4 emissiveRightColor;\n#endif\n\n#if defined(REFLECTIONMAP_SPHERICAL) || defined(REFLECTIONMAP_PROJECTION) || defined(REFRACTION)\nuniform mat4 view;\n#endif\n\n#ifdef REFRACTION\nuniform vec4 vRefractionInfos;\n#ifdef REFRACTIONMAP_3D\n#else\nuniform mat4 refractionMatrix;\n#endif\n#endif\n\n#ifdef REFLECTION\nuniform vec2 vReflectionInfos;\n#ifdef REFLECTIONMAP_SKYBOX\n#else\n#if defined(REFLECTIONMAP_PLANAR) || defined(REFLECTIONMAP_CUBIC) || defined(REFLECTIONMAP_PROJECTION)\nuniform mat4 reflectionMatrix;\n#endif\n#endif\n#endif";
BABYLON.Effect.IncludesShadersStore['legacyPbrFunctions'] = "\n#define RECIPROCAL_PI2 0.15915494\n#define FRESNEL_MAXIMUM_ON_ROUGH 0.25\n\nconst float kPi=3.1415926535897932384626433832795;\nconst float kRougnhessToAlphaScale=0.1;\nconst float kRougnhessToAlphaOffset=0.29248125;\nfloat Square(float value)\n{\nreturn value*value;\n}\nfloat getLuminance(vec3 color)\n{\nreturn clamp(dot(color,vec3(0.2126,0.7152,0.0722)),0.,1.);\n}\nfloat convertRoughnessToAverageSlope(float roughness)\n{\n\nconst float kMinimumVariance=0.0005;\nfloat alphaG=Square(roughness)+kMinimumVariance;\nreturn alphaG;\n}\n\nfloat getMipMapIndexFromAverageSlope(float maxMipLevel,float alpha)\n{\n\n\n\n\n\n\n\nfloat mip=kRougnhessToAlphaOffset+maxMipLevel+(maxMipLevel*kRougnhessToAlphaScale*log2(alpha));\nreturn clamp(mip,0.,maxMipLevel);\n}\nfloat getMipMapIndexFromAverageSlopeWithPMREM(float maxMipLevel,float alphaG)\n{\nfloat specularPower=clamp(2./alphaG-2.,0.000001,2048.);\n\nreturn clamp(- 0.5*log2(specularPower)+5.5,0.,maxMipLevel);\n}\n\nfloat smithVisibilityG1_TrowbridgeReitzGGX(float dot,float alphaG)\n{\nfloat tanSquared=(1.0-dot*dot)/(dot*dot);\nreturn 2.0/(1.0+sqrt(1.0+alphaG*alphaG*tanSquared));\n}\nfloat smithVisibilityG_TrowbridgeReitzGGX_Walter(float NdotL,float NdotV,float alphaG)\n{\nreturn smithVisibilityG1_TrowbridgeReitzGGX(NdotL,alphaG)*smithVisibilityG1_TrowbridgeReitzGGX(NdotV,alphaG);\n}\n\n\nfloat normalDistributionFunction_TrowbridgeReitzGGX(float NdotH,float alphaG)\n{\n\n\n\nfloat a2=Square(alphaG);\nfloat d=NdotH*NdotH*(a2-1.0)+1.0;\nreturn a2/(kPi*d*d);\n}\nvec3 fresnelSchlickGGX(float VdotH,vec3 reflectance0,vec3 reflectance90)\n{\nreturn reflectance0+(reflectance90-reflectance0)*pow(clamp(1.0-VdotH,0.,1.),5.0);\n}\nvec3 FresnelSchlickEnvironmentGGX(float VdotN,vec3 reflectance0,vec3 reflectance90,float smoothness)\n{\n\nfloat weight=mix(FRESNEL_MAXIMUM_ON_ROUGH,1.0,smoothness);\nreturn reflectance0+weight*(reflectance90-reflectance0)*pow(clamp(1.0-VdotN,0.,1.),5.0);\n}\n\nvec3 computeSpecularTerm(float NdotH,float NdotL,float NdotV,float VdotH,float roughness,vec3 specularColor,vec3 reflectance90)\n{\nfloat alphaG=convertRoughnessToAverageSlope(roughness);\nfloat distribution=normalDistributionFunction_TrowbridgeReitzGGX(NdotH,alphaG);\nfloat visibility=smithVisibilityG_TrowbridgeReitzGGX_Walter(NdotL,NdotV,alphaG);\nvisibility/=(4.0*NdotL*NdotV); \nvec3 fresnel=fresnelSchlickGGX(VdotH,specularColor,reflectance90);\nfloat specTerm=max(0.,visibility*distribution)*NdotL;\nreturn fresnel*specTerm*kPi; \n}\nfloat computeDiffuseTerm(float NdotL,float NdotV,float VdotH,float roughness)\n{\n\n\nfloat diffuseFresnelNV=pow(clamp(1.0-NdotL,0.000001,1.),5.0);\nfloat diffuseFresnelNL=pow(clamp(1.0-NdotV,0.000001,1.),5.0);\nfloat diffuseFresnel90=0.5+2.0*VdotH*VdotH*roughness;\nfloat diffuseFresnelTerm =\n(1.0+(diffuseFresnel90-1.0)*diffuseFresnelNL) *\n(1.0+(diffuseFresnel90-1.0)*diffuseFresnelNV);\nreturn diffuseFresnelTerm*NdotL;\n\n\n}\nfloat adjustRoughnessFromLightProperties(float roughness,float lightRadius,float lightDistance)\n{\n#ifdef USEPHYSICALLIGHTFALLOFF\n\nfloat lightRoughness=lightRadius/lightDistance;\n\nfloat totalRoughness=clamp(lightRoughness+roughness,0.,1.);\nreturn totalRoughness;\n#else\nreturn roughness;\n#endif\n}\nfloat computeDefaultMicroSurface(float microSurface,vec3 reflectivityColor)\n{\nfloat kReflectivityNoAlphaWorkflow_SmoothnessMax=0.95;\nfloat reflectivityLuminance=getLuminance(reflectivityColor);\nfloat reflectivityLuma=sqrt(reflectivityLuminance);\nmicroSurface=reflectivityLuma*kReflectivityNoAlphaWorkflow_SmoothnessMax;\nreturn microSurface;\n}\nvec3 toLinearSpace(vec3 color)\n{\nreturn vec3(pow(color.r,2.2),pow(color.g,2.2),pow(color.b,2.2));\n}\nvec3 toGammaSpace(vec3 color)\n{\nreturn vec3(pow(color.r,1.0/2.2),pow(color.g,1.0/2.2),pow(color.b,1.0/2.2));\n}\n#ifdef CAMERATONEMAP\nvec3 toneMaps(vec3 color)\n{\ncolor=max(color,0.0);\n\ncolor.rgb=color.rgb*vCameraInfos.x;\nfloat tuning=1.5; \n\n\nvec3 tonemapped=1.0-exp2(-color.rgb*tuning); \ncolor.rgb=mix(color.rgb,tonemapped,1.0);\nreturn color;\n}\n#endif\n#ifdef CAMERACONTRAST\nvec4 contrasts(vec4 color)\n{\ncolor=clamp(color,0.0,1.0);\nvec3 resultHighContrast=color.rgb*color.rgb*(3.0-2.0*color.rgb);\nfloat contrast=vCameraInfos.y;\nif (contrast<1.0)\n{\n\ncolor.rgb=mix(vec3(0.5,0.5,0.5),color.rgb,contrast);\n}\nelse\n{\n\ncolor.rgb=mix(color.rgb,resultHighContrast,contrast-1.0);\n}\nreturn color;\n}\n#endif";
BABYLON.Effect.IncludesShadersStore['legacyPbrLightFunctions'] = "\nstruct lightingInfo\n{\nvec3 diffuse;\n#ifdef SPECULARTERM\nvec3 specular;\n#endif\n};\nfloat computeDistanceLightFalloff(vec3 lightOffset,float lightDistanceSquared,float range)\n{ \n#ifdef USEPHYSICALLIGHTFALLOFF\nfloat lightDistanceFalloff=1.0/((lightDistanceSquared+0.0001));\n#else\nfloat lightDistanceFalloff=max(0.,1.0-length(lightOffset)/range);\n#endif\nreturn lightDistanceFalloff;\n}\nfloat computeDirectionalLightFalloff(vec3 lightDirection,vec3 directionToLightCenterW,float lightAngle,float exponent)\n{\nfloat falloff=0.0;\n#ifdef USEPHYSICALLIGHTFALLOFF\nfloat cosHalfAngle=cos(lightAngle*0.5);\nconst float kMinusLog2ConeAngleIntensityRatio=6.64385618977; \n\n\n\n\n\nfloat concentrationKappa=kMinusLog2ConeAngleIntensityRatio/(1.0-cosHalfAngle);\n\n\nvec4 lightDirectionSpreadSG=vec4(-lightDirection*concentrationKappa,-concentrationKappa);\nfalloff=exp2(dot(vec4(directionToLightCenterW,1.0),lightDirectionSpreadSG));\n#else\nfloat cosAngle=max(0.000000000000001,dot(-lightDirection,directionToLightCenterW));\nif (cosAngle>=lightAngle)\n{\nfalloff=max(0.,pow(cosAngle,exponent));\n}\n#endif\nreturn falloff;\n}\nlightingInfo computeLighting(vec3 viewDirectionW,vec3 vNormal,vec4 lightData,vec3 diffuseColor,vec3 specularColor,float rangeRadius,float roughness,float NdotV,vec3 reflectance90,out float NdotL) {\nlightingInfo result;\nvec3 lightDirection;\nfloat attenuation=1.0;\nfloat lightDistance;\n\nif (lightData.w == 0.)\n{\nvec3 lightOffset=lightData.xyz-vPositionW;\nfloat lightDistanceSquared=dot(lightOffset,lightOffset);\nattenuation=computeDistanceLightFalloff(lightOffset,lightDistanceSquared,rangeRadius);\nlightDistance=sqrt(lightDistanceSquared);\nlightDirection=normalize(lightOffset);\n}\n\nelse\n{\nlightDistance=length(-lightData.xyz);\nlightDirection=normalize(-lightData.xyz);\n}\n\nroughness=adjustRoughnessFromLightProperties(roughness,rangeRadius,lightDistance);\n\nvec3 H=normalize(viewDirectionW+lightDirection);\nNdotL=max(0.00000000001,dot(vNormal,lightDirection));\nfloat VdotH=clamp(0.00000000001,1.0,dot(viewDirectionW,H));\nfloat diffuseTerm=computeDiffuseTerm(NdotL,NdotV,VdotH,roughness);\nresult.diffuse=diffuseTerm*diffuseColor*attenuation;\n#ifdef SPECULARTERM\n\nfloat NdotH=max(0.00000000001,dot(vNormal,H));\nvec3 specTerm=computeSpecularTerm(NdotH,NdotL,NdotV,VdotH,roughness,specularColor,reflectance90);\nresult.specular=specTerm*attenuation;\n#endif\nreturn result;\n}\nlightingInfo computeSpotLighting(vec3 viewDirectionW,vec3 vNormal,vec4 lightData,vec4 lightDirection,vec3 diffuseColor,vec3 specularColor,float rangeRadius,float roughness,float NdotV,vec3 reflectance90,out float NdotL) {\nlightingInfo result;\nvec3 lightOffset=lightData.xyz-vPositionW;\nvec3 directionToLightCenterW=normalize(lightOffset);\n\nfloat lightDistanceSquared=dot(lightOffset,lightOffset);\nfloat attenuation=computeDistanceLightFalloff(lightOffset,lightDistanceSquared,rangeRadius);\n\nfloat directionalAttenuation=computeDirectionalLightFalloff(lightDirection.xyz,directionToLightCenterW,lightDirection.w,lightData.w);\nattenuation*=directionalAttenuation;\n\nfloat lightDistance=sqrt(lightDistanceSquared);\nroughness=adjustRoughnessFromLightProperties(roughness,rangeRadius,lightDistance);\n\nvec3 H=normalize(viewDirectionW+directionToLightCenterW);\nNdotL=max(0.00000000001,dot(vNormal,directionToLightCenterW));\nfloat VdotH=clamp(dot(viewDirectionW,H),0.00000000001,1.0);\nfloat diffuseTerm=computeDiffuseTerm(NdotL,NdotV,VdotH,roughness);\nresult.diffuse=diffuseTerm*diffuseColor*attenuation;\n#ifdef SPECULARTERM\n\nfloat NdotH=max(0.00000000001,dot(vNormal,H));\nvec3 specTerm=computeSpecularTerm(NdotH,NdotL,NdotV,VdotH,roughness,specularColor,reflectance90);\nresult.specular=specTerm*attenuation;\n#endif\nreturn result;\n}\nlightingInfo computeHemisphericLighting(vec3 viewDirectionW,vec3 vNormal,vec4 lightData,vec3 diffuseColor,vec3 specularColor,vec3 groundColor,float roughness,float NdotV,vec3 reflectance90,out float NdotL) {\nlightingInfo result;\n\n\n\nNdotL=dot(vNormal,lightData.xyz)*0.5+0.5;\nresult.diffuse=mix(groundColor,diffuseColor,NdotL);\n#ifdef SPECULARTERM\n\nvec3 lightVectorW=normalize(lightData.xyz);\nvec3 H=normalize(viewDirectionW+lightVectorW);\nfloat NdotH=max(0.00000000001,dot(vNormal,H));\nNdotL=max(0.00000000001,NdotL);\nfloat VdotH=clamp(0.00000000001,1.0,dot(viewDirectionW,H));\nvec3 specTerm=computeSpecularTerm(NdotH,NdotL,NdotV,VdotH,roughness,specularColor,reflectance90);\nresult.specular=specTerm;\n#endif\nreturn result;\n}";
BABYLON.Effect.IncludesShadersStore['legacyPbrLightFunctionsCall'] = "#ifdef LIGHT{X}\n#if defined(LIGHTMAP) && defined(LIGHTMAPEXCLUDED{X}) && defined(LIGHTMAPNOSPECULAR{X})\n\n#else\n#ifdef SPOTLIGHT{X}\ninfo=computeSpotLighting(viewDirectionW,normalW,light{X}.vLightData,light{X}.vLightDirection,light{X}.vLightDiffuse.rgb,light{X}.vLightSpecular,light{X}.vLightDiffuse.a,roughness,NdotV,specularEnvironmentR90,NdotL);\n#endif\n#ifdef HEMILIGHT{X}\ninfo=computeHemisphericLighting(viewDirectionW,normalW,light{X}.vLightData,light{X}.vLightDiffuse.rgb,light{X}.vLightSpecular,light{X}.vLightGround,roughness,NdotV,specularEnvironmentR90,NdotL);\n#endif\n#if defined(POINTLIGHT{X}) || defined(DIRLIGHT{X})\ninfo=computeLighting(viewDirectionW,normalW,light{X}.vLightData,light{X}.vLightDiffuse.rgb,light{X}.vLightSpecular,light{X}.vLightDiffuse.a,roughness,NdotV,specularEnvironmentR90,NdotL);\n#endif\n#endif\n#ifdef SHADOW{X}\n#ifdef SHADOWESM{X}\n#if defined(SHADOWCUBE{X})\nnotShadowLevel=computeShadowWithESMCube(light{X}.vLightData.xyz,shadowSampler{X},light{X}.shadowsInfo.x,light{X}.shadowsInfo.z,light{X}.depthValues);\n#else\nnotShadowLevel=computeShadowWithESM(vPositionFromLight{X},vDepthMetric{X},shadowSampler{X},light{X}.shadowsInfo.x,light{X}.shadowsInfo.z);\n#endif\n#else\n#ifdef SHADOWPCF{X}\n#if defined(SHADOWCUBE{X})\nnotShadowLevel=computeShadowWithPCFCube(light{X}.vLightData.xyz,shadowSampler{X},light{X}.shadowsInfo.y,light{X}.shadowsInfo.x,light{X}.depthValues);\n#else\nnotShadowLevel=computeShadowWithPCF(vPositionFromLight{X},vDepthMetric{X},shadowSampler{X},light{X}.shadowsInfo.y,light{X}.shadowsInfo.x);\n#endif\n#else\n#if defined(SHADOWCUBE{X})\nnotShadowLevel=computeShadowCube(light{X}.vLightData.xyz,shadowSampler{X},light{X}.shadowsInfo.x,light{X}.depthValues);\n#else\nnotShadowLevel=computeShadow(vPositionFromLight{X},vDepthMetric{X},shadowSampler{X},light{X}.shadowsInfo.x);\n#endif\n#endif\n#endif\n#else\nnotShadowLevel=1.;\n#endif\n#if defined(LIGHTMAP) && defined(LIGHTMAPEXCLUDED{X})\nlightDiffuseContribution+=lightmapColor*notShadowLevel;\n#ifdef SPECULARTERM\n#ifndef LIGHTMAPNOSPECULAR{X}\nlightSpecularContribution+=info.specular*notShadowLevel*lightmapColor;\n#endif\n#endif\n#else\nlightDiffuseContribution+=info.diffuse*notShadowLevel;\n#ifdef OVERLOADEDSHADOWVALUES\nif (NdotL<0.000000000011)\n{\nnotShadowLevel=1.;\n}\nshadowedOnlyLightDiffuseContribution*=notShadowLevel;\n#endif\n#ifdef SPECULARTERM\nlightSpecularContribution+=info.specular*notShadowLevel;\n#endif\n#endif\n#endif";
BABYLON.Effect.IncludesShadersStore['legacyPbrUboDeclaration'] = "layout(std140,column_major) uniform;\nuniform Material\n{\nuniform vec2 vAlbedoInfos;\nuniform vec3 vAmbientInfos;\nuniform vec2 vOpacityInfos;\nuniform vec2 vEmissiveInfos;\nuniform vec2 vLightmapInfos;\nuniform vec3 vReflectivityInfos;\nuniform vec2 vMicroSurfaceSamplerInfos;\nuniform vec4 vRefractionInfos;\nuniform vec2 vReflectionInfos;\nuniform vec3 vBumpInfos;\nuniform mat4 albedoMatrix;\nuniform mat4 ambientMatrix;\nuniform mat4 opacityMatrix;\nuniform mat4 emissiveMatrix;\nuniform mat4 lightmapMatrix;\nuniform mat4 reflectivityMatrix;\nuniform mat4 microSurfaceSamplerMatrix;\nuniform mat4 bumpMatrix;\nuniform mat4 refractionMatrix;\nuniform mat4 reflectionMatrix;\nuniform vec3 vReflectionColor;\nuniform vec4 vAlbedoColor;\nuniform vec4 vLightingIntensity;\nuniform vec2 vMicrosurfaceTextureLods;\nuniform vec4 vReflectivityColor;\nuniform vec3 vEmissiveColor;\nuniform vec4 opacityParts;\nuniform vec4 emissiveLeftColor;\nuniform vec4 emissiveRightColor;\nuniform vec4 vOverloadedIntensity;\nuniform vec3 vOverloadedAmbient;\nuniform vec3 vOverloadedAlbedo;\nuniform vec3 vOverloadedReflectivity;\nuniform vec3 vOverloadedEmissive;\nuniform vec3 vOverloadedReflection;\nuniform vec3 vOverloadedMicroSurface;\nuniform vec4 vOverloadedShadowIntensity;\nuniform float pointSize;\n};\nuniform Scene {\nmat4 viewProjection;\nmat4 view;\n};";
BABYLON.Effect.IncludesShadersStore['legacyPbrVertexDeclaration'] = "uniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef ALBEDO\nuniform mat4 albedoMatrix;\nuniform vec2 vAlbedoInfos;\n#endif\n#ifdef AMBIENT\nuniform mat4 ambientMatrix;\nuniform vec3 vAmbientInfos;\n#endif\n#ifdef OPACITY\nuniform mat4 opacityMatrix;\nuniform vec2 vOpacityInfos;\n#endif\n#ifdef EMISSIVE\nuniform vec2 vEmissiveInfos;\nuniform mat4 emissiveMatrix;\n#endif\n#ifdef LIGHTMAP\nuniform vec2 vLightmapInfos;\nuniform mat4 lightmapMatrix;\n#endif\n#if defined(REFLECTIVITY) || defined(METALLICWORKFLOW) \nuniform vec3 vReflectivityInfos;\nuniform mat4 reflectivityMatrix;\n#endif\n#ifdef MICROSURFACEMAP\nuniform vec2 vMicroSurfaceSamplerInfos;\nuniform mat4 microSurfaceSamplerMatrix;\n#endif\n#ifdef BUMP\nuniform vec3 vBumpInfos;\nuniform mat4 bumpMatrix;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n";
BABYLON.Effect.IncludesShadersStore['legacyColorCurves'] = "const vec3 HDTVRec709_RGBLuminanceCoefficients=vec3(0.2126,0.7152,0.0722);\nvec3 applyColorCurves(vec3 original) {\nvec3 result=original;\n\n\n\nfloat luma=dot(result.rgb,HDTVRec709_RGBLuminanceCoefficients);\nvec2 curveMix=clamp(vec2(luma*3.0-1.5,luma*-3.0+1.5),vec2(0.0,0.0),vec2(1.0,1.0));\nvec4 colorCurve=vCameraColorCurveNeutral+curveMix.x*vCameraColorCurvePositive-curveMix.y*vCameraColorCurveNegative;\nresult.rgb*=colorCurve.rgb;\nresult.rgb=mix(vec3(luma,luma,luma),result.rgb,colorCurve.a);\nreturn result;\n}";
BABYLON.Effect.IncludesShadersStore['legacyColorCurvesDefinition'] = "uniform vec4 vCameraColorCurveNeutral;\nuniform vec4 vCameraColorCurvePositive;\nuniform vec4 vCameraColorCurveNegative;";
BABYLON.Effect.IncludesShadersStore['legacyColorGrading'] = "vec4 colorGrades(vec4 color) \n{ \n\nfloat sliceContinuous=color.z*vCameraColorGradingInfos.z;\nfloat sliceInteger=floor(sliceContinuous);\n\n\nfloat sliceFraction=sliceContinuous-sliceInteger; \n\nvec2 sliceUV=color.xy*vCameraColorGradingScaleOffset.xy+vCameraColorGradingScaleOffset.zw;\n\n\nsliceUV.x+=sliceInteger*vCameraColorGradingInfos.w;\nvec4 slice0Color=texture2D(cameraColorGrading2DSampler,sliceUV);\nsliceUV.x+=vCameraColorGradingInfos.w;\nvec4 slice1Color=texture2D(cameraColorGrading2DSampler,sliceUV);\nvec3 result=mix(slice0Color.rgb,slice1Color.rgb,sliceFraction);\ncolor.rgb=mix(color.rgb,result,vCameraColorGradingInfos.x);\nreturn color;\n}";
BABYLON.Effect.IncludesShadersStore['legacyColorGradingDefinition'] = "uniform sampler2D cameraColorGrading2DSampler;\nuniform vec4 vCameraColorGradingInfos;\nuniform vec4 vCameraColorGradingScaleOffset;";
