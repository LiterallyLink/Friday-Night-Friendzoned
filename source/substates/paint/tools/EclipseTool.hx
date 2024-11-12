package substates.paint.tools;

import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class EclipseTool extends BaseTool {
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
        
        if (startPos == null) {
            startPos = FlxPoint.get(0, 0);
        }
        
        canvas.draw(previewBitmap);
        
        drawEclipse(
            Math.floor(startPos.x), 
            Math.floor(startPos.y),
            Math.floor(x), 
            Math.floor(y), 
            color
        );
    }

    override public function onMouseUp(x:Float, y:Float, color:Int):Void {
        if (!isDrawing) return;
        
        // Draw final eclipse
        canvas.draw(previewBitmap);
        drawEclipse(
            Math.floor(startPos.x), 
            Math.floor(startPos.y),
            Math.floor(x), 
            Math.floor(y), 
            color
        );
        
        cleanupPreview();
        isDrawing = false;
    }

    private function drawEclipse(startX:Int, startY:Int, endX:Int, endY:Int, color:Int):Void {
        var centerX:Float = (startX + endX) / 2;
        var centerY:Float = (startY + endY) / 2;
        var radiusX:Float = Math.abs(endX - startX) / 2;
        var radiusY:Float = Math.abs(endY - startY) / 2;
        
        // Draw more points for smoother ellipse
        for (angle in 0...360) {
            var radian:Float = angle * Math.PI / 180;
            var x:Float = centerX + radiusX * Math.cos(radian);
            var y:Float = centerY + radiusY * Math.sin(radian);
            
            drawPixel(Std.int(x), Std.int(y), color);
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