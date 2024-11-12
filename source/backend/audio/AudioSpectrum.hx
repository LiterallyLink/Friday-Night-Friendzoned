package backend.audio;
 
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import backend.audio.AudioVisualizer;
import backend.audio.AudioSpectrumTypes.AmplitudeData;
import backend.audio.AudioSpectrumTypes.FrequencyBinRange;
import backend.audio.AudioSpectrumDebug;
 
class AudioSpectrum extends FlxGroup
{
    // Constants
    private static inline var NUM_BARS:Int = 100;
    private static inline var MAX_BAR_HEIGHT:Float = 300;
    private static inline var SMOOTHING_FACTOR:Float = 0.20;
    private static inline var AMPLITUDE_MULTIPLIER:Float = 8000;
 
    // Frequency band constants
    private static inline var SUB_BASS_FREQ:Float = 20;
    private static inline var BASS_FREQ:Float = 150;
    private static inline var LOW_MID_FREQ:Float = 300;
    private static inline var MID_FREQ:Float = 400;
    private static inline var HIGH_MID_FREQ:Float = 500;
    private static inline var PRESENCE_FREQ:Float = 550;
    private static inline var BRILLIANCE_FREQ:Float = 600;

    // Frequency category amplitude constants
    private static var SUB_BASS_AMPLITUDE:Float = 1.0;
    private static var BASS_AMPLITUDE:Float = 1.0;
    private static var MID_AMPLITUDE:Float = 1.0;
    private static var HIGH_MID_AMPLITUDE:Float = 1.0;
    private static var PRESENCE_AMPLITUDE:Float = 1.0;
    private static var BRILLIANCE_AMPLITUDE:Float = 1.0;
 
    // Instance properties
    private var barWidth:Float;
    private var barSpacing:Float;
    private var isVertical:Bool = false;
    private var facingLeft:Bool = false;
 
    // Visualization data
    private var bars:Array<FlxSprite>;
    private var spectrum:Array<Float>;
    private var lastSpectrum:Array<Float>;
    private var peakLevels:Array<Float>;
    private var vis:AudioVisualizer;
    private var samples:Array<Float>;
    private var frequencyData:Array<Array<Float>>;

    public var debug:AudioSpectrumDebug;
 
    // Constructor
    public function new(sound:FlxSound, X:Float = 0, Y:Float = 0, vertical:Bool = false, faceLeft:Bool = false,
		subBassAmplitude:Float = 1.0, bassAmplitude:Float = 1.0, midAmplitude:Float = 1.0,
		highMidAmplitude:Float = 1.0, presenceAmplitude:Float = 1.0, brillianceAmplitude:Float = 1.0)
	{
		super();
		
		isVertical = vertical;
		facingLeft = faceLeft;
		
		SUB_BASS_AMPLITUDE = subBassAmplitude;
		BASS_AMPLITUDE = bassAmplitude;
		MID_AMPLITUDE = midAmplitude;
		HIGH_MID_AMPLITUDE = highMidAmplitude;
		PRESENCE_AMPLITUDE = presenceAmplitude;
		BRILLIANCE_AMPLITUDE = brillianceAmplitude;
 
        // Calculate dimensions based on orientation
        if (isVertical)
        {
            var totalHeight = FlxG.height - Y * 2;
            barSpacing = totalHeight * 0.005;
            barWidth = (totalHeight - (barSpacing * (NUM_BARS - 1))) / NUM_BARS;
        }
        else
        {
            var totalWidth = FlxG.width - X * 2;
            barSpacing = totalWidth * 0.005;
            barWidth = (totalWidth - (barSpacing * (NUM_BARS - 1))) / NUM_BARS;
        }
 
        // Initialize arrays
        bars = [];
        spectrum = [for (i in 0...NUM_BARS) 0.0];
        lastSpectrum = [for (i in 0...NUM_BARS) 0.0];
        peakLevels = [for (i in 0...NUM_BARS) 0.0];
        samples = [];
        frequencyData = [];
 
        vis = new AudioVisualizer(sound);
        debug = new AudioSpectrumDebug(vis);
        debug.setSpectrum(this);

        createBars(X, Y);
    }

	private function createBars(X:Float, Y:Float):Void
	{
		for (i in 0...NUM_BARS)
		{
			var bar:FlxSprite;
			if (isVertical)
			{
				bar = new FlxSprite(X, Y + i * (barWidth + barSpacing));
				var color:FlxColor = getBarColor(i);
				bar.makeGraphic(1, Std.int(barWidth), color);
				bar.origin.x = 0; // Keep origin at left side for both directions
				bar.origin.y = 0;
			}
			else
			{
				bar = new FlxSprite(X + i * (barWidth + barSpacing), Y);
				var color:FlxColor = getBarColor(i);
				bar.makeGraphic(Std.int(barWidth), 1, color);
				bar.origin.y = 0;
			}
	
			bar.scale.x = 1;
			bar.scale.y = 1;
			bars.push(bar);
			add(bar);
		}
	}
 
	// Public methods
    override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	
		vis.checkAndSetBuffer();
	
		if (vis.setBuffer && vis.snd.playing)
		{
			var pos = Std.int(vis.snd.time * vis.sampleRate / 1000);
	
			samples = [];
			for (i in 0...2048)
			{
				var samplePos = pos + i;
				if (samplePos < vis.numSamples)
				{
					var info = AudioVisualizer.getCurAud(vis.audioData, samplePos * 2);
					samples.push(info.balanced);
				}
			}
	
			if (samples.length > 0)
			{
				frequencyData = vis.funnyFFT(samples, 1);
	
				if (frequencyData.length > 0)
				{
					var freqs = frequencyData[frequencyData.length - 1];
					var fftSize = samples.length;
	
					var maxAmplitude = 0.0;
					for (freq in freqs)
					{
						maxAmplitude = Math.max(maxAmplitude, freq);
					}

					if (maxAmplitude == 0) {
						maxAmplitude = 1.0;
					}
	
					for (i in 0...NUM_BARS)
					{
						var binRange = calculateFrequencyBinRange(i, fftSize, freqs.length);
						var amplitudeData = calculateBandAmplitude(binRange.start, binRange.end, freqs, maxAmplitude, fftSize);
	
						var smoothedSpectrum = applyDecayAndSmoothing(i, amplitudeData.amplitude);
	
						var freqMultiplier = 1.0 + Math.pow(Math.abs(0.5 - (i / NUM_BARS)), 1.2) * 1.8;
						var freqBoost:Float = calculateFrequencyBoost(i);
	
						var freqAmplitude = getFrequencyAmplitude(i);
						var scaledHeight = Math.pow(smoothedSpectrum, 0.72) * AMPLITUDE_MULTIPLIER * freqMultiplier * freqBoost * freqAmplitude;
	
						var randomRange = 0.07 + (i / NUM_BARS) * 0.09;
						scaledHeight *= (0.96 + randomRange * Math.random());
	
						var height = Math.min(MAX_BAR_HEIGHT, scaledHeight);
	
						if (isVertical)
						{
							if (facingLeft)
							{
								height *= -1;
							}
							bars[i].scale.x = height;
						}
						else
						{
							bars[i].scale.y = Math.max(1, height);
						}
					}
	
					normalizeBarMinimums();
				}
			}
		}
	}
 
    /**
     * Updates the position of all visualization bars in the spectrum.
     * For vertical spectrums, maintains a single X position and spaces bars vertically.
     * For horizontal spectrums, spaces bars horizontally from the given X position.
     * 
     * @param X The X coordinate to position the spectrum at
     * @param Y The Y coordinate to position the spectrum at
     */
     public function setPosition(X:Float, Y:Float):Void
    {
        if (isVertical)
        {
            for (i in 0...bars.length)
            {
                bars[i].x = X;
                bars[i].y = Y + i * (barWidth + barSpacing);
            }
        }
        else
        {
            for (i in 0...bars.length)
            {
                bars[i].x = X + i * (barWidth + barSpacing);
                bars[i].y = Y;
            }
        }
    }
 
    /**
    * Converts a bar's index into its corresponding color using HSB color space.
    * The hue is determined by the frequency range the bar represents,
    * with full saturation and brightness for vibrant visualization.
    * 
    * @param index The index of the bar (0 to NUM_BARS-1)
    * @return FlxColor The color for the given bar, ranging from purple (sub-bass) to red (brilliance)
    */
    private function getBarColor(index:Int):FlxColor
    {
       var hue = getHueForBar(index);
       return FlxColor.fromHSB(hue, 1, 1, 1);
    }
 
    /**
    * Maps a bar's normalized index to its corresponding hue value in the HSB color space.
    * Colors are assigned based on frequency ranges, following common audio visualization conventions:
    * - 0-10%:  Purple  (280°) for sub-bass frequencies
    * - 10-20%: Blue    (240°) for bass frequencies
    * - 20-40%: Cyan    (180°) for mid frequencies
    * - 40-60%: Green   (120°) for high-mid frequencies
    * - 60-80%: Yellow  (60°)  for presence frequencies
    * - 80-100%: Red    (0°)   for brilliance frequencies
    * 
    * @param index The index of the bar (0 to NUM_BARS-1)
    * @return Float The hue value (0-360 degrees) for the given bar index
    */
    private function getHueForBar(index:Int):Float
    {
       var normalizedIndex = index / NUM_BARS;
       if (normalizedIndex < 0.1)
           return 280; // Sub-bass (purple)
       if (normalizedIndex < 0.2)
           return 240; // Bass (blue)
       if (normalizedIndex < 0.4)
           return 180; // Mids (cyan/green)
       if (normalizedIndex < 0.6)
           return 120; // High-mids (green/yellow)
       if (normalizedIndex < 0.8)
           return 60; // Presence (yellow/orange)
       return 0; // Brilliance (red)
    }
 
    /**
    * Determines the weight/multiplier for a given frequency in the audio spectrum.
    * Each frequency range is carefully weighted to compensate for human hearing perception 
    * and to create a more visually balanced spectrum display.
    * 
    * Weight Values:
    * - Sub-bass (<20Hz):    3.5x - Lower weight to prevent overwhelming bass frequencies
    *                              while still maintaining presence in the visualization
    * 
    * - Bass (<150Hz):       3.5x - Matched with sub-bass to create smooth transition
    *                              through the low frequency range
    * 
    * - Low-mids (<300Hz):   5.0x - Higher boost to bring out instruments like guitars, 
    *                              piano lower registers, and vocal fundamentals
    * 
    * - Mids (<400Hz):       4.5x - Slightly reduced from low-mids to prevent muddiness
    *                              while keeping vocal presence strong
    * 
    * - High-mids (<500Hz):  4.0x - Further reduced to balance against boosted presence
    *                              range, primarily affecting upper harmonics
    * 
    * - Presence (<550Hz):   4.5x - Boosted to emphasize vocal clarity and instrument 
    *                              attack characteristics
    * 
    * - Brilliance (>550Hz): 5.0x - Strong boost to ensure high frequency content 
    *                              remains visible despite naturally lower amplitude
    * 
    * @param freq The frequency in Hz to get the weight for
    * @return Float The weight multiplier for the given frequency range
    */
    private function getFrequencyWeight(freq:Float):Float
    {
       if (freq < SUB_BASS_FREQ)
           return 3.5; // Sub-bass unchanged
       if (freq < BASS_FREQ)
           return 3.5; // Bass unchanged
       if (freq < LOW_MID_FREQ)
           return 5.0; // Low-mids unchanged
       if (freq < MID_FREQ)
           return 4.5; // Mids unchanged
       if (freq < HIGH_MID_FREQ)
           return 4.0; // Increased from 4.5 to 7.0
       if (freq < PRESENCE_FREQ)
           return 4.5; // Increased from 4.0 to 6.5
       return 5; // Increased from 3.5 to 6.0
    }

    private function getFrequencyAmplitude(barIndex:Int):Float
	{
		if (barIndex < NUM_BARS * 0.1)
			return SUB_BASS_AMPLITUDE;
		if (barIndex < NUM_BARS * 0.2)
			return BASS_AMPLITUDE;
		if (barIndex < NUM_BARS * 0.4)
			return MID_AMPLITUDE;
		if (barIndex < NUM_BARS * 0.6)
			return HIGH_MID_AMPLITUDE;
		if (barIndex < NUM_BARS * 0.8)
			return PRESENCE_AMPLITUDE;
		return BRILLIANCE_AMPLITUDE;
	}
 
	private function getFrequencyForBin(binIndex:Int, sampleRate:Float, fftSize:Int):Float
	{
		return (binIndex * sampleRate) / (fftSize * 2);
	}
 
	private function getBinForFrequency(freq:Float, sampleRate:Float, fftSize:Int):Int
	{
		return Std.int((freq * fftSize * 2) / sampleRate);
	}
 
	private function calculateFrequencyBinRange(barIndex:Int, fftSize:Int, freqsLength:Int):FrequencyBinRange
	{
		var freqStart = SUB_BASS_FREQ * Math.pow(BRILLIANCE_FREQ / SUB_BASS_FREQ, Math.pow(barIndex / NUM_BARS, 1.15));
		var freqEnd = SUB_BASS_FREQ * Math.pow(BRILLIANCE_FREQ / SUB_BASS_FREQ, Math.pow((barIndex + 1) / NUM_BARS, 1.15));
 
		var startBin = getBinForFrequency(freqStart, vis.sampleRate, fftSize);
		var endBin = getBinForFrequency(freqEnd, vis.sampleRate, fftSize);
 
		startBin = Std.int(Math.max(0, Math.min(freqsLength - 1, startBin)));
		endBin = Std.int(Math.max(0, Math.min(freqsLength - 1, endBin)));
		if (endBin <= startBin)
			endBin = startBin + 1;
 
		return {start: startBin, end: endBin};
	}
 
	private function calculateFrequencyBoost(barIndex:Int):Float
	{
		if (barIndex < NUM_BARS / 4)
			return 0.9; // Bass frequencies
		if (barIndex < NUM_BARS / 2)
			return 1.4; // Mid frequencies
		if (barIndex < NUM_BARS * 0.75)
			return 1.3; // High-mid frequencies
		return 2.2; // High frequencies
	}
 
	// Private methods - Amplitude and visualization processing
	private function calculateBandAmplitude(startBin:Int, endBin:Int, freqs:Array<Float>, maxAmplitude:Float, fftSize:Int):AmplitudeData{
		var amplitude = 0.0;
		var peakAmplitude = 0.0;
		var binCount = 0;
 
		for (j in startBin...endBin)
		{
			var freq = getFrequencyForBin(j, vis.sampleRate, fftSize);
			var weight = getFrequencyWeight(freq);
 
			var compressedAmp = Math.pow(freqs[j] / maxAmplitude, 0.8) * freqs[j];
			amplitude += compressedAmp * weight;
			peakAmplitude = Math.max(peakAmplitude, compressedAmp * weight);
			binCount++;
		}
 
		return {
			amplitude: (binCount > 0) ? amplitude / binCount : 0,
			peakAmplitude: peakAmplitude,
			binCount: binCount
		};
	}
 
	private function applyDecayAndSmoothing(index:Int, amplitude:Float):Float
	{
		var decayRate = 0.95;
		if (index < NUM_BARS / 4)
			decayRate = 0.88; // Faster decay for bass
		else if (index < NUM_BARS / 2)
			decayRate = 0.92; // Slightly slower for mids
 
		peakLevels[index] = Math.max(amplitude, peakLevels[index] * decayRate);
 
		var targetHeight = amplitude * 0.8 + peakLevels[index] * 0.2;
		spectrum[index] = (targetHeight * SMOOTHING_FACTOR) + (lastSpectrum[index] * (1 - SMOOTHING_FACTOR));
		lastSpectrum[index] = spectrum[index];
 
		return spectrum[index];
	}
 
 
	private function normalizeBarMinimums():Void
	{
		var maxHeight = 0.0;
		for (i in 0...NUM_BARS)
		{
			maxHeight = Math.max(maxHeight, isVertical ? Math.abs(bars[i].scale.x) : bars[i].scale.y);
		}
 
		if (maxHeight > 1)
		{
			for (i in 0...NUM_BARS)
			{
				var minHeight = maxHeight * 0.08 * (1 + 0.5 * Math.random());
				if (isVertical)
				{
					var sign = facingLeft ? -1 : 1;
					bars[i].scale.x = sign * Math.max(minHeight, Math.abs(bars[i].scale.x));
				}
				else
				{
					bars[i].scale.y = Math.max(minHeight, bars[i].scale.y);
				}
			}
		}
	}
}