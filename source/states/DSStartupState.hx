package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import sys.io.File;
import sys.io.Process;

import openfl.Lib;

class DSStartupState extends MusicBeatState
{
	public var dsBackground:FlxSprite;
	public var dsBitchText:FlxSprite;
	public var dsBlackSText:FlxSprite;
	public var dsGreySText:FlxSprite;
	public var dsMfText:FlxSprite;
	public var dsNintendoLogo:FlxSprite;
	public var dsWarningText:FlxSprite;
	public var dsContinueText:FlxSprite;
	public var dsLearnMoreLink:FlxSprite;
	public var dsLearnMoreLink2:FlxSprite;
	private var stylus:FlxSprite;

	public var dsGroup:FlxTypedGroup<FlxSprite>;

	public var dsCamera:FlxCamera;
	
	override function create()
	{	
		FlxG.mouse.visible = false;

		dsCamera = new FlxCamera(0, -600, 512, 768);
		FlxG.cameras.reset(dsCamera);
		FlxCamera.defaultCameras = [dsCamera];

		Lib.current.scaleX = 2.5;
		Lib.current.scaleY = 2.5;

		// PlayState.ogwinX = Lib.application.window.x;
		// PlayState.ogwinY = Lib.application.window.y;
		
		var win = Lib.application.window;
		var DSWidth = 256 * 2; // 512
		var DSHeight = 384 * 2; // 768

		FlxG.resizeWindow(DSWidth, DSHeight);
		FlxG.resizeGame(DSWidth, DSHeight);

		Lib.current.x = 0;
		Lib.current.y = 0;
		win.resizable = false;

		dsGroup = new FlxTypedGroup<FlxSprite>();
		add(dsGroup);

		dsBackground = new FlxSprite(0, 0).loadGraphic(Paths.image('dsAssets/ds_bg'));
		dsBackground.antialiasing = false;
		dsBackground.cameras = [dsCamera];
		dsGroup.add(dsBackground);

		dsBitchText = new FlxSprite(64, 94).loadGraphic(Paths.image('dsAssets/ds_bitcha_text'));
		dsBitchText.antialiasing = false;
		dsBitchText.cameras = [dsCamera];

		dsBlackSText = new FlxSprite(272, 94).loadGraphic(Paths.image('dsAssets/ds_black_s_text'));
		dsBlackSText.y = 64;
		dsBlackSText.antialiasing = false;
		dsBlackSText.cameras = [dsCamera];

		dsGreySText = new FlxSprite(272, 126).loadGraphic(Paths.image('dsAssets/ds_grey_s_text'));
		dsGreySText.y = 156;
		dsGreySText.antialiasing = false;
		dsGreySText.cameras = [dsCamera];

		dsMfText = new FlxSprite(314, 94).loadGraphic(Paths.image('dsAssets/ds_mf_text'));
		dsMfText.antialiasing = false;
		dsMfText.cameras = [dsCamera];

		dsNintendoLogo = new FlxSprite(92, 282).loadGraphic(Paths.image('dsAssets/ds_friendtendo_logo'));
		dsNintendoLogo.antialiasing = false;
		dsNintendoLogo.cameras = [dsCamera];

		dsWarningText = new FlxSprite(50, 412).loadGraphic(Paths.image('dsAssets/ds_warning'));
		dsWarningText.antialiasing = false;
		dsWarningText.cameras = [dsCamera];

		dsLearnMoreLink = new FlxSprite(100, 662).loadGraphic(Paths.image('dsAssets/ds_learn_more_link'));
		dsLearnMoreLink.antialiasing = false;
		dsLearnMoreLink.cameras = [dsCamera];

		dsContinueText = new FlxSprite(88, 720).loadGraphic(Paths.image('dsAssets/ds_continue_text'));
		dsContinueText.antialiasing = false;
		dsContinueText.cameras = [dsCamera];

		stylus = new FlxSprite().loadGraphic(Paths.image('dsAssets/stylus'));
		stylus.antialiasing = false;
		add(stylus);

		new FlxTimer().start(1.5, function(timer:FlxTimer):Void {
			dsGroup.add(dsBitchText);
			dsGroup.add(dsBlackSText);
			dsGroup.add(dsGreySText);
			dsGroup.add(dsMfText);
			dsGroup.add(dsNintendoLogo);
			dsGroup.add(dsWarningText);
			dsGroup.add(dsLearnMoreLink);
			dsGroup.add(dsContinueText);

			FlxSpriteUtil.fadeIn(dsBitchText, 2, true);
			FlxSpriteUtil.fadeIn(dsBlackSText, 2.5, true);
			FlxSpriteUtil.fadeIn(dsGreySText, 2.5, true);
			FlxSpriteUtil.fadeIn(dsMfText, 3, true);
			FlxSpriteUtil.fadeIn(dsNintendoLogo, 3, true);
			FlxSpriteUtil.fadeIn(dsWarningText, 3, true);
			FlxSpriteUtil.fadeIn(dsLearnMoreLink, 3, true);
			FlxSpriteUtil.fadeIn(dsContinueText, 2, true);

			flashingEffect(dsContinueText, 2, 2);

			FlxTween.tween(dsBlackSText, { y: 94 }, 0.6);
			FlxTween.tween(dsGreySText, { y: 126 }, 0.6);
		});

		FlxG.sound.play(Paths.sound('ds_startup_noise'));

	}

	override function destroy()
	{
		super.destroy();
	}

	private function flashingEffect(sprite:FlxSprite, fadeInDuration:Float, fadeOutDuration:Float):Void
	{
		FlxSpriteUtil.fadeIn(sprite, fadeInDuration, true, function(tween:FlxTween):Void {
			FlxSpriteUtil.fadeOut(sprite, fadeOutDuration, function(tween:FlxTween):Void {
				flashingEffect(sprite, fadeInDuration, fadeOutDuration);
			});
		});
	}

	override function update(elapsed:Float)
	{
		stylus.x = FlxG.mouse.x;
		stylus.y = FlxG.mouse.y - 267;

		if (FlxG.mouse.pressed)
		{
			stylus.y += 10;
		}

		if (FlxG.mouse.overlaps(dsLearnMoreLink) && FlxG.mouse.justPressed) {
			Sys.command("start \"\" \"C:\\Users\\zecha\\Desktop\\Programming\\FNF-PsychEngine-main\\assets\\shared\\learnmore.html\"");
			trace('ass');
		}

		if (FlxG.mouse.overlaps(dsBackground) && !FlxG.mouse.overlaps(dsLearnMoreLink) && FlxG.mouse.justPressed) {

			trace("switch to new state");
		}
	}
}
