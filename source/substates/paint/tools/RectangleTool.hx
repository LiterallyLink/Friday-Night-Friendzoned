package substates.paint.tools;

import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class RectangleTool extends BaseTool {
    private var isDrawing:Bool = false;
    private var startPos:FlxPoint;
    private var previewBitmap:BitmapData;
    private var pixelSize:Int = 1;
    
    public function new(canvas:BitmapData) {
        super(canvas);
        getPoint();
    }

    private function getPoint():Void {
        if (startPos == null) {
            startPos = FlxPoint.get(0, 0);
        }
    }

    override public function onMouseDown(x:Float, y:Float, color:Int):Void {
        isDrawing = true;
        getPoint();
        startPos.set(x, y);
        cleanupPreview();
        previewBitmap = canvas.clone();
    }

    override public function onMouseMove(x:Float, y:Float, color:Int):Void {
        if (!isDrawing || previewBitmap == null) return;
        
        canvas.draw(previewBitmap);
        
        drawRectangle(
            Math.floor(startPos.x), 
            Math.floor(startPos.y),
            Math.floor(x), 
            Math.floor(y), 
            color
        );
    }

    override public function onMouseUp(x:Float, y:Float, color:Int):Void {
        if (!isDrawing) return;
        
        canvas.draw(previewBitmap);
        drawRectangle(
            Math.floor(startPos.x), 
            Math.floor(startPos.y),
            Math.floor(x), 
            Math.floor(y), 
            color
        );
        
        cleanupPreview();
        isDrawing = false;
    }

    private function drawRectangle(startX:Int, startY:Int, endX:Int, endY:Int, color:Int):Void {
        var x1:Int = Std.int(Math.min(startX, endX));
        var y1:Int = Std.int(Math.min(startY, endY));
        var x2:Int = Std.int(Math.max(startX, endX));
        var y2:Int = Std.int(Math.max(startY, endY));
        
        drawLine(Std.int(x1), Std.int(y1), Std.int(x2), Std.int(y1), color); // Top
        drawLine(Std.int(x2), Std.int(y1), Std.int(x2), Std.int(y2), color); // Right
        drawLine(Std.int(x2), Std.int(y2), Std.int(x1), Std.int(y2), color); // Bottom
        drawLine(Std.int(x1), Std.int(y2), Std.int(x1), Std.int(y1), color); // Left
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

    private function drawPixel(x:Int, y:Int, color:Int):Void {
        var halfSize:Int = Math.floor(pixelSize / 2);
        
        for (offsetX in -halfSize...halfSize + 1) {
            for (offsetY in -halfSize...halfSize + 1) {
                var px:Int = x + offsetX;
                var py:Int = y + offsetY;
                
                canvas.setPixel32(px, py, color);
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