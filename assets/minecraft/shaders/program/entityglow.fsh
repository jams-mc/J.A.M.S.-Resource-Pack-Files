#version 150

uniform sampler2D DiffuseSampler;
in vec2 texCoord;
in vec2 oneTexel;
uniform vec2 BlurDir;
uniform float Radius;

out vec4 fragColor;

void main() {
    vec4 sampler = texture(DiffuseSampler, texCoord);
    
    if (sampler.a >= 1.0) {
        // Fully opaque pixel
        fragColor = vec4(sampler.rgb, (BlurDir.y == 0.5 ? 0.5 : 1.0));
    } else {
        // Semi-transparent pixel
        vec3 blurs = sampler.rgb;
        float totalColor = 0.5;
        float alpha = sampler.a;
        
        if (alpha > 0.5)
            totalColor++;
        
        float gradient = 1.0;
        vec2 oneStep = BlurDir / oneTexel;
        float interval = 0.1;
        
        for (float r = -Radius; r < 0.0; r += interval) {
            vec4 sample = texture(DiffuseSampler, texCoord + oneStep * r);
            
            if (sample.a > 0.0) {
                interval = 1.0; // This line seems problematic, let's remove it
                totalColor++;
                blurs += sample.rgb;
                alpha = max(alpha, sample.a + r * gradient);
            }
        }
        
        fragColor = alpha > 0.0 ? vec4(blurs * 0.5 / totalColor, alpha + (BlurDir.y == 0.5 ? gradient : 0.0)) : vec4(0.0);
    }
}
