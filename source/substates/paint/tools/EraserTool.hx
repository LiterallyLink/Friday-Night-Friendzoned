package substates.paint.tools;

import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class EraserTool extends BaseTool {
    private var isErasing:Bool = false;
    private var lastPos:FlxPoint;
    private var eraserSize:Int = 10;
    
    public function new(canvas:BitmapData) {
        super(canvas);
        lastPos = new FlxPoint(0, 0);
    }

    override public function onMouseDown(x:Float, y:Float, color:Int):Void {
        isErasing = true;
        if (lastPos == null) lastPos = new FlxPoint(0, 0);
        lastPos.set(x, y);
        eraseAtPosition(x, y);
    
    }

    override public function onMouseMove(x:Float, y:Float, color:Int):Void {
        if (!isErasing) return;

        if (!hasMouseMoved(lastPos.x, lastPos.y, x, y)) {
            return;
        }
    
        eraseLine(
            Math.floor(lastPos.x), 
            Math.floor(lastPos.y),
            Math.floor(x), 
            Math.floor(y)
        );
        
        lastPos.set(x, y);
    }

    override public function onMouseUp(x:Float, y:Float, color:Int):Void {
        if (isErasing) {
            isErasing = false;
        }
    }

    private function eraseAtPosition(x:Float, y:Float):Void {
        erasePixel(Math.floor(x), Math.floor(y));
    }

    private function erasePixel(x:Int, y:Int):Void {
        var halfSize:Int = Math.floor(eraserSize / 2);
        
        for (offsetX in -halfSize...halfSize + 1) {
            for (offsetY in -halfSize...halfSize + 1) {
                var px:Int = x + offsetX;
                var py:Int = y + offsetY;
                
                canvas.setPixel32(px, py, FlxColor.WHITE);
            }
        }
    }

    private function eraseLine(x0:Int, y0:Int, x1:Int, y1:Int):Void {
        var dx:Int = Std.int(Math.abs(x1 - x0));
        var dy:Int = Std.int(Math.abs(y1 - y0));
        var sx:Int = (x0 < x1) ? 1 : -1;
        var sy:Int = (y0 < y1) ? 1 : -1;
        var err:Int = dx - dy;

        while (true) {
            erasePixel(x0, y0);

            if (x0 == x1 && y0 == y1) break;

            var e2:Int = 2 * err;
            if (e2 > -dy) {
                err -= dy;
                x0 += sx;
            }
            if (e2 < dx) {
                err += dx;
                y0 += sy;
            }
        }
    }

    override public function cleanup():Void {
        isErasing = false;

        if (lastPos != null) {
            lastPos.destroy();
            lastPos = null;
        }
    }
}