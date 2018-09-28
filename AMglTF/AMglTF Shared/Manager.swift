import Metal
import CoreGraphics


/**
 for define Protocol of Manager
 */
protocol Manager {
    var name: String { get }
    func drawableSizeWillChange(size: CGSize)
    func update()
    func render(renderEncoder: MTLRenderCommandEncoder)
}
