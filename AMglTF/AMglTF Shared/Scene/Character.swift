import MetalKit

class Character: Node {
    
    let buffers: [MTLBuffer]
    let meshNodes: [CharacterNode]
    let animations: [AnimationClip]
    let nodes: [CharacterNode]
    var currentTime: Float = 0
    var currentAnimation: AnimationClip?
    var currentAnimationPlaying: Bool = false
    
    class CharacterSubmesh: Submesh {
        var attributes: [Attributes] = []
        var indexCount: Int = 0
        var indexBuffer: MTLBuffer?
        var indexBufferOffset: Int = 0
        var indexType: MTLIndexType = .uint16
    }
    
    init(name: String) {
        let asset = GLTFAsset(filename: name)
        buffers = asset.buffers
        animations = asset.animations
        guard asset.scenes.count > 0 else {
            fatalError("glTF file has no scene")
        }
        meshNodes = asset.scenes[0].meshNodes
        nodes = asset.scenes[0].nodes
        
        super.init()
        
        self.name = name
    }
    
    override func update(deltaTime: Float) {
        guard let animation = currentAnimation,
            currentAnimationPlaying == true else {
                return
        }
        currentTime += deltaTime
        let time = fmod(currentTime, animation.duration)
        for nodeAnimation in animation.nodeAnimations {
            let speed = animation.speed
            let animation = nodeAnimation.value
            animation.speed = speed
            guard let node = animation.node else { continue }
            if let translation = animation.getTranslation(time: time) {
                node.translation = translation
            }
            if let rotationQuaternion = animation.getRotation(time: time) {
                node.rotationQuaternion = rotationQuaternion
            }
        }
    }
}

// MARK:- Animation Control
extension Character {
    
    func calculateJoints(node: CharacterNode, time: Float) {
        if let nodeAnimation = animations[0].nodeAnimations[node.nodeIndex] {
            if let translation = nodeAnimation.getTranslation(time: time) {
                node.translation = translation
            }
            if let rotationQuaternion = nodeAnimation.getRotation(time: time) {
                node.rotationQuaternion = rotationQuaternion
            }
        }
        for child in node.children {
            calculateJoints(node: child, time: time)
        }
    }
    
    func runAnimation(clip animationClip: AnimationClip? = nil) {
        var clip = animationClip
        if clip == nil {
            guard animations.count > 0 else { return }
            clip = animations[0]
        } else {
            clip = animationClip
        }
        currentAnimation = clip
        currentTime = 0
        currentAnimationPlaying = true
        // immediately update the initial pose
        update(deltaTime: 0)
    }
    
    func runAnimation(name: String) {
        guard let clip = (animations.filter {
            $0.name == name
        }).first else {
            return
        }
        runAnimation(clip: clip)
    }
    
    func pauseAnimation() {
        currentAnimationPlaying = false
    }
    
    func resumeAnimation() {
        currentAnimationPlaying = true
    }
    
    func stopAnimation() {
        currentAnimation = nil
        currentAnimationPlaying = false
    }
}

// MARK:- Rendering
extension Character: Renderable {
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms vertex: Uniforms) {
        for node in meshNodes {
            guard let mesh = node.mesh else { continue }
            
            if let skin = node.skin {
                for (i, jointNode) in skin.jointNodes.enumerated() {
                    skin.jointMatrixPalette[i] = node.globalTransform.inverse *
                        jointNode.globalTransform *
                        jointNode.inverseBindTransform
                }
                let length = MemoryLayout<float4x4>.stride *
                    skin.jointMatrixPalette.count
                let buffer =
                    Renderer.device.makeBuffer(bytes: &skin.jointMatrixPalette,
                                               length: length, options: [])
                renderEncoder.setVertexBuffer(buffer, offset: 0, index: 21)
            }
            
            var uniforms = vertex
            uniforms.modelMatrix = worldTransform
            uniforms.normalMatrix = float3x3(normalFrom4x4: modelMatrix)
            renderEncoder.setVertexBytes(&uniforms,
                                         length: MemoryLayout<Uniforms>.stride,
                                         index: Int(BufferIndex.uniforms.rawValue))
            
            for submesh in mesh.submeshes {
                renderEncoder.setRenderPipelineState(submesh.pipelineState)
                var material = submesh.material
                renderEncoder.setFragmentBytes(&material,
                                               length: MemoryLayout<Material>.stride,
                                               index: Int(BufferIndex.materials.rawValue))
                for attribute in submesh.attributes {
                    renderEncoder.setVertexBuffer(buffers[attribute.bufferIndex],
                                                  offset: attribute.offset,
                                                  index: attribute.index)
                }
                
                renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                    indexCount: submesh.indexCount,
                                                    indexType: submesh.indexType,
                                                    indexBuffer: submesh.indexBuffer!,
                                                    indexBufferOffset: submesh.indexBufferOffset)
            }
        }
    }
}

