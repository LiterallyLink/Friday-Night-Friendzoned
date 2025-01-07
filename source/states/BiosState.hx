package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

import backend.ShaderManager;

import substates.ShaderSubState;
import substates.bios.AchievementsSubState;

typedef MenuOption = {
    label:String,
    description:String,
    callback:() -> Void
}

class BiosState extends MusicBeatState {
    private static inline var OPTION_FONT_SIZE:Int = 20;
    private static inline var DESCRIPTION_FONT_SIZE:Int = 15;
    private static inline var X_OFFSET:Int = 25;
    private static inline var Y_OFFSET:Int = 220;
    private static inline var LINE_SPACING:Int = 35;
    private static inline var SCREEN_PADDING:Int = 15;

    private var MENU_OPTIONS:Array<MenuOption>;
    private var descriptionText:FlxText;

    private var biosText:FlxText;
    private var biosLogo:FlxSprite;

    private var biosOptions:Array<FlxText> = [];
    private var biosIndex:Int = 0;

    override public function create():Void {
        MENU_OPTIONS = [
            {
                label: 'Roll it back to FriendzonedOS v1',
                description: "Are you stuck in the past?\nDo you refuse to accept any of the changes in your life?\n\nWell then, FriendzonedOS v1 is the\nOperating System for you!\n\nDiscard this new update and go back\nto the old one you stuck up grampa!",
                callback: () -> trace("Rollback selected")
            },
            {
                label: 'Restart in \'Safe For Work\' mode',
                description: "Our A.I. assistant, B.A.M.F., is trained off of\ncomputer forums on MoreChan and Fitter,\nas a result, some less than friendly words\nmay slip through our profanity filter!\n\nTo prevent this, we've provided the 'Safe For Work' mode.\n\nKeep his naughty lips sealed with this\nfeature and keep your ears clean!",
                callback: () -> toggleSFWMode()
            },
            {
                label: 'Clear That Motherfunkin\' Disk Drive',
                description: "Reset all your data in the game!\n(Warning: Will reset your data in the game.)",
                callback: () -> trace("Cache clear selected")
            },
            {
                label: 'Display FPS & Memory Usage',
                description: "Display performance metrics in the corner of the screen.\nUseful for debugging and optimization.",
                callback: () -> toggleMetrics()
            },
            {
                label: 'Advanced Chipset Features',
                description: "Toggle advanced gameplay mechanics.\nRecommended for experienced players only.",
                callback: () -> trace("Mechanics selected")
            },
            {
                label: "Setup Assistant",
                description: "Forgot your password? Misspelt your username?\n\nDon't worry, our handy dandy setup assistant will help you\nget back on track!",
                callback: () -> trace("Setup Assistant selected")
            },
            {
                label: 'Enable Chart Editor',
                description: "Enables the Chart Editor for chart editing\nin case you wanted to edit the chart you\nlittle chart editor you!",
                callback: () -> trace("Chart Editor selected")
            },
            {
                label: 'Enable Stage Editor',
                description: "Lights!\nCamera!\nActi-vate stage editor to mess with\nthe vital organs of the game.",
                callback: () -> trace("Stage Editor selected")
            },
            {
                label: 'Funky Fresh Filters',
                description: "Toggle visual effects processing.\nDisable if experiencing performance issues.",
                callback: () -> {
                    this.openSubState(new ShaderSubState());
                }
            },
            {
                label: 'Tune Up Yo Trophies',
                description: "For completionist only.",
                callback: () -> {
                    this.openSubState(new AchievementsSubState());
                }
            }
        ];

        super.create();

        addBiosBg();
        addBiosAudio();
        addBiosLogo();
        addBiosBoxes();
        addBiosText();

        updateSelection();
    }

    private function addBiosBg():Void {
        var BIOS_BG_COLOR:Int = 0xFF1927F1;
        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, BIOS_BG_COLOR));
        ShaderManager.i().applyShaders();
    }

    private function addBiosAudio():Void {
        FlxG.sound.playMusic(Paths.music('biosTheme'), 0.5, true);
        FlxG.sound.play(Paths.sound('humming'), true);
    }

    private function addBiosLogo():Void {
        biosLogo = new FlxSprite(0, 20, Paths.image('logos/friendzonedBiosLogo'));
        biosLogo.x = (FlxG.width - biosLogo.width) / 2;

        biosText = new FlxText(0, 0, FlxG.width, "Welcome to the FriendzonedOS Bios Screen, please select an option.");
        biosText.setFormat(null, OPTION_FONT_SIZE, FlxColor.WHITE, CENTER);
        biosText.x = (FlxG.width - biosText.width) / 2;
        biosText.y = biosLogo.y + biosLogo.height + biosText.height;

        add(biosLogo);
        add(biosText);
    }

    private function addBiosText():Void {
        final halfScreenWidth:Float = FlxG.width / 2;
        final rightBoxX:Float = halfScreenWidth + (SCREEN_PADDING * 3);
        descriptionText = new FlxText(rightBoxX + 10, Y_OFFSET, (FlxG.width / 2) - SCREEN_PADDING * 4);
        descriptionText.setFormat(null, DESCRIPTION_FONT_SIZE, FlxColor.WHITE, LEFT);
        add(descriptionText);

        for (i in 0...MENU_OPTIONS.length) {
            var optionText = new FlxText(X_OFFSET, Y_OFFSET + (LINE_SPACING * i), 0, MENU_OPTIONS[i].label);
            optionText.setFormat(null, OPTION_FONT_SIZE, FlxColor.WHITE, CENTER);
            biosOptions.push(optionText);
            add(optionText);
        }
    }

    private function addBiosBoxes():Void {
        final BORDER_PADDING:Int = 10;
        final DOUBLE_PADDING:Int = BORDER_PADDING * 2;
        final SCREEN_WIDTH:Int = FlxG.width;
        final SCREEN_HEIGHT:Int = FlxG.height;
        
        var borderSprite:FlxSprite = new FlxSprite(0, 0);
        borderSprite.makeGraphic(SCREEN_WIDTH, SCREEN_HEIGHT, FlxColor.TRANSPARENT);

        FlxSpriteUtil.drawRect(
            borderSprite, 
            BORDER_PADDING, 
            BORDER_PADDING, 
            SCREEN_WIDTH - DOUBLE_PADDING, 
            SCREEN_HEIGHT - DOUBLE_PADDING,
            FlxColor.TRANSPARENT, 
            {thickness: 1, color: FlxColor.WHITE}
        );

        add(borderSprite);
    
        var boxesSprite:FlxSprite = new FlxSprite(0, 0);
        boxesSprite.makeGraphic(SCREEN_WIDTH, SCREEN_HEIGHT, FlxColor.TRANSPARENT);
    
        final startY:Float = biosText.y + biosText.height + SCREEN_PADDING;
        final bottomY:Float = SCREEN_HEIGHT - BORDER_PADDING;
        final boxHeight:Float = bottomY - startY;
        
        final halfScreenWidth:Float = SCREEN_WIDTH / 2;
        final leftBoxWidth:Float = halfScreenWidth + (SCREEN_PADDING * 2);
        final rightBoxWidth:Float = halfScreenWidth - (SCREEN_PADDING * 2) - DOUBLE_PADDING;
        final rightBoxX:Float = halfScreenWidth + (SCREEN_PADDING * 2) + BORDER_PADDING;
    
        FlxSpriteUtil.drawRect(
            boxesSprite,
            BORDER_PADDING,
            startY,
            leftBoxWidth,
            boxHeight,
            FlxColor.TRANSPARENT,
            {thickness: 1, color: FlxColor.WHITE}
        );
    
        FlxSpriteUtil.drawRect(
            boxesSprite,
            rightBoxX,
            startY,
            rightBoxWidth,
            boxHeight * 0.75,
            FlxColor.TRANSPARENT,
            {thickness: 1, color: FlxColor.WHITE}
        );
    
        add(boxesSprite);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) {
            updateMenuIndex(-1);
        } else if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S) {
            updateMenuIndex(1);
        } else if (FlxG.keys.justPressed.ENTER) {
            MENU_OPTIONS[biosIndex].callback();
        } else if (FlxG.keys.justPressed.F10) {
            FlxG.sound.music.stop();
            MusicBeatState.switchState(new BootState());
        }
    }

    private function updateMenuIndex(change:Int):Void {
        biosIndex = (biosIndex + change + MENU_OPTIONS.length) % MENU_OPTIONS.length;
        updateSelection();
    }

    private function updateSelection():Void {
        for (i in 0...biosOptions.length) {
            biosOptions[i].setFormat(null, OPTION_FONT_SIZE, FlxColor.WHITE, CENTER);
        }
        biosOptions[biosIndex].setFormat(null, OPTION_FONT_SIZE, FlxColor.YELLOW, CENTER);
        descriptionText.text = MENU_OPTIONS[biosIndex].description;
    }

    private function toggleMetrics():Void {
        ClientPrefs.data.showFPS = !ClientPrefs.data.showFPS;

        if (Main.fpsVar != null) {
            Main.fpsVar.visible = ClientPrefs.data.showFPS;
        }

        ClientPrefs.saveSettings();
    }

    private function toggleSFWMode():Void {
        ClientPrefs.data.sfwMode = !ClientPrefs.data.sfwMode;
        ClientPrefs.saveSettings();
    }
}