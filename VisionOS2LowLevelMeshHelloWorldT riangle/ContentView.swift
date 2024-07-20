//
//  ContentView.swift
//  VisionOS2LowLevelMeshHelloWorldT riangle
//
//  Created by Sadao Tokuyama on 7/20/24.
//

import SwiftUI
import RealityKit

enum TriangleType {
    case left
    case right
}

struct ContentView: View {

    @State var realityViewContent: RealityViewContent?
    let colors: [UIColor] = [
        .red, .green, .blue, .yellow, .orange, .purple
    ]
    var body: some View {
        VStack {
            Text("Low Level Mesh Triangles")
                .font(.extraLargeTitle)
            
            RealityView { content in
                realityViewContent = content
                realityViewContent!.add(try! triangleEntity(.left))
                realityViewContent!.add(try! triangleEntity(.right))
            }
            Button(action: {
                realityViewContent!.entities.removeAll()
                realityViewContent!.add(try! triangleEntity(.left))
                realityViewContent!.add(try! triangleEntity(.right))
            }) {
                Text("Update")
                    .font(.extraLargeTitle)
                    .frame(width: 200, height: 100)
                    .cornerRadius(8)
            }
        }
    }
    
    func triangleEntity(_ type: TriangleType) throws -> Entity {
        let lowLevelMesh = try triangleMesh(type)
        let resource = try MeshResource(from: lowLevelMesh)
        let modelComponent = ModelComponent(mesh: resource, materials: [UnlitMaterial(color: colors.randomElement() ?? .white)])
        let entity = Entity()
        entity.name = "Triangle"
        entity.components.set(modelComponent)
        entity.scale *= 0.25
        return entity
    }
    
    func triangleMesh(_ type: TriangleType) throws -> LowLevelMesh {
        var desc =  MyVertex.descriptor
        desc.vertexCapacity = 3
        desc.indexCapacity = 3
        
        let mesh = try LowLevelMesh(descriptor: desc)
        
        switch (type) {
            case .left:
                mesh.withUnsafeMutableBytes(bufferIndex: 0) {rawBytes in
                    let vertices = rawBytes.bindMemory(to: MyVertex.self)
                    vertices[0] = MyVertex(position: [1, 1, 0], color: 0xFF00FF00)
                    vertices[1] = MyVertex(position: [-1, 1, 0], color: 0xFFFF0000)
                    vertices[2] = MyVertex(position: [-1, -1, 0], color: 0xFF0000FF)
                }
            case .right:
                mesh.withUnsafeMutableBytes(bufferIndex: 0) {rawBytes in
                    let vertices = rawBytes.bindMemory(to: MyVertex.self)
                    vertices[0] = MyVertex(position: [-1, -1, 0], color: 0xFF00FF00)
                    vertices[1] = MyVertex(position: [1, -1, 0], color: 0xFFFF0000)
                    vertices[2] = MyVertex(position: [1, 1, 0], color: 0xFF0000FF)
                }
        }
        mesh.withUnsafeMutableIndices { rawIndices in
            let indices = rawIndices.bindMemory(to: UInt32.self)
            indices[0] = 0
            indices[1] = 1
            indices[2] = 2
        }
        
        let meshBounds = BoundingBox(min: [-1, -1, 0], max: [1, 1, 0])
        mesh.parts.replaceAll([
            LowLevelMesh.Part(
                indexCount: 3,
                topology: .triangleStrip,
                bounds: meshBounds
            )
        ])
        return mesh
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
