#include <metal_stdlib>
using namespace metal;

#import "ShaderTypes.h"


struct VertexOut {
    float4 position [[ position ]];
    float point_size [[ point_size ]];
};

vertex VertexOut vertexLight( constant float3 *vertices [[ buffer(0) ]],
                              constant Uniforms &uniforms [[ buffer(BufferIndexUniforms) ]],
                              uint id [[vertex_id]])
{
    VertexOut out;
    matrix_float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix;
    out.position = mvp * float4(vertices[id], 1);
    out.point_size = 20.0;
    return out;
}

fragment float4 fragmentLight(float2 point [[ point_coord]],
                              constant float3 &color [[ buffer(1) ]]) {
    float d = distance(point, float2(0.5, 0.5));
    if (d > 0.5) {
        discard_fragment();
    }
    return float4(color ,1);
}

