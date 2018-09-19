import MetalKit

class Lighting: Node
{
    // !!! current not extend Node !!!
    
    func buildDefaultLight() -> Light
    {
        var light = Light()
        light.position = [0, 0, 0]
        light.color = [1, 1, 1]
        light.specularColor = [0.6, 0.6, 0.6]
        light.intensity = 1
        light.attenuation = float3(1, 0, 0)
        light.type = LightType.sunlight
        return light
    }
    
    func lighting() -> [Light] {
        var lights: [Light] = []
        
        var light = buildDefaultLight()
        light.position = [-1, 0.5, -2]
        light.intensity = 2.0
        lights.append(light)
        
        light = buildDefaultLight()
        light.position = [0, 1, 2]
        light.intensity = 0.2
        lights.append(light)
        
        light = buildDefaultLight()
        light.type = LightType.ambientlight
        light.intensity = 0.1
        lights.append(light)
        
        return lights
    }
    
    lazy var sunlight: Light = {
        var light = buildDefaultLight()
        light.position = [1, 1, 1]
        return light
    }()
    
    lazy var ambientLight: Light = {
        var light = buildDefaultLight()
        light.position = [1, -1, 1]
        light.color = [0.0, 0.0, 0.0]
        light.intensity = 0.1
        light.type = LightType.ambientlight
        return light
    }()
    
    lazy var redLight: Light = {
        var light = buildDefaultLight()
        light.position = [-1, 2, 1]
        light.color = [1, 0, 0]
        light.attenuation = float3(1, 1, 1)
        light.type = LightType.pointlight
        return light
    }()
    
    lazy var blueLight: Light = {
        var light = buildDefaultLight()
        light.position = [1, 2, -1]
        light.color = [0, 0, 1]
        light.attenuation = float3(1, 1, 1)
        light.type = LightType.pointlight
        return light
    }()
    
    lazy var spotlight: Light = {
        var light = buildDefaultLight()
        light.position = [1, 1, -1]
        light.color = [0, 0, 1]
        light.attenuation = float3(1, 1, 1)
        light.type = LightType.spotlight
        light.coneAngle = radians(fromDegrees: 180)
        light.coneDirection = [0, 0, 0]
        light.coneAttenuation = 1
        return light
    }()
}


