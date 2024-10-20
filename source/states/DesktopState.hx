package states;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;

import shaders.CRTShader;
import openfl.filters.ShaderFilter;

class DesktopState extends MusicBeatState
{
    public var vcr:CRTShader;

	override function create()
	{	
        desktopTheme = ClientPrefs.data.desktopTheme;
    
        vcr = new CRTShader(0.2, 0.55);
        FlxG.camera.setFilters([new ShaderFilter(vcr)]);

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;
	}

	override function destroy()
	{
		super.destroy();
	}

	override function update(elapsed:Float)
	{
        if (FlxG.sound.music != null) {
            Conductor.songPosition = FlxG.sound.music.time;
        }

        super.update(elapsed);
	}
}
