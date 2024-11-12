package substates.paint.tools;

import openfl.display.BitmapData;

class BaseTool {
    private var canvas:BitmapData;
    private var pixelSize:Int = 3;
    
    public function new(canvas:BitmapData) {
        this.canvas = canvas;
    }
    
    public function onMouseDown(x:Float, y:Float, color:Int):Void {}
    public function onMouseMove(x:Float, y:Float, color:Int):Void {}
    public function onMouseUp(x:Float, y:Float, color:Int):Void {}
    public function cleanup():Void {}

    private function hasMouseMoved(oldX:Float, oldY:Float, newX:Float, newY:Float):Bool {
        return Math.floor(oldX) != Math.floor(newX) || Math.floor(oldY) != Math.floor(newY);
    }
    
    private function drawPixel(x:Int, y:Int, color:Int):Void {
        var halfSize:Int = Math.floor(pixelSize / 2);
        
        var startX:Int = x - halfSize;
        var startY:Int = y - halfSize;
        var endX:Int = x + halfSize + 1;
        var endY:Int = y + halfSize + 1;
        
        if (startX < 0) startX = 0;
        if (startY < 0) startY = 0;
        if (endX > canvas.width) endX = canvas.width;
        if (endY > canvas.height) endY = canvas.height;
        
        var px:Int = startX;
        while (px < endX) {
            var py:Int = startY;
            while (py < endY) {
                canvas.setPixel32(px, py, color);
                py++;
            }
            px++;
        }
    }
    
    public function updateCanvas(newCanvas:BitmapData):Void {
        this.canvas = newCanvas;
    }
}