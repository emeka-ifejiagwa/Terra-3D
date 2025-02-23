//
//  Erosion.swift
//  Terra 3D
//
//  Created by Jiexy on 2/17/25.
//
import RealityKit
import simd
import Accelerate

/// Inspired by[ this research paper by Hans Theobald Beyer](http://www.firespark.de/resources/downloads/implementation%20of%20a%20methode%20for%20hydraulic%20erosion.pdf)
// MARK: IMPORTANT - To avoid complications and confusion, I follow the technique in the book where x is used for the width and y for the height
// Works but reduces frame rate drastically
class Erosion: System {
    private let maxParticleLifeTime = 32
    private let inertia: Float = 0.025
    private let depositionRate: Float = 0.5
    private let minSlope: Float = 0.1
    private let capacity: Float = 32 // Multiplier for how much sediment a droplet can carry
    private let erosionRate: Float = 0.1
    private let gravity: Float = 16
    private let radius = 2
    // MARK: modify evaporation to use temperature
    private var evaporationRate: Float = 0.001
    
    private static let query = EntityQuery(where: .has(HeightComponent.self)
                                           && .has(TemperatureComponent.self)
                                           && .has(HumidityComponent.self))
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: Erosion.query, updatingSystemWhen: .rendering)
        entities.forEach { terrain in
            var heightMap = terrain.components[HeightComponent.self]?.heightMap ?? HeightComponent(height: MAP_HEIGHT, width: MAP_WIDTH).heightMap
            var drop = Particle()
            for _ in 0...self.maxParticleLifeTime {
                // before modifying drop, copy old drop
                let oldDrop = drop
                let gradient = calculatePositionGradient(of: oldDrop, in: heightMap)
                var updatedDirection = oldDrop.direction * self.inertia - gradient * (1 - self.inertia)
                // because of the way we set up the computed properties, which updates when we update position
                // we need to check this before setting the position
                // if the direction is 0, we would get an NAN when we try to normalize
                if updatedDirection == .zero {
                    updatedDirection = simd_normalize(.init(x: Float.random(in: -1...1), y: Float.random(in: -1...1)))
                }
                drop.direction = updatedDirection
                drop.pos = oldDrop.pos + drop.direction
                let outOfBounds = drop.pos.x < 0.0 || drop.pos.x >= Float(MAP_WIDTH - 1) || drop.pos.y < 0.0 || drop.pos.y >= Float(MAP_HEIGHT - 1)
                // if direction is 0 or we are at the edge of the map, we can stop iteration
                if(drop.direction == .zero || outOfBounds) { break }
                
                let oldHeight = heightMap[oldDrop.index.y, oldDrop.index.x]
                let newHeight = heightMap[drop.index.y, drop.index.x]
                let heightDiff = newHeight - oldHeight
                
                if heightDiff > 0 {
                    // if we have excess sediment, deposit enough and move on
                    // else deposit all you have
                    let sedimentToDeposit = min(heightDiff, drop.sediment)
                    distribute(deposit: sedimentToDeposit, at: oldDrop.index, cellBoundPos: oldDrop.cellBoundPos, on: &heightMap)
                    drop.sediment -= sedimentToDeposit
                } else {
                    let sedimentCapacity = max(-heightDiff, self.minSlope) * drop.velocity * drop.water * self.capacity
                    if drop.sediment > sedimentCapacity {
                        let surplus = (drop.sediment - sedimentCapacity) * self.depositionRate
                        distribute(deposit: surplus, at: oldDrop.index, cellBoundPos: oldDrop.cellBoundPos, on: &heightMap)
                        drop.sediment -= surplus
                    } else {
                        // drop carries less sediment than its capacity allows
                        let amountToErode = min((sedimentCapacity - drop.sediment) * self.erosionRate, -heightDiff)
                        erode(amountToErode, by: oldDrop, on: &heightMap)
                        drop.sediment += amountToErode
                    }
                }
                
                let velocitySquared = oldDrop.velocity * oldDrop.velocity + heightDiff * self.gravity
                drop.velocity = sqrtf(max(velocitySquared, 0))
                drop.water = oldDrop.water * (1 - self.evaporationRate)
            }
            
            // MARK: Consider updating the model component instead of this
            terrain.components[HeightComponent.self] = HeightComponent(height: MAP_HEIGHT, width: MAP_WIDTH, heightMap: heightMap)
            if let component = terrain.components[HeightComponent.self] {
                let terrainTextureComponent = terrain.components[TerrainTextureComponent.self]!
                
                let modelComponent = ModelComponent(mesh: component.terrainMesh, materials: [terrainTextureComponent.material])
                terrain.components[ModelComponent.self] = modelComponent
            }
        }
        
    }
    
    private func calculatePositionGradient(
        of drop: Particle, in heightMap: Flat2DArray<Float>
    ) -> SIMD2<Float>{
        let heightNW = heightMap[drop.index.y, drop.index.x] // see mark for reason for split
        let heightNE = heightMap[drop.index.y, drop.index.x + 1] // see mark for reason for split
        let heightSW = heightMap[drop.index.y + 1, drop.index.x] // see mark for reason for split
        let heightSE = heightMap[drop.index.y + 1, drop.index.x + 1] // see mark for reason for split
        
        let gradient = SIMD2<Float>(
            x: (heightNE - heightNW) * (1 - drop.cellBoundPos.y) + (heightSW - heightSE) * (drop.cellBoundPos.y),
            y: (heightSW - heightNW) * (1 - drop.cellBoundPos.x) + (heightSE - heightNE) * (drop.cellBoundPos.x)
        )
        return gradient
    }
    
    private func distribute(deposit sedimentToDeposit: Float, at index: SIMD2<Int>, cellBoundPos: SIMD2<Float>, on heightMap: inout Flat2DArray<Float>){
        // distribute sediments to surrounding cells
        heightMap[index.y, index.x] += sedimentToDeposit * (1 - cellBoundPos.x) * (1 - cellBoundPos.y)
        heightMap[index.y, index.x + 1] += sedimentToDeposit * cellBoundPos.x * (1 - cellBoundPos.y)
        heightMap[index.y + 1, index.x] += sedimentToDeposit * (1 - cellBoundPos.x) * cellBoundPos.y
        heightMap[index.y + 1, index.x + 1] += sedimentToDeposit * cellBoundPos.x * cellBoundPos.y
    }
    
    private func erode(_ amountToErode: Float, by drop: Particle, on heightMap: inout Flat2DArray<Float>){
        var totalWeights: Float = 0
        var weights: [Float] = []
        let neighbors = getNeighbors(of: drop.pos, withRadius: self.radius)
        for neighbor in neighbors{
            let neighborPos = SIMD2<Float>(Float(neighbor.x), Float(neighbor.y))
            let weight = max(0, Float(self.radius) - length(neighborPos - drop.pos))
            totalWeights += weight
            weights.append(weight)
        }
        
        let normalizedWeights = vDSP.divide(weights, totalWeights)
        let erosionPerCell = vDSP.multiply(amountToErode, normalizedWeights)
        for (i, neighbor) in neighbors.enumerated() {
            heightMap[neighbor.y, neighbor.x] -= erosionPerCell[i]
        }
    }
    
    private func getNeighbors(of position: SIMD2<Float>, withRadius radius: Int) -> [SIMD2<Int>]{
        var neighbors: [SIMD2<Int>] = []
        let minWidthInRadius = floor(position.x - Float(radius))
        let maxWidthInRadius = floor(position.x + Float(radius))
        
        let minHeightInRadius = floor(position.y - Float(radius))
        let maxHeightInRadius = floor(position.y + Float(radius))
        for y in Int(minHeightInRadius)...Int(maxHeightInRadius){
            for x in Int(minWidthInRadius)...Int(maxWidthInRadius){
                // check bounds
                if x >= 0, x < MAP_WIDTH, y >= 0, y < MAP_HEIGHT, length(position - SIMD2<Float>(Float(x), Float(y))) <= Float(self.radius){
                    neighbors.append(SIMD2(x, y))
                }
            }
        }
        return neighbors
    }
    
}

struct Particle {
    var pos: SIMD2<Float>
    var direction: SIMD2<Float>
    var velocity: Float = 10
    var water: Float = 20
    var sediment: Float = 0
    var index: SIMD2<Int> {
        return SIMD2(Int(pos.x), Int(pos.y))
    }
    var cellBoundPos: SIMD2<Float> {
        return self.pos - SIMD2<Float>(self.index) // between 0 and 1
    }
    init(
        // to avoid checking out of bounds, we generate one less than the last index
        pos: SIMD2<Float> = SIMD2(.random(in: 0..<Float(MAP_WIDTH - 1)), .random(in: 0..<Float(MAP_HEIGHT - 1))),
        direction: SIMD2<Float> = .zero,
        initialVelocity: Float = 1,
        initialWater: Float = 1,
        initialSediment: Float = 0
    ){
        self.pos = pos
        self.direction = direction
        self.velocity = initialVelocity
        self.water = initialWater
        self.sediment = initialSediment
    }
}
