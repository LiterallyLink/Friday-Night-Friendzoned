package substates.paint;

import flixel.FlxG;
import flixel.system.FlxSound;

class SoundManager {
    private static var lastSoundTimes:Map<String, Float> = new Map<String, Float>();
    private static var currentSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
    private static inline final DEFAULT_COOLDOWN:Float = 0.1;
    
    public static function playSound(soundPath:String, cooldown:Float = DEFAULT_COOLDOWN):Void {
        var currentTime = Date.now().getTime() / 1000;
        var lastTime = lastSoundTimes.get(soundPath);
        
        if (lastTime == null || (currentTime - lastTime) >= cooldown) {
            if (currentSounds.exists(soundPath)) {
                var sound = currentSounds.get(soundPath);
                if (sound != null) {
                    sound.stop();
                    sound.destroy();
                }
            }
            
            var sound = FlxG.sound.play(Paths.sound(soundPath));
            currentSounds.set(soundPath, sound);
            lastSoundTimes.set(soundPath, currentTime);
        }
    }
    
    public static function clearSoundCooldown(soundPath:String):Void {
        lastSoundTimes.remove(soundPath);
        if (currentSounds.exists(soundPath)) {
            var sound = currentSounds.get(soundPath);
            if (sound != null) {
                sound.stop();
                sound.destroy();
            }
            currentSounds.remove(soundPath);
        }
    }
}
