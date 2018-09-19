import Metal


/**
 Dynamic Buffer for Tirple Buffering,
 
 Dynamic buffer data refers to frequently updated data stored in a buffer. To avoid creating new buffers per frame and to minimize processor idle time between frames, implement a triple buffering model.
 
 for management Renderer ~ Scene Uniforms, i seperate Renederer and DynamicBuffer from XCode10 default Metal Template
 
 see also [Metal Best Practices Guide/Resource Management/Triple Buffering](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/TripleBuffering.html)
 */
class DynamicBuffer {
    /// The 256 byte aligned size of our uniform structure
    static var alignedUniformsSize = (MemoryLayout<Uniforms>.size & ~0xFF) + 0x100
    
    /// Buffer Count, we use Triple Buffering
    static var maxBuffersInFlight = 3

    let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)

    /// VertexUniformBuffer
    var dynamicUniformBuffer: MTLBuffer
    var uniformBufferOffset = 0
    var uniformBufferIndex = 0
    var uniformBufferSize = 0
    var uniforms: UnsafeMutablePointer<Uniforms>
    var currentUniform: Uniforms {
        return uniforms[uniformBufferIndex]
    }
    
    // FragementUniformBuffer
    var dynamicFragmentUniformBuffer: MTLBuffer
    var fragmentUniformBufferOffset = 0
    var fragmentUniformBufferIndex = 0
    var fragmentUniformBufferSize = 0
    var fragmentUniforms: UnsafeMutablePointer<FragmentUniforms>
    var currentFragmentUniform: FragmentUniforms {
        return fragmentUniforms[fragmentUniformBufferIndex]
    }
    
    init?(device: MTLDevice)
    {
        uniformBufferSize = DynamicBuffer.alignedUniformsSize * DynamicBuffer.maxBuffersInFlight
        
        guard let buffer = device.makeBuffer(length:uniformBufferSize, options:[MTLResourceOptions.storageModeShared]) else { return nil }
        dynamicUniformBuffer = buffer
        
        self.dynamicUniformBuffer.label = "UniformBuffer"
        
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents()).bindMemory(to:Uniforms.self, capacity:1)
        
        
        fragmentUniformBufferSize = DynamicBuffer.alignedUniformsSize * DynamicBuffer.maxBuffersInFlight
        
        guard let fragmentBuffer = device.makeBuffer(length:fragmentUniformBufferSize, options:[MTLResourceOptions.storageModeShared]) else { return nil }
        dynamicFragmentUniformBuffer = fragmentBuffer
        
        self.dynamicFragmentUniformBuffer.label = "FragmentUniformBuffer"
        
        fragmentUniforms = UnsafeMutableRawPointer(dynamicFragmentUniformBuffer.contents()).bindMemory(to: FragmentUniforms.self, capacity: 1)
    }
    
    /**
     update index in Buffers.
     */
    public func updateDynamicBufferState() {
        uniformBufferIndex = (uniformBufferIndex + 1) % DynamicBuffer.maxBuffersInFlight
        
        uniformBufferOffset = DynamicBuffer.alignedUniformsSize * uniformBufferIndex
        
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents() + uniformBufferOffset).bindMemory(to:Uniforms.self, capacity:1)
        
        fragmentUniformBufferIndex = (fragmentUniformBufferIndex + 1) % DynamicBuffer.maxBuffersInFlight
        
        fragmentUniformBufferOffset = DynamicBuffer.alignedUniformsSize * fragmentUniformBufferIndex
        
        fragmentUniforms = UnsafeMutableRawPointer(dynamicFragmentUniformBuffer.contents() + fragmentUniformBufferOffset).bindMemory(to:FragmentUniforms.self, capacity:1)
    }
 
    /**
     
     */
    public func setDynamicBufferInRenderEncoder(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setVertexBuffer(dynamicUniformBuffer, offset:0, index: BufferIndex.uniforms.rawValue)
        
        renderEncoder.setFragmentBuffer(dynamicFragmentUniformBuffer, offset:0, index: BufferIndex.fragmentUniforms.rawValue)
    }
}
