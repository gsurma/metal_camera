//
//  grayscaleKernel.metal
//  MetalCamera
//
//  Created by Greg on 01/09/2019.
//  Copyright © 2019 GS. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void grayscaleKernel(texture2d<float, access::read> inTexture [[ texture(0) ]],
                        texture2d<float, access::write> outTexture [[ texture(1) ]],
                        uint2 gid [[ thread_position_in_grid ]]) {
    float4 originalColor = inTexture.read(gid);
    float avg = (originalColor.r+originalColor.g+originalColor.b)/3.0;
    float4 finalColor = float4(avg, avg, avg, originalColor.a);
    outTexture.write(finalColor, gid);
}
