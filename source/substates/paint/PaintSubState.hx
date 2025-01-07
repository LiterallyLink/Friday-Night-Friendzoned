package substates.paint;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxPoint;

import backend.composite.CompositeSprite;
import substates.paint.Canvas;
import substates.paint.DrawingTool;

class PaintSubState extends FlxSubState {
    public static var bgComposite:CompositeSprite;

    private var originalWidth:Float;
    private var originalHeight:Float;
        
    private var canvas:Canvas;

    private var selectedTool:DrawingTool = DrawingTool.Pencil;
    public static var selectedColor:Int = 0xFFFFFFFF;

    private var toolButtons:Array<FlxButton> = [];    
    private static final TOOLBAR_LAYOUT:Array<DrawingTool> = [
        Pencil, Eraser,
        Dropper, Zoom,
        Spraycan, Line,
        Rectangle, Eclipse,
        Select, Text
    ];

    private var colorButtons:Array<FlxButton> = [];
    private var colorPalette:Array<Int> = [
        0xFF000000,
        0xFF484848,
        0xFFA8A8A8,
        0xFFFFFFFF,
        0xFF860A00,
        0xFFFF1400,
        0xFF854300,
        0xFFFF8116,
        0xFFA1A400,
        0xFFFBFF00,
        0xFF039600,
        0xFF06FF00,
        0xFF27A778,
        0xFF00FFA3,
        0xFF004B8F,
        0xFF0087FF,
        0xFF020036,
        0xFF0D00FF,
        0xFF2A005F,
        0xFF7300FF,
        0xFF58005D,
        0xFFF400FF,
        0xFFFF94EC,
        0xFF96FFE7
    ];
        
    private var topLeftCorner:FlxSprite;
    private var topMiddle:FlxSprite;
    private var topRightCorner:FlxSprite;
    private var leftMiddle:FlxSprite;
    private var rightMiddle:FlxSprite;
    private var bottomLeftCorner:FlxSprite;
    private var bottomMiddle:FlxSprite;
    private var bottomRightCorner:FlxSprite;

    override function create() {
        super.create();

        drawBackground();
        drawBorder();
        createCanvas();
        createDrawingTools();
        createColorPalette();
    }

    private function createCanvas():Void {
        var DEFAULT_CANVAS_X:Int = 104;
        var DEFAULT_CANVAS_Y:Int = 50;

        canvas = new Canvas();

        canvas.x = bgComposite.x + DEFAULT_CANVAS_X;
        canvas.y = bgComposite.y + DEFAULT_CANVAS_Y;

        canvas.scale.set(bgComposite.scale.x, bgComposite.scale.y);
        canvas.updateHitbox();

        add(canvas);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        updateBorderPositions();
        updateToolPositions();
        updateCanvasPosition();
        updateColorPositions();

        if (FlxG.keys.pressed.LEFT)
            updateCompositePosition(bgComposite, bgComposite.x - 2, bgComposite.y);
        if (FlxG.keys.pressed.RIGHT)
            updateCompositePosition(bgComposite, bgComposite.x + 2, bgComposite.y);
        if (FlxG.keys.pressed.UP)
            updateCompositePosition(bgComposite, bgComposite.x, bgComposite.y - 2);
        if (FlxG.keys.pressed.DOWN)
            updateCompositePosition(bgComposite, bgComposite.x, bgComposite.y + 2);
            
        if (FlxG.keys.pressed.Q)
            updateCompositeSize(bgComposite.width + 2, bgComposite.height + 2);
        if (FlxG.keys.pressed.E)
            updateCompositeSize(bgComposite.width - 2, bgComposite.height - 2);

        if (FlxG.keys.pressed.CONTROL) {
            if (FlxG.keys.justPressed.Z) {
                canvas.undo();
            }
            if (FlxG.keys.justPressed.Y) {
                canvas.redo();
            }
        }

        handleDrawing();
    }

    private function handleDrawing():Void {
        var mouseX = (FlxG.mouse.x - canvas.x) / canvas.scale.x;
        var mouseY = (FlxG.mouse.y - canvas.y) / canvas.scale.y;

        if (FlxG.mouse.justPressed) {
            canvas.handleMouseDown(mouseX, mouseY, selectedColor);
        }
        else if (FlxG.mouse.pressed) {
            canvas.handleMouseMove(mouseX, mouseY, selectedColor);
        }
        else if (FlxG.mouse.justReleased) {
            canvas.handleMouseUp(mouseX, mouseY, selectedColor);
        }
    }

    private function createDrawingTools():Void {
        for (tool in TOOLBAR_LAYOUT) {
            createToolButton(tool);
        }

        updateToolPositions();
    }
    
    private function createToolButton(tool:DrawingTool):Void {
        var toolButton = new FlxButton(0, 0, "", () -> {
            selectedTool = tool;
            canvas.setTool(tool);
        });

        toolButton.loadGraphic(Paths.image('menudesktop/applications/paint/tools/${Std.string(tool).toLowerCase()}'));
        toolButtons.push(toolButton);
        add(toolButton);
    }

    private function updateToolPositions():Void {
        var buttonSize:Int = 32;
        var buttonPadding:Int = 16;
        var baseX:Int = 16;
        var baseY:Int = 50;
        var buttonsPerRow:Int = 2;
        
        for (i in 0...toolButtons.length) {
            var row:Int = Math.floor(i / buttonsPerRow);
            var col:Int = i % buttonsPerRow;
            
            var x:Float = baseX + (col * (buttonSize + buttonPadding));
            var y:Float = baseY + (row * (buttonSize + buttonPadding));
            
            var button = toolButtons[i];
            button.x = bgComposite.x + (x * bgComposite.scale.x);
            button.y = bgComposite.y + (y * bgComposite.scale.y);
            
            button.scale.set(bgComposite.scale.x, bgComposite.scale.y);            
            button.updateHitbox();
        }
    }

    private function updateCanvasPosition():Void {
        if (canvas != null) {
            var canvasX:Int = 104;
            var canvasY:Int = 50;

            canvas.x = bgComposite.x + canvasX * bgComposite.scale.x;
            canvas.y = bgComposite.y + canvasY * bgComposite.scale.y;
            
            canvas.scale.set(bgComposite.scale.x, bgComposite.scale.y);
            canvas.updateHitbox();
        }
    }

    private function drawBackground():Void {
        bgComposite = new CompositeSprite();
        
        var backdrop = new FlxSprite();
        backdrop.loadGraphic(Paths.image('menudesktop/applications/paint/backdrop'));
        
        originalWidth = backdrop.width;
        originalHeight = backdrop.height;

        bgComposite.add(backdrop);    
        bgComposite.width = originalWidth;
        bgComposite.height = originalHeight;
        bgComposite.updateHitbox();
        
        add(bgComposite);
    }

    /*
    ===================
        BORDER MANAGER
    ===================
    */
    private function drawBorder():Void {
        createBorderSprites();

        add(topLeftCorner);
        add(topMiddle);
        add(topRightCorner);

        add(leftMiddle);
        add(rightMiddle);

        add(bottomLeftCorner);
        add(bottomMiddle);
        add(bottomRightCorner);
    }

    private function createBorderSprites():Void {
        topLeftCorner = new FlxSprite();
        topLeftCorner.loadGraphic(Paths.image('menudesktop/applications/window/top-left'));
        
        topRightCorner = new FlxSprite();
        topRightCorner.loadGraphic(Paths.image('menudesktop/applications/window/top-right'));
        
        bottomLeftCorner = new FlxSprite();
        bottomLeftCorner.loadGraphic(Paths.image('menudesktop/applications/window/bottom-left'));
        
        bottomRightCorner = new FlxSprite();
        bottomRightCorner.loadGraphic(Paths.image('menudesktop/applications/window/bottom-right'));
    
        topMiddle = new FlxSprite();
        topMiddle.loadGraphic(Paths.image('menudesktop/applications/window/top-middle'));
        
        bottomMiddle = new FlxSprite();
        bottomMiddle.loadGraphic(Paths.image('menudesktop/applications/window/bottom-middle'));
    
        leftMiddle = new FlxSprite();
        leftMiddle.loadGraphic(Paths.image('menudesktop/applications/window/middle-left'));
    
        rightMiddle = new FlxSprite();
        rightMiddle.loadGraphic(Paths.image('menudesktop/applications/window/middle-right'));
        
        updateBorderPositions();
    }
        
    private function updateBorderPositions():Void {
        var targetWidth = Math.floor(originalWidth * bgComposite.scale.x);
        var targetHeight = Math.floor(originalHeight * bgComposite.scale.y);
        
        var bounds = {
            x: bgComposite.x,
            y: bgComposite.y,
            width: targetWidth,
            height: targetHeight
        };
        
        topLeftCorner.setPosition(bounds.x, bounds.y);
        
        topRightCorner.setPosition(
            bounds.x + bounds.width - topRightCorner.width,
            bounds.y
        );
        
        bottomLeftCorner.setPosition(
            bounds.x,
            bounds.y + bounds.height - bottomLeftCorner.height
        );
        
        bottomRightCorner.setPosition(
            bounds.x + bounds.width - bottomRightCorner.width,
            bounds.y + bounds.height - bottomRightCorner.height
        );
    
        var middleWidth = targetWidth - topLeftCorner.width - topRightCorner.width;
        var middleHeight = targetHeight - topLeftCorner.height - bottomLeftCorner.height;
        
        topMiddle.setGraphicSize(Std.int(middleWidth), Std.int(topMiddle.height));
        topMiddle.updateHitbox();
        topMiddle.setPosition(bounds.x + topLeftCorner.width, bounds.y);
    
        bottomMiddle.setGraphicSize(Std.int(middleWidth), Std.int(bottomMiddle.height));
        bottomMiddle.updateHitbox();
        bottomMiddle.setPosition(bounds.x + bottomLeftCorner.width, bounds.y + bounds.height - bottomMiddle.height);
    
        leftMiddle.setGraphicSize(Std.int(leftMiddle.width), Std.int(middleHeight));
        leftMiddle.updateHitbox();
        leftMiddle.setPosition(bounds.x, bounds.y + topLeftCorner.height);
    
        rightMiddle.setGraphicSize(Std.int(rightMiddle.width), Std.int(middleHeight));
        rightMiddle.updateHitbox();
        rightMiddle.setPosition(bounds.x + bounds.width - rightMiddle.width, bounds.y + topRightCorner.height);
    }

    /*
    ===================
     COMPOSITE MANAGER
    ===================
    */
    public function updateCompositePosition(composite:CompositeSprite, newX:Float, newY:Float):Void {
        composite.x = newX;
        composite.y = newY;
        composite.updateHitbox();
    }

    public function updateCompositeSize(newWidth:Float, newHeight:Float):Void {
        var targetWidth = Math.floor(newWidth);
        var targetHeight = Math.floor(newHeight);
        
        updateBorderPositions();
        
        bgComposite.scale.x = targetWidth / originalWidth;
        bgComposite.scale.y = targetHeight / originalHeight;
        bgComposite.width = targetWidth;
        bgComposite.height = targetHeight;

        bgComposite.updateHitbox();
        
        updateBorderPositions();
    }

    /*
    ===================
       COLOR MANAGER
    ===================
    */
    public function createColorPalette():Void {
        for (color in colorPalette) {
            createColorButton(color);
        }
        updateColorPositions();
    }

    private function createColorButton(color:Int):Void {
        var button = new FlxButton(0, 0, "", () -> selectedColor = color);
        
        var buttonSprite = new FlxSprite();
        buttonSprite.makeGraphic(22, 22, color);
        
        FlxSpriteUtil.drawLine(buttonSprite, 0, 0, 21, 0, {color: FlxColor.WHITE, thickness: 3});
        FlxSpriteUtil.drawLine(buttonSprite, 0, 0, 0, 21, {color: FlxColor.WHITE, thickness: 3}); 
        
        FlxSpriteUtil.drawLine(buttonSprite, 21, 0, 21, 21, {color: FlxColor.BLACK, thickness: 3}); 
        FlxSpriteUtil.drawLine(buttonSprite, 0, 21, 21, 21, {color: FlxColor.BLACK, thickness: 3}); 
        
        button.loadGraphicFromSprite(buttonSprite);
        colorButtons.push(button);
        add(button);
    }

    public function updateColorPositions():Void {
        var buttonSize = 24;
        var padding = 6;
        var columns = 2;
        var startX = 710;
        var startY = 44;

        for (i in 0...colorButtons.length) {
            var row:Int = Math.floor(i / columns);
            var col:Int = i % columns;
            
            var x:Float = startX;
            if (col == 0) {
                x += buttonSize + padding;
            }
            
            var y:Float = startY + (row * (buttonSize + padding));
            
            var button = colorButtons[i];
            button.x = bgComposite.x + (x * bgComposite.scale.x);
            button.y = bgComposite.y + (y * bgComposite.scale.y);
            
            button.scale.set(bgComposite.scale.x, bgComposite.scale.y);
            button.updateHitbox();
        }
    }
}