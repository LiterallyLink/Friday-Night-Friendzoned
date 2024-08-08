package states;

import flixel.FlxG;

class BiosState extends MusicBeatState
{

	override public function create():Void
	{
        FlxG.mouse.visible = true;

        var funkinOSLogo:FlxText = new FlxText(10, 10, "
          ___          _   _      ___  ___ 
         | __|  _ _ _ | |_(_)_ _ / _ \\/ __|
         | _| || | ' \\| / / | ' \\ (_) \\__ \\
         |_| \\_,_|_||_|_\\_\\_|_||_\\___/|___/
                                   ");
        add(funkinOSLogo);
    
        var biosText:FlxText = new FlxText(10, 80, "You're seeing this screen because you interrupted\nthe boot sequence or something went wrong\nduring scripts execution.", 8);
        biosText.setFormat(null, 8, 0xFFC9D872);
        // add(biosText);

        var downgradeText:FlxText = new FlxText(10, 120, "> Downgrade to Funkin93 v1", 8);
        // add(downgradeText);
        var downgradeExplanationText:FlxText = new FlxText(10, 130, "Less apps and no filesystem\nbut better support for old browsers", 8);
        downgradeExplanationText.setFormat(null, 8, 0xFFC9D872);
       //  add(downgradeExplanationText);

        var reinstallText:FlxText = new FlxText(10, 160, "> Reinstall to Funkin93 v2", 8);
       // add(reinstallText);
        var reinstallExplanationText:FlxText = new FlxText(10, 170, "You will loose all your saved data\nbut can repair broken boot", 8);
        reinstallExplanationText.setFormat(null, 8, 0xFFC9D872);
       // add(reinstallExplanationText);

        var restartText:FlxText = new FlxText(10, 200, "> Restart in Safe Mode", 8);
       // add(restartText);
        var restartText:FlxText = new FlxText(10, 210, "Disable any script or style\nfrom the /a/boot/ folder", 8);
        restartText.setFormat(null, 8, 0xFFC9D872);
        //add(restartText);
        
        var continueText:FlxText = new FlxText(10, 240, "> Continue normal boot", 8);
        //add(continueText);
    }

    override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
