package substates.paint.tools;

import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class LineTool extends BaseTool {
    private var isDrawing:Bool = false;
    private var startPos:FlxPoint;
    private var previewBitmap:BitmapData;
    
    public function new(canvas:BitmapData) {
        super(canvas);
        startPos = FlxPoint.get(0, 0);
    }

    override public function onMouseDown(x:Float, y:Float, color:Int):Void {
        isDrawing = true;

        if (startPos == null) {
            startPos = FlxPoint.get(0, 0);
        }
        
        startPos.set(x, y);
        
        cleanupPreview();
        
        if (canvas != null) {
            previewBitmap = canvas.clone();
        }
    }

    override public function onMouseMove(x:Float, y:Float, color:Int):Void {
        if (!isDrawing || canvas == null) return;
        
        if (previewBitmap != null) {
            canvas.draw(previewBitmap);
            
            drawLine(
                Math.floor(startPos.x), 
                Math.floor(startPos.y),
                Math.floor(x), 
                Math.floor(y), 
                color
            );
        }
    }

    override public function onMouseUp(x:Float, y:Float, color:Int):Void {
        if (!isDrawing) return;
        
        canvas.draw(previewBitmap);
        drawLine(
            Math.floor(startPos.x), 
            Math.floor(startPos.y),
            Math.floor(x), 
            Math.floor(y), 
            color
        );
        
        cleanupPreview();
        isDrawing = false;
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

    private function cleanupPreview():Void {
        if (previewBitmap != null) {
            previewBitmap.dispose();
            previewBitmap = null;
        }
    }

    override public function cleanup():Void {
        isDrawing = false;
        cleanupPreview();
        if (startPos != null) {
            startPos.put();
            startPos = null;
        }
    }
}