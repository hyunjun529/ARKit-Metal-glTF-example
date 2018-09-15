// Our platform independent renderer class

import Metal
import MetalKit


// The 256 byte aligned size of our uniform structure
let alignedUniformsSize = (MemoryLayout<Uniforms>.size & ~0xFF) + 0x100

let maxBuffersInFlight = 3

enum RendererError: Error {
    case badVertexDescriptor
}


class Renderer: NSObject, MTKViewDelegate {
    static var device: MTLDevice!
    
    static var commandQueue: MTLCommandQueue!
    static var depthStencilState: MTLDepthStencilState!
    
    static var depthStencilPixelFormat: MTLPixelFormat!
    static var colorPixelFormat: MTLPixelFormat!
    
    static var library: MTLLibrary?
    
    var dynamicUniformBuffer: MTLBuffer
    var uniformBufferOffset = 0
    var uniformBufferIndex = 0
    var uniforms: UnsafeMutablePointer<Uniforms>
    
    var dynamicFragmentUniformBuffer: MTLBuffer
    var fragmentUniformBufferOffset = 0
    var fragmentUniformBufferIndex = 0
    var fragmentUniforms: UnsafeMutablePointer<FragmentUniforms>
    
    let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)
    
    
    lazy var camera: Camera = {
        let camera = Camera()
        camera.position = [0, 4, -8]
        return camera
    }()
    
    var models: [Model] = []
    
    var lights: [Light] = []
    
    // Debug drawing of lights
    lazy var lightPipelineState: MTLRenderPipelineState = {
        return buildLightPipelineState()
    }()
    
    
    init?(metalKitView: MTKView) {
        Renderer.device = metalKitView.device!
        
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        metalKitView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        metalKitView.sampleCount = 1
        
        let depthStateDesciptor = MTLDepthStencilDescriptor()
        depthStateDesciptor.depthCompareFunction = MTLCompareFunction.less
        depthStateDesciptor.isDepthWriteEnabled = true
        guard let state = Renderer.device.makeDepthStencilState(descriptor:depthStateDesciptor) else { return nil }
        
        Renderer.commandQueue = Renderer.device.makeCommandQueue()!
        Renderer.depthStencilState = state
        
        Renderer.depthStencilPixelFormat = metalKitView.depthStencilPixelFormat
        Renderer.colorPixelFormat = metalKitView.colorPixelFormat
        
        Renderer.library = Renderer.device.makeDefaultLibrary()
        
        
        let uniformBufferSize = alignedUniformsSize * maxBuffersInFlight
        
        guard let buffer = Renderer.device.makeBuffer(length:uniformBufferSize, options:[MTLResourceOptions.storageModeShared]) else { return nil }
        dynamicUniformBuffer = buffer
        
        self.dynamicUniformBuffer.label = "UniformBuffer"
        
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents()).bindMemory(to:Uniforms.self, capacity:1)
        
        
        let fragmentUniformBufferSize = alignedUniformsSize * maxBuffersInFlight
        
        guard let fragmentBuffer = Renderer.device.makeBuffer(length:fragmentUniformBufferSize, options:[MTLResourceOptions.storageModeShared]) else { return nil }
        dynamicFragmentUniformBuffer = fragmentBuffer
        
        self.dynamicFragmentUniformBuffer.label = "FragmentUniformBuffer"
        
        fragmentUniforms = UnsafeMutableRawPointer(dynamicFragmentUniformBuffer.contents()).bindMemory(to: FragmentUniforms.self, capacity: 1)
        
        
        super.init()
        
        
        // metalKitView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1)
        metalKitView.delegate = self
        mtkView(metalKitView, drawableSizeWillChange: metalKitView.bounds.size)
        
        
        // init Models
        let kizunaai = Model(name: "kizunaai")
        kizunaai.position = [0, 0, 0]
        kizunaai.rotation = [0, radians(fromDegrees: 45), 0]
        models.append(kizunaai)
        
        
        // init Lights
        let lighting = Lighting()
        lights.append(lighting.sunlight)
        lights.append(lighting.ambientLight)
        lights.append(lighting.redLight)
        lights.append(lighting.blueLight)
        fragmentUniforms[0].lightCount = UInt32(lights.count)
    }
    
    private func updateDynamicBufferState() {
        /// Update the state of our uniform buffers before rendering
        
        uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
        
        uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
        
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents() + uniformBufferOffset).bindMemory(to:Uniforms.self, capacity:1)
    }
    
    private func updateGameState() {
        /// Update any game state before rendering
        
        uniforms[0].projectionMatrix = camera.projectionMatrix
        uniforms[0].viewMatrix = camera.viewMatrix
        uniforms[0].modelMatrix = matrix_float4x4(1.0)
    }
    
    func draw(in view: MTKView) {
        /// Per frame updates hare
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        if let commandBuffer = Renderer.commandQueue.makeCommandBuffer() {
            
            let semaphore = inFlightSemaphore
            commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
                semaphore.signal()
            }
            
            self.updateDynamicBufferState()
            
            self.updateGameState()
            
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            let renderPassDescriptor = view.currentRenderPassDescriptor
            
            if let renderPassDescriptor = renderPassDescriptor, let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                
                /// Final pass rendering code here
                renderEncoder.label = "Primary Render Encoder"
                
                renderEncoder.pushDebugGroup("Draw Box")
                
                renderEncoder.setCullMode(.front)
                
                renderEncoder.setFrontFacing(.counterClockwise)
                
                renderEncoder.setDepthStencilState(Renderer.depthStencilState)
                
                
                renderEncoder.setFragmentBytes(&lights,
                                               length: MemoryLayout<Light>.stride * lights.count,
                                               index: Int(BufferIndex.lights.rawValue))
                
                
                // render all the models in the array
                fragmentUniforms[0].cameraPosition = camera.position
                fragmentUniforms[0].lightCount = UInt32(lights.count)
                
                uniforms[0].projectionMatrix = camera.projectionMatrix
                uniforms[0].viewMatrix = camera.viewMatrix
                
                for model in models {
                    // model matrix now comes from the Model's superclass: Node
                    uniforms[0].modelMatrix = model.modelMatrix
                    uniforms[0].normalMatrix = float3x3(normalFrom4x4: model.modelMatrix)
                    fragmentUniforms[0].tiling = model.tiling // hmm...
                    
                    renderEncoder.setVertexBuffer(dynamicUniformBuffer, offset:uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
                    
                    renderEncoder.setFragmentBuffer(dynamicFragmentUniformBuffer, offset:fragmentUniformBufferOffset, index: BufferIndex.fragmentUniforms.rawValue)
                    
                    renderEncoder.setRenderPipelineState(model.pipelineState)
                    renderEncoder.setVertexBuffer(model.vertexBuffer, offset: 0,
                                                  index: Int(BufferIndex.meshPositions.rawValue))
                    
                    for modelSubmesh in model.submeshes {
                        renderEncoder.setFragmentSamplerState(model.samplerState, index: 0)
                        
                        // set the fragment texture here
                        renderEncoder.setFragmentTexture(modelSubmesh.textures.baseColor,
                                                         index: Int(TextureIndex.color.rawValue))
                        
                        let submesh = modelSubmesh.submesh
                        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                            indexCount: submesh.indexCount,
                                                            indexType: submesh.indexType,
                                                            indexBuffer: submesh.indexBuffer.buffer,
                                                            indexBufferOffset: submesh.indexBuffer.offset)
                    }
                }

                
                // Debug Lighting
                debugLights(renderEncoder: renderEncoder, lightType: LightType.pointlight)
                
                renderEncoder.popDebugGroup()
                
                renderEncoder.endEncoding()
                
                if let drawable = view.currentDrawable {
                    commandBuffer.present(drawable)
                }
            }
            
            commandBuffer.commit()
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        /// Respond to drawable size or orientation changes here
        
        camera.aspect = Float(view.bounds.width)/Float(view.bounds.height)
    }
}
