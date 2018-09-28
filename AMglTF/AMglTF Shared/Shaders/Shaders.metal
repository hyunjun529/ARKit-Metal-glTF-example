#include <metal_stdlib>
#include <simd/simd.h>

#import "ShaderTypes.h"

using namespace metal;


constant bool hasColorTexture [[ function_constant(0) ]];
constant bool hasNormalTexture [[ function_constant(1) ]];

typedef struct
{
    float4 position [[ attribute(Position) ]];
    float3 normal [[ attribute(Normal) ]];
    float2 uv [[ attribute(UV) ]];
    float3 tangent [[attribute(Tangent)]];
    float3 bitangent [[attribute(Bitangent)]];
} Vertex;

typedef struct {
    float4 position [[ position ]];
    float3 worldPosition;
    float3 worldNormal;
    float2 uv;
    float3 worldTangent;
    float3 worldBitangent;
} ColorInOut;


vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
{
    ColorInOut out;
    
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    
    out.worldPosition = (uniforms.modelMatrix * in.position).xyz;
    
    out.worldNormal = uniforms.normalMatrix * in.normal;
    
    out.worldTangent = uniforms.normalMatrix * in.tangent;
    
    out.worldBitangent = uniforms.normalMatrix * in.bitangent;
    
    out.uv = in.uv;
    
    return out;
}


fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               constant Light *lights [[ buffer(BufferIndexLights) ]],
                               sampler textureSampler [[ sampler(0) ]],
                               constant Material &material [[ buffer(BufferIndexMaterials)]],
                               texture2d<float> baseColorTexture [[ texture(BaseColorTexture),
                                                                   function_constant(hasColorTexture) ]],
                               texture2d<float> normalTexture [[ texture(NormalTexture),
                                                                function_constant(hasNormalTexture) ]],
                               constant FragmentUniforms &fragmentUniforms [[ buffer(BufferIndexFragmentUniforms) ]],
                               constant uint &tiling [[ buffer(22) ]])
{
    float3 baseColor;
    if (hasColorTexture) {
        baseColor = baseColorTexture.sample(textureSampler,
                                            in.uv * tiling).rgb;
    } else {
        baseColor = material.baseColor;
    }
    
    float materialShininess = material.shininess;
    float3 materialSpecularColor = material.specularColor;
    
    float3 normalValue;
    if (hasNormalTexture) {
        normalValue = normalTexture.sample(textureSampler, in.uv * fragmentUniforms.tiling).rgb;
        normalValue = normalValue * 2 - 1;
    } else {
        normalValue = in.worldNormal;
    }
    normalValue = normalize(normalValue);
    
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    
    float3 normalDirection = in.worldNormal * normalValue.z + in.worldTangent * normalValue.x + in.worldBitangent * normalValue.y;
    
    normalDirection = normalize(normalDirection);
    
    for (uint i = 0; i < fragmentUniforms.lightCount; i++) {
        Light light = lights[i];
        if (light.type == LightTypeSunlight) {
            float3 lightDirection = normalize(light.position);
            float diffuseIntensity =
            saturate(dot(lightDirection, normalDirection));
            diffuseColor += light.color * baseColor * diffuseIntensity;
            if (diffuseIntensity > 0) {
                float3 reflection = reflect(lightDirection, normalDirection); // (R)
                float3 cameraPosition = normalize(in.worldPosition - fragmentUniforms.cameraPosition); // (V)
                float specularIntensity = pow(saturate(dot(reflection, cameraPosition)), materialShininess);
                specularColor += light.specularColor * materialSpecularColor * specularIntensity;
            }
        } else if (light.type == LightTypeAmbientlight) {
            ambientColor += light.color * light.intensity;
        } else if (light.type == LightTypePointlight) {
            float d = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(light.position - in.worldPosition);
            float attenuation = 1.0 / (light.attenuation.x +
                                       light.attenuation.y * d + light.attenuation.z * d * d);
            
            float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
            float3 color = light.color * baseColor * diffuseIntensity;
            color *= attenuation;
            diffuseColor += color;
        } else if (light.type == LightTypeSpotlight) {
            float d = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(light.position - in.worldPosition);
            float3 coneDirection = normalize(-light.coneDirection);
            float spotResult = (dot(lightDirection, coneDirection));
            if (spotResult > cos(light.coneAngle)) {
                float attenuation = 1.0 / (light.attenuation.x +
                                           light.attenuation.y * d + light.attenuation.z * d * d);
                attenuation *= pow(spotResult, light.coneAttenuation);
                float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
                float3 color = light.color * baseColor * diffuseIntensity;
                color *= attenuation;
                diffuseColor += color;
            }
        }
    }
    
    float3 color = diffuseColor + ambientColor + specularColor;
    
    return float4(color, 1);
}

