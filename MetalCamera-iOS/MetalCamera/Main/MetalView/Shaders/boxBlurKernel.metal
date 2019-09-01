//
//  boxBlurKernel.metal
//  MetalCamera
//
//  Created by Greg on 01/09/2019.
//  Copyright © 2019 GS. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void boxBlurKernel(texture2d<float, access::read> inTexture [[ texture(0) ]],
                          texture2d<float, access::write> outTexture [[ texture(1) ]],
                          uint2 gid [[ thread_position_in_grid ]]) {
    
    const int blurSize = 25;
    int range = floor(blurSize/2.0);
    
    float4 colors = float4(0);
    for (int x = -range; x <= range; x++) {
        for (int y = -range; y <= range; y++) {
            float4 color = inTexture.read(uint2(gid.x+x,
                                                gid.y+y));
            colors += color;
        }

    }

    float4 finalColor = colors/float(blurSize*blurSize);
    outTexture.write(finalColor, gid);
}
