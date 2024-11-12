package states;

import backend.audio.AudioSpectrum;
import backend.audio.AudioSpectrumDebug;
import flixel.FlxG;
import flixel.text.FlxText;

class TestState extends MusicBeatState
{   
    var leftSpectrum:AudioSpectrum;
    var rightSpectrum:AudioSpectrum;
    var music:FlxSound;
    var debugText:FlxText;
    
    override function create()
    {
        super.create();
    
        debugText = new FlxText(10, 10, FlxG.width - 20);
        debugText.alignment = CENTER;
        add(debugText);
        
        debugText.text = "Loading music...";
        
        // Let's try loading without the callback first and handle in update
        music = FlxG.sound.load(Paths.music('Voices'));
        initializeSpectrums(); // Initialize right away
    }
    
    private function initializeSpectrums():Void {
        debugText.text = "Initializing spectrums...";
    
        var padding:Float = 10;
        var bassAmplitude:Float = 0.2;
        var subBassAmplitude:Float = 0.2;
        var midAmplitude:Float = 1;
        var highMidAmplitude:Float = 1.3;
        var presenceAmplitude:Float = 1.3;
        var brillianceAmplitude:Float = 2;
    
        leftSpectrum = new AudioSpectrum(music, padding, padding, true, false,
            subBassAmplitude, bassAmplitude, midAmplitude, highMidAmplitude, 
            presenceAmplitude, brillianceAmplitude);
        rightSpectrum = new AudioSpectrum(music, FlxG.width - padding, padding, true, true,
            subBassAmplitude, bassAmplitude, midAmplitude, highMidAmplitude,
            presenceAmplitude, brillianceAmplitude);
    
        add(leftSpectrum);
        add(rightSpectrum);
    
        music.play();
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (music != null && leftSpectrum != null && rightSpectrum != null) 
        {
            // Get the enhanced debug info
            //debugText.text = AudioSpectrumDebug.getSpectrumInfo(music, [leftSpectrum, rightSpectrum]);
            
            // Check and reset buffers if needed
            //AudioSpectrumDebug.checkAndResetSpectrumBuffers([leftSpectrum, rightSpectrum]);
            
            if (FlxG.keys.justPressed.SPACE) {
                if (music.playing) music.pause();
                else music.play();
            }
            
            if (FlxG.keys.justPressed.R) {
                reloadSpectrums();
            }
        }
    }
    
    public function reloadSpectrums():Void {
        if (leftSpectrum != null) {
            remove(leftSpectrum);
        }
        if (rightSpectrum != null) {
            remove(rightSpectrum);
        }
        
        initializeSpectrums();
    }
}