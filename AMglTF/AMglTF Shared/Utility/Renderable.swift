import MetalKit


/**
 IN PROGRESS
 */
protocol Renderable {
    var name: String { get }
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms)
}
