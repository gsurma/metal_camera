//
//  MetalView.swift
//  MetalCamera
//
//  Created by Greg on 24/07/2019.
//  Copyright © 2019 GS. All rights reserved.
//

import MetalKit
import CoreVideo

final class MetalView: MTKView {
    
    // Available kernels
    private let passthroughKernel = "passthroughKernel"
    private let brightnessKernel = "brightnessKernel"
    private let inversionKernel = "inversionKernel"
    private let contrastKernel = "contrastKernel"
    private let rgba2bgraKernel = "rgba2bgraKernel"
    private let exposureKernel = "exposureKernel"
    private let gammaKernel = "gammaKernel"
    private let grayscaleKernel = "grayscaleKernel"
    private let pixellateKernel = "pixellateKernel"
    private let boxBlurKernel = "boxBlurKernel"
    
    
    var pixelBuffer: CVPixelBuffer? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var textureCache: CVMetalTextureCache?
    private var commandQueue: MTLCommandQueue?
    private var computePipelineState: MTLComputePipelineState
    
    required init(coder: NSCoder) {
        
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to initialize GPU device")
        }
        
        commandQueue = metalDevice.makeCommandQueue()
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")
        do {
            let library = try metalDevice.makeLibrary(filepath: url!.path)
            guard let function = library.makeFunction(name: pixellateKernel) else {
                fatalError("Unable to create gpu kernel")
            }
            computePipelineState = try metalDevice.makeComputePipelineState(function: function)
        } catch {
            fatalError("Unable to setup metal")
        }
        
        var textCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &textCache) != kCVReturnSuccess {
            fatalError("Unable to allocate texture cache.")
        }
        else {
            textureCache = textCache
        }
        
        super.init(coder: coder)
        device = metalDevice
        
        drawableSize.width = 720
        drawableSize.height = 1280
    }
    
    override func draw(_ rect: CGRect) {
        autoreleasepool {
            if !rect.isEmpty {
                self.render()
            }
        }
    }
    
    private func render() {
        guard let pixelBuffer = self.pixelBuffer else { return }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, pixelBuffer, nil, .bgra8Unorm, width, height, 0, &cvTextureOut)
        
        guard let cvTexture = cvTextureOut, let inputTexture = CVMetalTextureGetTexture(cvTexture) else {
            fatalError("Failed to create metal textures")
        }
        
        // Debug image
//        let textureLoader = MTKTextureLoader(device: device!)
//        let inputTexture: MTLTexture = try! textureLoader.newTexture( URL: Bundle.main.url(forResource: "lighthouse", withExtension: "jpg")!, options: nil)

        guard let drawable: CAMetalDrawable = self.currentDrawable else { fatalError("Failed to create drawable") }
        
        if let commandQueue = commandQueue, let commandBuffer = commandQueue.makeCommandBuffer(), let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() {
            computeCommandEncoder.setComputePipelineState(computePipelineState)
            computeCommandEncoder.setTexture(inputTexture, index: 0)
            computeCommandEncoder.setTexture(drawable.texture, index: 1)
            computeCommandEncoder.dispatchThreadgroups(inputTexture.threadGroups(), threadsPerThreadgroup: inputTexture.threadGroupCount())
            computeCommandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

extension MTLTexture {
    
    func threadGroupCount() -> MTLSize {
        return MTLSizeMake(8, 8, 1)
    }
    
    func threadGroups() -> MTLSize {
        let groupCount = threadGroupCount()
        return MTLSize(width: (Int(width) + groupCount.width-1)/groupCount.width,
                       height: (Int(height) + groupCount.height-1)/groupCount.height,
                       depth: 1)
    }
}
