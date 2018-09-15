#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>


typedef struct
{
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef struct
{
    uint lightCount;
    vector_float3 cameraPosition;
} FragmentUniforms;

typedef NS_ENUM(NSInteger, BufferIndex)
{
    BufferIndexMeshPositions     = 0,
    BufferIndexMeshTexcoord      = 1,
    BufferIndexMeshNormal        = 2,
    BufferIndexLights            = 3,
    BufferIndexUniforms          = 4,
    BufferIndexFragmentUniforms  = 5
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
    VertexAttributePosition  = 0,
    VertexAttributeTexcoord  = 1,
    VertexAttributeNormal    = 2
};

typedef NS_ENUM(NSInteger, TextureIndex)
{
    TextureIndexColor        = 0,
    TextureIndexNormal       = 1
};


// lighting
typedef NS_ENUM(NSInteger, LightType)
{
    LightTypeUnused          = 0,
    LightTypeSunlight        = 1, // Directional light
    LightTypeSpotlight       = 2,
    LightTypePointlight      = 3,
    LightTypeAmbientlight    = 4
};

typedef struct {
    vector_float3 position;  // for a sunlight, this is direction
    vector_float3 color;
    vector_float3 specularColor;
    float intensity;
    vector_float3 attenuation;
    LightType type;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
} Light;

#endif /* ShaderTypes_h */
