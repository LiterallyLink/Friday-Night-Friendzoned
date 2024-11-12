package substates.paint.tools;

import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class SpraycanTool extends BaseTool {
    private var isDrawing:Bool = false;
    private var sprayTimer:Float = 0;
    private var sprayRadius:Int = 15;
    private var sprayDensity:Int = 30;
    
    public function new(canvas:BitmapData) {
        super(canvas);
    }

    override public function onMouseDown(x:Float, y:Float, color:Int):Void {
        isDrawing = true;
        sprayPaint(x, y, color);

        SoundManager.playSound('paint/OnSpray', 1);
    }

    override public function onMouseMove(x:Float, y:Float, color:Int):Void {
        if (!isDrawing) return;

        sprayTimer += FlxG.elapsed;

        if (sprayTimer >= 1/30) {
            sprayPaint(x, y, color);
            sprayTimer = 0;

            SoundManager.playSound('paint/MoveSpray', 7);
        }
    }

    override public function onMouseUp(x:Float, y:Float, color:Int):Void {
        isDrawing = false;

        SoundManager.clearSoundCooldown('paint/MoveSpray');
        SoundManager.playSound('paint/OffSpray');
    }

    private function sprayPaint(x:Float, y:Float, color:Int):Void {    
        for (i in 0...sprayDensity) {
            var angle = Math.random() * Math.PI * 2;
            var distance = Math.sqrt(Math.random()) * sprayRadius;
            
            var sprayX = x + Math.cos(angle) * distance;
            var sprayY = y + Math.sin(angle) * distance;
            
            drawSprayPixel(Math.floor(sprayX), Math.floor(sprayY), color);
        }
    }

    private function drawSprayPixel(x:Int, y:Int, color:Int):Void {
        canvas.setPixel32(x, y, color);
    }

    override public function cleanup():Void {
        isDrawing = false;
        sprayTimer = 0;
    }
}