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
    BufferIndexMeshPositions = 0,
    BufferIndexMeshTexcoord  = 1,
    BufferIndexMeshNormal    = 2,
    BufferIndexUniforms      = 3
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


#endif /* ShaderTypes_h */
