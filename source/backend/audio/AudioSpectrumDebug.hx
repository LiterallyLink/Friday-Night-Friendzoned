package backend.audio;

import flixel.sound.FlxSound;
import backend.CoolUtil;
import backend.audio.AudioVisualizer;

@:access(flixel.sound.FlxSound)
@:access(backend.audio.AudioSpectrum)
class AudioSpectrumDebug
{
    private var vis:AudioVisualizer;
    private var spectrum:AudioSpectrum;
    private var lastBufferReset:Float = 0;
    private var lastValidSampleCount:Int = 0;
    private var lastFreqDataLength:Int = 0;
    private var consecutiveEmptyFrames:Int = 0;
    private static inline final MAX_EMPTY_FRAMES:Int = 10;

    public function new(visualizer:AudioVisualizer)
    {
        vis = visualizer;
        if (vis != null && vis.audioData != null) {
            lastValidSampleCount = vis.audioData.length;
        }
    }

    public function getDetailedBufferInfo():String
    {
        var info = '';
        if (vis != null)
        {
            // Buffer status
            info += 'Buffer Set: ${vis.setBuffer}\n';
            info += 'Audio Data: ${vis.audioData != null ? "Present" : "Missing"}\n';
            info += 'Audio Data Length: ${vis.audioData != null ? vis.audioData.length : 0}\n';
            info += 'Sample Rate: ${Std.int(vis.sampleRate)}Hz\n';
            
            // Process status
            if (spectrum != null) {
                info += '\nFFT Processing:\n';
                info += 'Samples Length: ${spectrum.samples.length}\n';
                info += 'Freq Data Arrays: ${spectrum.frequencyData.length}\n';
                if (spectrum.frequencyData.length > 0) {
                    var lastArray = spectrum.frequencyData[spectrum.frequencyData.length - 1];
                    info += 'Last Freq Array Length: ${lastArray.length}\n';
                    
                    // Check for valid frequency data
                    var nonZeroFreqs = 0;
                    for (freq in lastArray) {
                        if (Math.abs(freq) > 0.0001) nonZeroFreqs++;
                    }
                    info += 'Non-zero frequencies: $nonZeroFreqs\n';
                }
                
                // Bar visualization status
                var activeBarCount = 0;
                var maxBarScale = 0.0;
                for (bar in spectrum.bars) {
                    var scale = spectrum.isVertical ? Math.abs(bar.scale.x) : bar.scale.y;
                    if (scale > 1.0) activeBarCount++;
                    maxBarScale = Math.max(maxBarScale, scale);
                }
                info += 'Active Bars: $activeBarCount\n';
                info += 'Max Bar Scale: $maxBarScale\n';
                info += 'Empty Frames: $consecutiveEmptyFrames\n';
            }
            
            // Timing information
            var pos:Int = Std.int(Math.floor(vis.snd.time * vis.sampleRate / 1000));
            var remaining:Int = vis.numSamples - pos;
            info += '\nTiming:\n';
            info += 'Sample Position: ${CoolUtil.formatNumberWithCommas(pos)}\n';
            info += 'Total Samples: ${CoolUtil.formatNumberWithCommas(vis.numSamples)}\n';
            info += 'Samples Remaining: ${CoolUtil.formatNumberWithCommas(remaining)}\n';
            
            // Sound properties
            info += '\nSound Properties:\n';
            info += 'Volume: ${vis.snd.volume}\n';
            info += 'Amplitude: ${vis.snd.amplitude}\n';
            info += 'Playing: ${vis.snd.playing}\n';
        }
        return info;
    }

    public function checkAndUpdateState():Bool {
        if (vis == null || !vis.snd.playing) return false;
        
        var currentPos = Std.int(Math.floor(vis.snd.time * vis.sampleRate / 1000));
        
        // Check the FFT window data
        if (vis.audioData != null) {
            var midPoint = Std.int(currentPos + 1024);
            if (midPoint < vis.audioData.length) {
                var hasData = false;
                for (i in 0...10) {
                    if (vis.audioData[midPoint + i] != 0) {
                        hasData = true;
                        break;
                    }
                }
                if (!hasData) {
                    trace('No data in FFT window at position $currentPos');
                    return true;
                }
            }
        }
        
        return false;
    }

    public function setSpectrum(audioSpectrum:AudioSpectrum):Void {
        spectrum = audioSpectrum;
    }

    public function resetBuffer():Void
    {
        if (vis != null)
        {
            trace('Attempting buffer reset...');
            trace('Current audio data length: ${vis.audioData != null ? vis.audioData.length : 0}');
            
            vis.setBuffer = false;
            vis.checkAndSetBuffer();
            
            if (vis.audioData != null) {
                trace('Buffer reset - New length: ${vis.audioData.length}');
                // Clear existing data to force refresh
                if (spectrum != null) {
                    spectrum.samples = [];
                    spectrum.frequencyData = [];
                }
            } else {
                trace('Buffer reset failed - No audio data');
            }
        }
    }

    public function checkNeedsReset():Bool {
        if (vis == null || !vis.snd.playing) return false;
        
        if (spectrum != null) {
            // Check if we have valid frequency data
            if (spectrum.frequencyData.length == 0 || 
                (spectrum.frequencyData.length > 0 && spectrum.frequencyData[spectrum.frequencyData.length - 1].length == 0)) {
                consecutiveEmptyFrames++;
                if (consecutiveEmptyFrames >= MAX_EMPTY_FRAMES) {
                    trace('No frequency data for ${consecutiveEmptyFrames} frames, triggering reset');
                    consecutiveEmptyFrames = 0;
                    return true;
                }
            } else {
                consecutiveEmptyFrames = 0;
            }
            
            // Check active bars
            var activeBarCount = 0;
            for (bar in spectrum.bars) {
                var scale = spectrum.isVertical ? Math.abs(bar.scale.x) : bar.scale.y;
                if (scale > 1.0) activeBarCount++;
            }
            
            if (activeBarCount == 0 && vis.snd.playing) {
                trace('No active bars while sound is playing, triggering reset');
                return true;
            }
        }
        
        return false;
    }

    /**
     * Static helper function to get detailed debug info for a music track and its spectrums
     */
    public static function getSpectrumInfo(music:FlxSound, spectrums:Array<AudioSpectrum>):String
    {
        var debugInfo = '';
        debugInfo += '=== Music Info ===\n';
        debugInfo += 'Music Time: ${music.time/1000}s\n';
        debugInfo += 'Music Length: ${music.length/1000}s\n';
        debugInfo += 'Music Playing: ${music.playing}\n';
        debugInfo += 'Music Volume: ${music.volume}\n';
        debugInfo += 'Music Amplitude: ${music.amplitude}\n\n';
        
        for (i in 0...spectrums.length) {
            debugInfo += '=== Spectrum ${i + 1} ===\n';
            debugInfo += spectrums[i].debug.getDetailedBufferInfo() + '\n';
        }
        
        return debugInfo;
    }
    
    public static function checkAndResetSpectrumBuffers(spectrums:Array<AudioSpectrum>):Void
    {
        for (spectrum in spectrums) {
            if (spectrum.debug.checkAndUpdateState()) {
                spectrum.debug.resetBuffer();
            }
        }
    }
}