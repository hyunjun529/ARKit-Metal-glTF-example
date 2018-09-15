// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;


typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
    float3 worldPosition;
    float3 worldNormal;
} ColorInOut;


vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
{
    ColorInOut out;

    float4 position = float4(in.position, 1.0);
    
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * position;

    out.texCoord = in.texCoord;

    out.worldNormal = in.normal;
    
    out.worldPosition = (uniforms.modelMatrix * position).xyz;
    
    return out;
}


fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               constant Light *lights [[ buffer(BufferIndexLights) ]],
                               constant FragmentUniforms &fragmentUniforms [[ buffer(BufferIndexFragmentUniforms) ]])
{
    float3 baseColor = float3(1, 1, 1);
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    float materialShininess = 32;
    float3 materialSpecularColor = float3(1, 1, 1);
    
    float3 normalDirection = normalize(in.worldNormal);
    
    for (uint i = 0; i < fragmentUniforms.lightCount; i++)
    {
        Light light = lights[i];
        
        if (light.type == LightTypeSunlight)
        {
            float3 lightDirection = normalize(light.position);
            float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
            diffuseColor += light.color * baseColor * diffuseIntensity;
            if (diffuseIntensity > 0)
            {
                float3 reflection =
                reflect(lightDirection, normalDirection);
                float3 cameraPosition =
                normalize(in.worldPosition - fragmentUniforms.cameraPosition);
                float specularIntensity =
                pow(saturate(dot(reflection, cameraPosition)), materialShininess);
                specularColor +=
                light.specularColor * materialSpecularColor * specularIntensity;
            }
        }
        else if (light.type == LightTypeAmbientlight)
        {
            ambientColor += light.color * light.intensity;
        }
        
        else if (light.type == LightTypePointlight)
        {
            float d = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(light.position - in.worldPosition);
            float attenuation = 1.0 / (light.attenuation.x +
                                       light.attenuation.y * d + light.attenuation.z * d * d);
            float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
            float3 color = light.color * baseColor * diffuseIntensity;
            color *= attenuation;
            diffuseColor += color;
        }
        
        else if (light.type == LightTypeSpotlight)
        {
            float d = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(light.position - in.worldPosition);
            float3 coneDirection = normalize(-light.coneDirection);
            float spotResult = (dot(lightDirection, coneDirection));
            if (spotResult > cos(light.coneAngle))
            {
                float attenuation = 1.0 / (light.attenuation.x +
                                           light.attenuation.y * d + light.attenuation.z * d * d);
                attenuation *= pow(spotResult, light.coneAttenuation);
                float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
                float3 color = light.color * baseColor * diffuseIntensity;
                color *= attenuation;
                diffuseColor += color;
            }
        }
        else
        {
            diffuseColor = float3(1.0, 0.0, 1.0); // something wrong, display like Unity 5.5+
        }
    }
    
    float3 color = diffuseColor + ambientColor + specularColor;
    
    return float4(color, 1);
}
