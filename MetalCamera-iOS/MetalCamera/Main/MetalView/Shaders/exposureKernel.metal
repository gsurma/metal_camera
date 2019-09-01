//
//  exposureKernel.metal
//  MetalCamera
//
//  Created by Greg on 01/09/2019.
//  Copyright © 2019 GS. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void exposureKernel(texture2d<float, access::read> inTexture [[ texture(0) ]],
                           texture2d<float, access::write> outTexture [[ texture(1) ]],
                           uint2 gid [[ thread_position_in_grid ]]) {
    const float exposure = 1.5;
    float4 originalColor = inTexture.read(gid);
    float4 finalColor = float4((originalColor.rgb*pow(2.0, exposure)), originalColor.a);
    outTexture.write(finalColor, gid);
}
