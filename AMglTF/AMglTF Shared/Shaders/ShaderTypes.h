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
    uint tiling;
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


// ARKit
// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef enum BufferIndices {
    kBufferIndexMeshPositions    = 0,
    kBufferIndexMeshGenerics     = 1,
    kBufferIndexInstanceUniforms = 2,
    kBufferIndexSharedUniforms   = 3
} BufferIndices;

// Attribute index values shared between shader and C code to ensure Metal shader vertex
//   attribute indices match the Metal API vertex descriptor attribute indices
typedef enum VertexAttributes {
    kVertexAttributePosition  = 0,
    kVertexAttributeTexcoord  = 1,
    kVertexAttributeNormal    = 2
} VertexAttributes;

// Texture index values shared between shader and C code to ensure Metal shader texture indices
//   match indices of Metal API texture set calls
typedef enum TextureIndices {
    kTextureIndexColor    = 0,
    kTextureIndexY        = 1,
    kTextureIndexCbCr     = 2
} TextureIndices;

// Structure shared between shader and C code to ensure the layout of shared uniform data accessed in
//    Metal shaders matches the layout of uniform data set in C code
typedef struct {
    // Camera Uniforms
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    
    // Lighting Properties
    vector_float3 ambientLightColor;
    vector_float3 directionalLightDirection;
    vector_float3 directionalLightColor;
    float materialShininess;
} SharedUniforms;

// Structure shared between shader and C code to ensure the layout of instance uniform data accessed in
//    Metal shaders matches the layout of uniform data set in C code
typedef struct {
    matrix_float4x4 modelMatrix;
} InstanceUniforms;


#endif /* ShaderTypes_h */
