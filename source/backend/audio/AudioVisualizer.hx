package backend.audio;

import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import backend.audio.dsp.FFT;
import lime.utils.Int16Array;
import backend.MathUtil;

using Lambda;

class AudioVisualizer
{
    public var snd:FlxSound;
    public var setBuffer:Bool = false;
    public var audioData:Int16Array;
    public var sampleRate:Int = 44100; // default, ez?
    public var numSamples:Int = 0;

    // Reusable arrays as class properties
    private var chunk:Array<Float>;
    private var windowCache:Array<Float>;
    private var freqOutput:Array<Array<Float>>;

    public function new(snd:FlxSound)
    {
        this.snd = snd;

        // Initialize reusable arrays
        final fftN = 1024;
        chunk = [for (i in 0...fftN) 0.0];
		windowCache = [for (i in 0...fftN) 
			0.42 - 0.5 * Math.cos(2 * Math.PI * i / fftN) + 
			0.08 * Math.cos(4 * Math.PI * i / fftN)
		];
		freqOutput = [[]];
    }

    public function funnyFFT(samples:Array<Float>, ?skipped:Int = 1):Array<Array<Float>>
    {
        // nab multiple samples at once in while / for loops?
        var fs:Float = 44100 / skipped; // sample rate shit?

        final fftN = 1024;
        final halfN = Std.int(fftN / 2);
        final overlap = 0.5;
        final hop = Std.int(fftN * (1 - overlap));

        // helpers, note that spectrum indexes suppose non-negative frequencies
        final binSize = fs / fftN;
        final indexToFreq = function(k:Int) {
            var powShit:Float = FlxMath.remapToRange(k, 0, halfN, 0, MathUtil.logBase(10, halfN)); // 4.3 is almost the log of 20Khz or so. Close enuf lol
            return 1.0 * (Math.pow(10, powShit)); // we need the `1.0` to avoid overflows
        };

        // "melodic" band-pass filter
        final minFreq = 20.70;
        final maxFreq = 4000.01;
        final melodicBandPass = function(k:Int, s:Float) {
            final freq = indexToFreq(k);
            final filter = freq > minFreq - binSize && freq < maxFreq + binSize ? 1 : 0;
            return s;
        };

        // Clear the existing array instead of creating new ones
        freqOutput[0].resize(0);

        var c = 0;
        while (c < samples.length)
        {
            // Reuse chunk array instead of creating new one
            for (n in 0...fftN) {
                chunk[n] = (c + n < samples.length ? samples[c + n] : 0.0) * windowCache[n];
            }

            // compute positive spectrum with sampling correction and BP filter
            final freqs = FFT.rfft(chunk).map(z -> z.scale(1 / fftN).magnitude).mapi(melodicBandPass);

            // find spectral peaks and their instantaneous frequencies
            for (k => s in freqs)
            {
                final freq = indexToFreq(k);
                final power = s * s;
                if (FlxG.keys.justPressed.I)
                {
                    trace(k);
                    final time = c / fs;
                    haxe.Log.trace('${time};${freq};${power}', null);
                }
                if (freq < maxFreq) freqOutput[0].push(power);
            }

            c += hop;
        }

        if (FlxG.keys.justPressed.C) trace(freqOutput.length);

        return freqOutput;
    }

    public static function getCurAud(aud:Int16Array, index:Int):CurAudioInfo
    {
        var left = aud[index] / 32767;
        var right = aud[index + 2] / 32767;
        var balanced = (left + right) / 2;

        var funny:CurAudioInfo = {left: left, right: right, balanced: balanced};

        return funny;
    }

    public function checkAndSetBuffer()
    {
        if (snd != null && snd.playing)
        {
            if (!setBuffer)
            {
                // Math.pow3
                @:privateAccess
                var buf = snd._channel.__audioSource.buffer;

                // @:privateAccess
                audioData = cast buf.data; // jank and hacky lol! kinda busted on HTML5 also!!
                sampleRate = buf.sampleRate;

                //trace('got audio buffer shit');
                //trace(sampleRate);
                //trace(buf.bitsPerSample);

                setBuffer = true;
                numSamples = Std.int(audioData.length / 2);
            }
        }
    }

    public function destroy():Void {
        snd = null;
        audioData = null;
        chunk = null;
        windowCache = null;
        freqOutput = null;
    }
}

typedef CurAudioInfo =
{
    var left:Float;
    var right:Float;
    var balanced:Float;
}