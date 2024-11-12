package substates.paint.tools;

import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class PencilTool extends BaseTool {
    private var isDrawing:Bool = false;
    private var lastPos:FlxPoint;
    
    public function new(canvas:BitmapData) {
        super(canvas);
        lastPos = new FlxPoint(0, 0);
    }

    override public function onMouseDown(x:Float, y:Float, color:Int):Void {        
        isDrawing = true;
        if (lastPos == null) lastPos = new FlxPoint(0, 0);
        lastPos.set(x, y);
        drawAtPosition(x, y, color);
    }

    override public function onMouseMove(x:Float, y:Float, color:Int):Void {
        if (!isDrawing) return;

        if (!hasMouseMoved(lastPos.x, lastPos.y, x, y)) {
            return;
        }

        drawLine(
            Math.floor(lastPos.x), 
            Math.floor(lastPos.y),
            Math.floor(x), 
            Math.floor(y), 
            color
        );
        
        lastPos.set(x, y);
    }

    override public function onMouseUp(x:Float, y:Float, color:Int):Void {
        isDrawing = false;
    }

    private function drawAtPosition(x:Float, y:Float, color:Int):Void {
        drawPixel(Math.floor(x), Math.floor(y), color);
    }

    private function drawLine(x0:Int, y0:Int, x1:Int, y1:Int, color:Int):Void {
        var dx:Int = Std.int(Math.abs(x1 - x0));
        var dy:Int = Std.int(Math.abs(y1 - y0));
        var sx:Int = (x0 < x1) ? 1 : -1;
        var sy:Int = (y0 < y1) ? 1 : -1;
        var err:Int = dx - dy;

        while (true) {
            drawPixel(x0, y0, color);

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
        isDrawing = false;
        if (lastPos != null) {
            lastPos.destroy();
            lastPos = null;
        }
    }
}