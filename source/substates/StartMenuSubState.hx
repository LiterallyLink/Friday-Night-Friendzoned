package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class StartMenuSubState extends FlxSubState {
    private var menuBg:FlxSprite;
    private var menuButtons:Array<FlxButton>;

    private var taskbar:FlxSprite;
    private var onDown:FlxSprite;
    
    private static inline var BUTTON_HEIGHT:Int = 25;
    private static inline var BUTTON_PADDING:Int = 2;
    private static inline var MENU_WIDTH:Int = 200;
    private static inline var TEXT_PADDING:Int = 10;
    
    public function new(onDown, taskbar:FlxSprite) {
        super();

        this.onDown = onDown;
        this.taskbar = taskbar;
        
        menuButtons = [];
    }

    override public function create():Void {
        super.create();

        var menuItems:Array<String> = [
            "Programs",
            "Documents",
            "Fullscreen",
            "Find",
            "Help",
            "Run...",
            "Reinstall",
            "Reboot...",
            "Shutdown"
        ];

        var totalButtonHeight:Float = (BUTTON_HEIGHT + BUTTON_PADDING) * menuItems.length;
        var menuX:Float = 5;
        var menuY:Float = taskbar.y - totalButtonHeight;

        menuBg = new FlxSprite(menuX, menuY);
        menuBg.makeGraphic(MENU_WIDTH, Std.int(totalButtonHeight), 0xFFA1A1A1);
        add(menuBg);

        var yPosition:Float = menuY;
        for (item in menuItems) {
            var button = new FlxButton(menuX + 5, yPosition, item, function() {
                trace('Clicked: ${item}');
            });
            
            button.makeGraphic(MENU_WIDTH - 10, BUTTON_HEIGHT, FlxColor.TRANSPARENT);
            button.label.alignment = "left";
            button.label.x += TEXT_PADDING;
            
            add(button);
            menuButtons.push(button);
            
            yPosition += BUTTON_HEIGHT + BUTTON_PADDING;
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        for (button in menuButtons) {
            if (button.status == FlxButton.HIGHLIGHT) {
                button.makeGraphic(MENU_WIDTH - 10, BUTTON_HEIGHT, 0xFF0090E4);
            } else {
                button.makeGraphic(MENU_WIDTH - 10, BUTTON_HEIGHT, FlxColor.TRANSPARENT);
            }
        }

        if (FlxG.mouse.justPressed) {
            onDown.visible = false;
            close();
        }
    }

    override public function close() {
        if (closeCallback != null)
            closeCallback();
        super.close();
    }
}