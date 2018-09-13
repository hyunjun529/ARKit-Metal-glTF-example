#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>


// MVP, Uniforms, Vertex, Buffer ... etc
typedef struct
{
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef NS_ENUM(NSInteger, BufferIndex)
{
    BufferIndexMeshPositions = 0,
    BufferIndexMeshGenerics  = 1,
    BufferIndexUniforms2     = 2
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
    VertexAttributePosition  = 0,
    VertexAttributeTexcoord  = 1,
};

typedef NS_ENUM(NSInteger, TextureIndex)
{
    TextureIndexColor    = 0,
    TextureIndexNormal        = 1
};


// Lighting
typedef NS_ENUM(NSInteger, LightType)
{
    unused          = 0,
    Sunlight        = 1,
    Spotlight       = 2,
    Pointlight      = 3,
    Ambientlight    = 4
};

typedef struct {
    uint lightCount;
    vector_float3 cameraPosition;
    uint tiling;
} FragmentUniforms;

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

// blinn-phong
typedef struct {
    vector_float3 baseColor;
    vector_float3 specularColor;
    float roughness;
    float metalness;
    vector_float3 ambientOcclusion;
    float shininess;
} Material;


// Character
typedef enum {
    BufferIndexVertices = 0,
    BufferIndexUniforms = 11,
    BufferIndexLights = 12,
    BufferIndexFragmentUniforms = 13,
    BufferIndexMaterials = 14
} BufferIndices;

typedef enum {
    Position = 0,
    Normal = 1,
    UV = 2,
    Tangent = 3,
    Bitangent = 4,
    Color = 5,
    Joints = 6,
    Weights = 7
} Attributes;


#endif /* ShaderTypes_h */

