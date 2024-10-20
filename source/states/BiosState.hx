package states;

import flixel.FlxG;

import shaders.CRTShader;
import flixel.system.FlxAssets.FlxShader;
import openfl.filters.ShaderFilter;

class BiosState extends MusicBeatState
{
	public var vcr:CRTShader;

	override public function create():Void
	{
		vcr = new CRTShader(0.35, 0.75);
		FlxG.camera.setFilters([new ShaderFilter(vcr)]);

        FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;

		var friendzonedOSLogo:FlxSprite = new FlxSprite(10, 10).loadGraphic(Paths.image('friendzonedOSLogo'));
		add(friendzonedOSLogo);
    
        var biosText:FlxText = new FlxText(10, 145, "DA FUCK? You just crashed the party...");
        biosText.setFormat(null, 15, FlxColor.YELLOW);
        add(biosText);

        var downgradeText:FlxText = new FlxText(10, 180, "> Roll it back to FriendzonedOS v1");
		downgradeText.setFormat(null, 10, FlxColor.YELLOW);
        add(downgradeText);
        var downgradeExplanationText:FlxText = new FlxText(10, 195, "Fewer beats, no file groove,\nbut it's chill with retro browsers.", 8);
		add(downgradeExplanationText);

        var reinstallText:FlxText = new FlxText(10, 235, "> Reinstall FriendzonedOS v2");
		reinstallText.setFormat(null, 10, FlxColor.YELLOW);
        add(reinstallText);
        var reinstallExplanationText:FlxText = new FlxText(10, 250, "Say bye to your saves, but\nyou can fix that broken vibe.", 8);
        add(reinstallExplanationText);

        var restartText:FlxText = new FlxText(10, 295, "> Restart in SFW Mode");
		restartText.setFormat(null, 10, FlxColor.YELLOW);
        add(restartText);
        var restartText:FlxText = new FlxText(10, 310, "Turn off any script or style\nfrom the /a/boot/ jam", 8);
        add(restartText);
        
        var continueText:FlxText = new FlxText(10, 355, "> Keep the Funk funkin");
		continueText.setFormat(null, 10, FlxColor.YELLOW);
        add(continueText);
    }

    override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
