import Metal
import MetalKit
import CoreGraphics

/**
 Renderer for Virtual Stage(no AR)
 */
class Renderer: NSObject, MTKViewDelegate {
    static var device: MTLDevice!
    
    static var commandQueue: MTLCommandQueue!
    static var depthStencilState: MTLDepthStencilState!
    
    static var depthStencilPixelFormat: MTLPixelFormat!
    static var colorPixelFormat: MTLPixelFormat!
    
    static var library: MTLLibrary?
    
    var dynamicBuffer: DynamicBuffer
    
    var scene: Scene?
    
    var lights: [Light] = []
    
    var managers: [Manager] = []
    
    
    init?(metalKitView: MTKView) {
        Renderer.device = metalKitView.device!
        
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        metalKitView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
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
        
        dynamicBuffer = DynamicBuffer(device: Renderer.device)!
        
        super.init()
        
        
        metalKitView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1)
        metalKitView.delegate = self
        mtkView(metalKitView, drawableSizeWillChange: metalKitView.bounds.size)
        
        
        let scene = GameScene(sceneSize: metalKitView.bounds.size)
        self.scene = scene
        
        
        let lighting = Lighting()
        lights = lighting.lighting()
    }
    
    
    func attachManager(manager: Manager) {
        self.managers.append(manager)
    }
    
    
    func updateManagers() {
        for manager in managers {
            manager.update()
        }
    }
    
    
    /// Per frame updates hare
    func draw(in view: MTKView) {
        
        // Wait to ensure only kMaxBuffersInFlight are getting proccessed by any stage in the Metal
        //   pipeline (App, Metal, Drivers, GPU, etc)
        let _ = dynamicBuffer.inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        // Create a new command buffer for each renderpass to the current drawable
        if let commandBuffer = Renderer.commandQueue.makeCommandBuffer() {
            
            let semaphore = dynamicBuffer.inFlightSemaphore
            commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
                semaphore.signal()
            }
            
            // Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            // holding onto the drawable and blocking the display pipeline any longer than necessary
            let renderPassDescriptor = view.currentRenderPassDescriptor
            
            dynamicBuffer.updateDynamicBufferState()
            
            
            // update manager
            updateManagers()
            
            
            let deltaTime = 1 / Float(view.preferredFramesPerSecond)
            guard let scene = scene else { return }
            scene.uniforms = dynamicBuffer.uniforms[dynamicBuffer.uniformBufferIndex]
            scene.update(deltaTime: deltaTime)
            
            
            // about renderEncoder https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html
            if let renderPassDescriptor = renderPassDescriptor, let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                
                /// Final pass rendering code here
                renderEncoder.label = "Main Loop"
                
                renderEncoder.pushDebugGroup("Main Loop")
                
                
                // Render Manager
                for manager in managers {
                    manager.render(renderEncoder: renderEncoder)
                }
                
                
                renderEncoder.setCullMode(.front)
                
                renderEncoder.setFrontFacing(.counterClockwise)
                
                renderEncoder.setDepthStencilState(Renderer.depthStencilState)
                
                dynamicBuffer.setDynamicBufferInRenderEncoder(renderEncoder: renderEncoder)
                
                
                dynamicBuffer.fragmentUniforms[dynamicBuffer.fragmentUniformBufferIndex].cameraPosition = scene.camera.position
                dynamicBuffer.fragmentUniforms[dynamicBuffer.fragmentUniformBufferIndex].lightCount = UInt32(lights.count)
                
                renderEncoder.setFragmentBytes(&lights,
                                               length: MemoryLayout<Light>.stride * lights.count,
                                               index: Int(BufferIndex.lights.rawValue))
                
                // Render Scene
                for renderable in scene.renderables {
                    renderEncoder.pushDebugGroup(renderable.name)
                    renderable.render(renderEncoder: renderEncoder,
                                      uniforms: scene.uniforms)
                    renderEncoder.popDebugGroup()
                }
                
                
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
        scene?.sceneSizeWillChange(to: size)
        
        for manager in managers {
            manager.drawableSizeWillChange(size: size)
        }
    }
}
