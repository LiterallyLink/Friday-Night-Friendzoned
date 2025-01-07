package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import openfl.geom.Rectangle;

enum SpawnPosition {
    TopLeft;
    TopRight;
    BottomLeft;
    BottomRight;
}

typedef MenuItem = {
    label:String,
    ?icon:String,
    callback:Void->Void
}

/**
 * A generic context menu that can be used for any right-click menu scenario.
 * Supports custom menu items, positioning, and styling.
 */
class ContextMenu extends FlxGroup {
    // Customizable style properties
    public static var BUTTON_HEIGHT:Int = 20;
    public static var MENU_WIDTH:Int = 140;
    public static var TEXT_PADDING:Int = 5;
    public static var BORDER_SIZE:Int = 1;
    public static var BACKGROUND_COLOR:FlxColor = 0xFFA1A1A1;
    public static var HOVER_COLOR:FlxColor = 0xFF0090E4;
    public static var TEXT_COLOR:FlxColor = FlxColor.BLACK;
    public static var HOVER_TEXT_COLOR:FlxColor = FlxColor.WHITE;
    public static var FONT_SIZE:Int = 8;
    
    private var backdrop:FlxSprite;
    private var menuItems:Array<FlxButton>;
    private var spawnPosition:SpawnPosition;
    private var menuOptions:Array<MenuItem>;

    /**
     * Creates a new context menu
     * @param options Array of menu items with labels and callbacks
     * @param spawnPosition The corner position where the menu should spawn relative to the mouse
     */
    public function new(options:Array<MenuItem>, spawnPosition:SpawnPosition = SpawnPosition.TopLeft) {
        super();
        
        this.menuOptions = options;
        this.spawnPosition = spawnPosition;
        this.menuItems = [];
        
        createMenu();
        createMenuItems();
    }

    /**
     * Calculates the menu position based on the spawn position setting
     * @return Object containing x and y coordinates for the menu
     */
    private function calculateMenuPosition():{ x:Float, y:Float } {
        var mousePos = FlxG.mouse.getPosition();
        var totalHeight = menuOptions.length * BUTTON_HEIGHT + (BORDER_SIZE * 2);
        var totalWidth = MENU_WIDTH + (BORDER_SIZE * 2);
        
        var x = mousePos.x;
        var y = mousePos.y;
        
        switch (spawnPosition) {
            case TopLeft:
                // Default position, no adjustment needed
            case TopRight:
                x = mousePos.x - totalWidth;
            case BottomLeft:
                y = mousePos.y - totalHeight;
            case BottomRight:
                x = mousePos.x - totalWidth;
                y = mousePos.y - totalHeight;
        }
        
        // Keep menu within screen bounds
        if (x < 0) x = 0;
        if (y < 0) y = 0;
        if (x + totalWidth > FlxG.width) x = FlxG.width - totalWidth;
        if (y + totalHeight > FlxG.height) y = FlxG.height - totalHeight;
        
        mousePos.put();
        return { x: x, y: y };
    }

    /**
     * Initializes the menu backdrop and borders
     */
    private function createMenu():Void {
        var pos = calculateMenuPosition();
        
        backdrop = new FlxSprite(pos.x, pos.y);

        var totalHeight = menuOptions.length * BUTTON_HEIGHT;
        var bgWidth = MENU_WIDTH + (BORDER_SIZE * 2);
        var bgHeight = totalHeight + (BORDER_SIZE * 2);
        
        backdrop.makeGraphic(bgWidth, bgHeight, FlxColor.TRANSPARENT);
        backdrop.pixels.fillRect(new Rectangle(BORDER_SIZE, BORDER_SIZE, MENU_WIDTH, totalHeight), BACKGROUND_COLOR);
        
        createBorders(bgWidth, bgHeight);
        add(backdrop);
    }

    /**
     * Creates the menu borders with proper shading
     */
    private function createBorders(width:Float, height:Float):Void {
        backdrop.pixels.fillRect(new Rectangle(0, 0, width, BORDER_SIZE), FlxColor.WHITE);
        backdrop.pixels.fillRect(new Rectangle(0, 0, BORDER_SIZE, height), FlxColor.WHITE);
        
        backdrop.pixels.fillRect(new Rectangle(width - BORDER_SIZE, 0, BORDER_SIZE, height), FlxColor.BLACK);
        backdrop.pixels.fillRect(new Rectangle(0, height - BORDER_SIZE, width, BORDER_SIZE), FlxColor.BLACK);
    }

    /**
     * Creates all menu item buttons
     */
    private function createMenuItems():Void {
        var pos = calculateMenuPosition();
        
        for (i in 0...menuOptions.length) {
            var option = menuOptions[i];
            var button = createButton(
                option.label,
                "left",
                pos.x,
                pos.y + (i * BUTTON_HEIGHT),
                option.callback
            );
            
            menuItems.push(button);
            add(button);
        }
    }

    /**
     * Creates a single menu button with proper styling
     */
    private function createButton(text:String, alignment:String, x:Float, y:Float, onClick:Void->Void):FlxButton {
        var button = new FlxButton(x + BORDER_SIZE, y + BORDER_SIZE, text, onClick);
        button.makeGraphic(MENU_WIDTH, BUTTON_HEIGHT, FlxColor.TRANSPARENT);
        
        button.label.alignment = alignment;
        button.label.x += TEXT_PADDING;
        button.label.setFormat(null, FONT_SIZE, TEXT_COLOR);
        
        button.onOver.callback = () -> {
            button.makeGraphic(MENU_WIDTH, BUTTON_HEIGHT, HOVER_COLOR);
            button.label.setFormat(null, FONT_SIZE, HOVER_TEXT_COLOR);
        };
        
        button.onOut.callback = () -> {
            button.makeGraphic(MENU_WIDTH, BUTTON_HEIGHT, FlxColor.TRANSPARENT);
            button.label.setFormat(null, FONT_SIZE, TEXT_COLOR);
        };
        
        return button;
    }

    /**
     * Helper method to check if a point overlaps with any part of the menu
     * @param point The point to check for overlap
     * @return Whether the point overlaps with the menu or any of its items
     */
    public function overlapsPoint(point:FlxPoint):Bool {
        if (backdrop.overlapsPoint(point)) return true;
        
        for (button in menuItems) {
            if (button.overlapsPoint(point)) return true;
        }
        
        return false;
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
    }
}