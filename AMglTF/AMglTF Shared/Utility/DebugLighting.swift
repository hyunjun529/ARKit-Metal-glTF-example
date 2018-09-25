import MetalKit

/**
 debug drawing
 
 but current not using this function
 
 need to move Scene - Node - light
 */
extension Renderer {
    
    func buildLightPipelineState() -> MTLRenderPipelineState {
        let library = Renderer.device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertexLight")
        let fragmentFunction = library?.makeFunction(name: "fragmentLight")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = Renderer.depthStencilPixelFormat
        pipelineDescriptor.stencilAttachmentPixelFormat = Renderer.depthStencilPixelFormat
        
        let lightPipelineState: MTLRenderPipelineState
        do {
            lightPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return lightPipelineState
    }
    
    
//    func debugLights(renderEncoder: MTLRenderCommandEncoder, lightType: LightType) {
//        for light in lights where light.type == lightType {
//            switch light.type {
//            case LightType.pointlight:
//                drawPointLight(renderEncoder: renderEncoder, position: light.position,
//                               color: light.color)
//            case LightType.spotlight:
//                drawPointLight(renderEncoder: renderEncoder, position: light.position,
//                               color: light.color)
//                
//                // leave this commented until you define spotlights
//                drawSpotLight(renderEncoder: renderEncoder, position: light.position,
//                              direction: light.coneDirection, color: light.color)
//            case LightType.sunlight:
//                drawDirectionalLight(renderEncoder: renderEncoder, direction: light.position,
//                                     color: float3(1, 0, 0), count: 5)
//            default:
//                break
//            }
//        }
//    }
    
    
    func drawPointLight(renderEncoder: MTLRenderCommandEncoder, position: float3, color: float3) {
        var vertices = [position]
        let buffer = Renderer.device.makeBuffer(bytes: &vertices,
                                                length: MemoryLayout<float3>.stride * vertices.count,
                                                options: [])
        dynamicBuffer.uniforms[dynamicBuffer.uniformBufferIndex].modelMatrix = float4x4.identity()
        renderEncoder.setVertexBytes(&dynamicBuffer.uniforms,
                                     length: MemoryLayout<Uniforms>.stride, index: 1)
        var lightColor = color
        renderEncoder.setFragmentBytes(&lightColor, length: MemoryLayout<float3>.stride, index: 1)
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        renderEncoder.setRenderPipelineState(buildLightPipelineState())
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0,
                                     vertexCount: vertices.count)
        
    }
    
    func drawDirectionalLight (renderEncoder: MTLRenderCommandEncoder,
                               direction: float3,
                               color: float3, count: Int) {
        var vertices: [float3] = []
        for i in -count..<count {
            let value = Float(i) * 0.4
            vertices.append(float3(value, 0, value))
            vertices.append(float3(direction.x+value, direction.y, direction.z+value))
        }
        
        let buffer = Renderer.device.makeBuffer(bytes: &vertices,
                                                length: MemoryLayout<float3>.stride * vertices.count,
                                                options: [])
        dynamicBuffer.uniforms[dynamicBuffer.uniformBufferIndex].modelMatrix = float4x4.identity()
        renderEncoder.setVertexBytes(&dynamicBuffer.uniforms,
                                     length: MemoryLayout<Uniforms>.stride, index: 1)
        var lightColor = color
        renderEncoder.setFragmentBytes(&lightColor, length: MemoryLayout<float3>.stride, index: 1)
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        renderEncoder.setRenderPipelineState(buildLightPipelineState())
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0,
                                     vertexCount: vertices.count)
        
    }
    
    func drawSpotLight(renderEncoder: MTLRenderCommandEncoder, position: float3, direction: float3, color: float3) {
        var vertices: [float3] = []
        vertices.append(position)
        vertices.append(float3(position.x + direction.x, position.y + direction.y, position.z + direction.z))
        let buffer = Renderer.device.makeBuffer(bytes: &vertices,
                                                length: MemoryLayout<float3>.stride * vertices.count,
                                                options: [])
        dynamicBuffer.uniforms[dynamicBuffer.uniformBufferIndex].modelMatrix = float4x4.identity()
        renderEncoder.setVertexBytes(&dynamicBuffer.uniforms,
                                     length: MemoryLayout<Uniforms>.stride, index: 1)
        var lightColor = color
        renderEncoder.setFragmentBytes(&lightColor, length: MemoryLayout<float3>.stride, index: 1)
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        renderEncoder.setRenderPipelineState(buildLightPipelineState())
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0,
                                     vertexCount: vertices.count)
    }
    
    
}

