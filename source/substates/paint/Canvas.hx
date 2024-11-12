package substates.paint;

import flixel.FlxSprite;
import openfl.display.BitmapData;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

import substates.paint.PaintSubState;
import substates.paint.DrawingTool;
import substates.paint.tools.*;

class Canvas extends FlxSprite {
    public var bitmap:BitmapData;
    private var currentTool:BaseTool;
    private var tools:Map<DrawingTool, BaseTool>;
    
    private var undoStack:Array<BitmapData>;
    private var redoStack:Array<BitmapData>;
    private static final MAX_HISTORY:Int = 50;

    public function new() {
        super();
        loadGraphic(Paths.image('menudesktop/applications/paint/canvas'));
        
        createCanvas();
        createTools();
        
        undoStack = [];
        redoStack = [];
        
        saveState();
    }

    private function createCanvas():Void {
        bitmap = new BitmapData(Std.int(width), Std.int(height), true, FlxColor.WHITE);
        pixels = bitmap;
    }

    private function createTools():Void {
        tools = new Map<DrawingTool, BaseTool>();
		
        tools.set(DrawingTool.Pencil, new PencilTool(bitmap));
		tools.set(DrawingTool.Eraser, new EraserTool(bitmap));
		tools.set(DrawingTool.Dropper, new DropperTool(bitmap));
		tools.set(DrawingTool.Spraycan, new SpraycanTool(bitmap));
		tools.set(DrawingTool.Line, new LineTool(bitmap));
		tools.set(DrawingTool.Rectangle, new RectangleTool(bitmap));
		tools.set(DrawingTool.Eclipse, new EclipseTool(bitmap));

		setTool(DrawingTool.Pencil);
    }

	public function setTool(tool:DrawingTool):Void {
		if (currentTool != null) {
			currentTool.cleanup();
			currentTool = null;
		}
		
		currentTool = tools.get(tool);
	}

	public function handleMouseDown(x:Float, y:Float, color:Int):Void {
		if (currentTool == null || !isInBounds(x, y)) {
			return;
		}
		
		currentTool.onMouseDown(x, y, color);
		updateCanvas();
	}

    public function handleMouseMove(x:Float, y:Float, color:Int):Void {
        var clampedX = Math.max(0, Math.min(x, bitmap.width - 1));
        var clampedY = Math.max(0, Math.min(y, bitmap.height - 1));
        
        if (currentTool == null) return;
        currentTool.onMouseMove(clampedX, clampedY, color);
        updateCanvas();
    }

    public function handleMouseUp(x:Float, y:Float, color:Int):Void {
        if (currentTool == null) return;

        currentTool.onMouseUp(x, y, color);
        updateCanvas();
        saveState();
    }

    public function isInBounds(x:Float, y:Float):Bool {
        return x >= 0 && x < bitmap.width && y >= 0 && y < bitmap.height;
    }

    private function updateCanvas():Void {
        pixels = bitmap;
        dirty = true;
    }

    public function undo():Bool {
        if (undoStack.length <= 1) return false;
        
        redoStack.push(bitmap.clone());
        undoStack.pop();
        bitmap = undoStack[undoStack.length - 1].clone();
        updateCanvas();
        return true;
    }

    public function redo():Bool {
        if (redoStack.length == 0) return false;
        
        var redoState = redoStack.pop();
        bitmap = redoState;
        undoStack.push(redoState.clone());
        updateCanvas();
        return true;
    }

    private function saveState():Void {
        undoStack.push(bitmap.clone());
        redoStack = [];
        
        while (undoStack.length > MAX_HISTORY) {
            undoStack.shift();
        }
    }
}