package shaders;

import flixel.system.FlxAssets.FlxShader;

class CRTShader extends FlxShader
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
    float warp = 0.35; // simulate curvature of CRT monitor
    float scan = 0.75; // simulate darkness between scanlines
    void mainImage(out vec4 fragColor,in vec2 fragCoord)
    	{
        // squared distance from center
        vec2 uv = fragCoord/iResolution.xy;
        vec2 dc = abs(0.5-uv);
        dc *= dc;

        // warp the fragment coordinates
        uv.x -= 0.5; uv.x *= 1.0+(dc.y*(0.3*warp)); uv.x += 0.5;
        uv.y -= 0.5; uv.y *= 1.0+(dc.x*(0.4*warp)); uv.y += 0.5;
        // sample inside boundaries, otherwise set to black
        if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0)
            fragColor = vec4(0.0,0.0,0.0,texture(iChannel0, uv).a);
        else
        	{
            // determine if we are drawing in a scanline
            float apply = abs(sin(fragCoord.y)*0.5*scan);
            // sample the texture
        	fragColor = vec4(mix(texture(iChannel0,uv).rgb,vec3(0.0),apply),texture(iChannel0, uv).a);
            }
    	}
    void main() {
    	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
    }
    ')
	public function new()
		{
			super();
		}
}
