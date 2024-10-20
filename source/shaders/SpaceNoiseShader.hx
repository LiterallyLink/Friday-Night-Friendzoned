package shaders;

import flixel.system.FlxAssets.FlxShader;

class SpaceNoiseShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        #define round(a) floor(a + 0.5)
        #define iResolution vec3(openfl_TextureSize, 0.)
        uniform float iTime;
        #define iChannel0 bitmap
        uniform sampler2D iChannel1;
        uniform sampler2D iChannel2;
        uniform sampler2D iChannel3;
        #define texture flixel_texture2D

        // third argument fix
        vec4 flixel_texture2D(sampler2D bitmap, vec2 coord, float bias) {
        	vec4 color = texture2D(bitmap, coord, bias);
        	if (!hasTransform)
        	{
        		return color;
        	}
        	if (color.a == 0.0)
        	{
        		return vec4(0.0, 0.0, 0.0, 0.0);
        	}
        	if (!hasColorTransform)
        	{
        		return color * openfl_Alphav;
        	}
        	color = vec4(color.rgb / color.a, color.a);
        	mat4 colorMultiplier = mat4(0);
        	colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
        	colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
        	colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
        	colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
        	color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
        	if (color.a > 0.0)
        	{
        		return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
        	}
        	return vec4(0.0, 0.0, 0.0, 0.0);
        }

        // variables which is empty, they need just to avoid crashing shader
        uniform float iTimeDelta;
        uniform float iFrameRate;
        uniform int iFrame;
        #define iChannelTime float[4](iTime, 0., 0., 0.)
        #define iChannelResolution vec3[4](iResolution, vec3(0.), vec3(0.), vec3(0.))
        uniform vec4 iMouse;
        uniform vec4 iDate;

        float Hash(in vec3 position) {
            return fract(sin(dot(position,vec3(283.6,127.1,311.7))) * 43758.5);
        }
        float Noise(vec3 uv, vec3 color) {
            uv.x += 2.0 * cos(color.y);
        	uv.y -= iTime * 0.25 + 0.25 * color.x * color.y;
            uv.z += iTime * 0.4 - color.z;

            vec2 coordinate = vec2(0, 1);
            vec3 floored = floor(uv);
            vec3 fractal = fract(uv);
            fractal *= fractal * (3.0 - 2.0 * fractal);

            float mix11 = mix(Hash(floored + coordinate.xxx), Hash(floored + coordinate.yxx), fractal.x);
            float mix12 = mix(Hash(floored + coordinate.xyx), Hash(floored + coordinate.yyx), fractal.x);
            float mix1  = mix(mix11, mix12, fractal.y);             
            float mix21 = mix(Hash(floored + coordinate.xxy), Hash(floored + coordinate.yxy), fractal.x);
            float mix22 = mix(Hash(floored + coordinate.xyy), Hash(floored + coordinate.yyy), fractal.x);
            float mix2  = mix(mix21, mix22, fractal.y);
            return mix(mix1, mix2, fractal.z);
        }

        void mainImage(out vec4 fragColor, in vec2 fragCoord) {
            vec3 preColor = vec3(0.3 * sin(iTime), 0.2, 0.35);
            vec2 uv = fragCoord.xy / iResolution.xy;
            vec3 uv3 = normalize(vec3(0.5, uv.x, uv.y));
            float noise = 0.5    * Noise(uv3      , preColor) +
                          0.25   * Noise(uv3 * 2.0, preColor) +
                          0.125  * Noise(uv3 * 4.0, preColor) +
                          0.0625 * Noise(uv3 * 8.0, preColor);
            vec3 color = preColor * noise * 2.0;
            color += Hash(Hash(uv.xyy) * uv.xyx * iTime) * 0.2;
            color *= 0.9 * smoothstep(length(uv * 0.5 - 0.25), 0.7, 0.4);

            vec4 spriteColor = texture(iChannel0, uv);

            vec3 finalColor = mix(spriteColor.rgb, color, 0.5); // Adjust blending ratio here (0.5 for 50%)

            float alpha = spriteColor.a * 1; // Lower the alpha as needed

            fragColor = vec4(finalColor, alpha);
        }


        void main() {
        	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
        }
    ')

    public function new()
    {
        super();
        iTime.value = [0.0];
    }

    public function update(elapsed:Float)
    {
        iTime.value[0] += elapsed;
    }
}