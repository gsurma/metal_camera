//
//  pixellateKernel.metal
//  MetalCamera
//
//  Created by Greg on 01/09/2019.
//  Copyright © 2019 GS. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void pixellateKernel(texture2d<float, access::read> inTexture [[ texture(0) ]],
                            texture2d<float, access::write> outTexture [[ texture(1) ]],
                            uint2 gid [[ thread_position_in_grid ]]) {

    const float pixelSize = 20.0;
    uint2 position = uint2(floor(gid.x/pixelSize)*pixelSize,
                           floor(gid.y/pixelSize)*pixelSize);
    float4 finalColor = inTexture.read(position);
    outTexture.write(finalColor, gid);
}
