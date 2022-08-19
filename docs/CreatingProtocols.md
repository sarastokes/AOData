
##### Creating a new protocol
Subclass `aod.core.Protocol` or one of the subclasses (e.g. `aod.core.StimulusProtocol`)  if those are applicable.

Each `Protocol` subclass must define two properties: `sampleRate`, the rate data is sampled in Hz, and `stimRate`, the rate stimuli are presented in Hz. 

The stimulus is created and written with the following methods:
1. **calculateTotalTime**: determine how the total stimulus time is calculated
2. **generate**: calculates normalized stimulus values (between 0 and 1)
3. **mapToStimulator**: Apply any alterations necessary to convert the output of `generate` into whatever your stimulator requires. For example, apply nonlinearities here or conversions to different data types
4. **writeStim**: Outputs the calculated stimulus to the filetype needed for imaging software

You can either provide the filename to `writeStim` or define a method for determining a default filename by overwriting `getFileName`.

Below is a template for defining a new protocol:
```matlab
classdef MyProtocol < aod.core.Protocol

    % Define properties specific to this protocol
    properties
        myProp
    end 

    % Define the following two necessary properties
    properties (Access = protected)
        % Frequency that data is sampled (Hz)
        sampleRate = 25      
        % Frequency that stimuli are presented (Hz)
        stimRate = 500          
    end

    methods
        function obj = MyProtocol(varargin)
            obj = obj@aod.core.Protocol(varargin{:});

            % Parse properties specific to this protocol
            ip = inputParser();
            ip.KeepUnmatched = true;
            addParameter(ip, 'MyProp', 1, @isnumeric);
            parse(ip, varargin{:});

            obj.myProp = ip.Results.MyProp;
        end

        function stim = generate(obj)
            % Define how the stimulus is created
        end

        function stim = mapToStimulator(obj)
            % Define mapping to stimulator, if necessary
            stim = obj.generate();
        end

        function writeStim(obj, fName)
            % Define how the stimulus is written to a file
            if nargin < 2
                fName = obj.getFileName();
            end
            stim = obj.mapToStimulator();
        end
    end
end
```

For example, here's a protocol called `Steps` for the LEDs on the 1P primate system. Data is sampled at 25 Hz (`sampleRate`) and the update rate for the LEDs is 500 Hz (`stimRate`). 
This protocol begins at a baseline value (`baseIntensity`) for a set amount of time (`preTime`), increases (`contrast`) for a set amount of time (`stimTime`), then returns to the baseline value (`baseIntensity`) for a set amount of time (`tailTime`), This creates an achromatic step in contrast

```
  preTime       stimTime         tailTime
            _________________
            |               |
            |               |
____________|               |_______________ baseIntensity
```

In addition, the protocol requires the maximum power for each of the 3 LEDs (`ledMaxPowers`) and there is no default value available for this, so it's a direct input to the protocol instead of being passed to `inputParser` (see [inputParser's documentation](https://www.mathworks.com/help/matlab/ref/inputparser.html?searchHighlight=inputParser&s_tid=srchtitle_inputParser_1) for more information). 

The calculation for the contrast step is found in `generate()`. For LED stimuli, the normalized values must be scaled by each LED's max power (`ledMaxPowers`), so that occurs in the `mapToStimulator()` function. Finally, to write a stimulus file for the imaging software, the values for each LED are written to a text file using an external function `writeLEDStimulusFile`.

```matlab
classdef Step < aod.core.Protocol

    % Protocol-specific, all public access properties are saved
    properties
        ledMaxPowers        % Max powers for each LED, [R G B]
        preTime             % time before step is presented (sec)
        stimTime            % time step is presented (sec)
        tailTime            % time after step is presented (sec)
        contrast            % change in value during step (-1 to 1)
        baseIntensity       % baseline value for the LEDs (0 to 1)
    end

    % These properties must be set by subclasses
    properties (SetAccess = protected)
        sampleRate = NaN
        stimRate = NaN
    end

    % These properties are derived and don't need to be saved
    properties (Access = private)
        amplitude
    end

    methods
        function obj = ContrastStep(ledMaxPowers, varargin)
            obj = obj@aod.core.Protocol(varargin{:});

            obj.ledMaxValues = ledMaxValues;

            % Parse optional key/value inputs
            ip = inputParser();
            addParameter(ip, 'PreTime', 1, @isnumeric);
            addParameter(ip, 'StimTime', 5, @isnumeric);
            addParameter(ip, 'TailTime', 1, @isnumeric);
            addParameter(ip, 'BaseIntensity', 0.5, @isnumeric);
            addParameter(ip, 'Contrast', 1, @isnumeric);
            parse(ip, varargin{:});

            obj.preTime = ip.Results.PreTime;
            obj.stimTime = ip.Results.StimTime;
            obj.tailTime = ip.Results.TailTime;
            obj.baseIntensity = ip.Results.BaseIntensity;
            obj.contrast = ip.Results.Contrast;

            % Derived properties
            if obj.baseIntensity == 0
                obj.amplitude = obj.contrast;
            else 
                obj.amplitude = (obj.baseIntensity*obj.contrast) + obj.baseIntensity;
            end
        end

        function stim = generate(obj)
            % Define how the stimulus is created
            totalPts = obj.sec2pts(obj.totalTime);
            stim = obj.baseIntensity + zeros(1, totalPts);

            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimPts);

            stim(prePts+1:prePts+stimPts) = obj.amplitude;
        end

        function stim = mapToStimulator(obj)
            % Define mapping to stimulator, if necessary
            stim = obj.generate();
            ledValues = data .* obj.ledMaxPowers';
        end

        function fName = getFileName(obj)
            if obj.baseIntensity == 0
                fName = 'intensity_increment_';
            elseif obj.contrast > 0
                fName = 'contrast_decrement_';
            elseif obj.contrast < 0
                fName = 'contrast_increment';
            end
            fName = [fName, sprintf('_%up_%uc_%us_%ut',...
                100*obj.baseIntensity, 100*obj.contrast,... 
                obj.stimTime, obj.totalTime)];
        end

        function writeStim(obj, fName)
            % Define how the stimulus is written to a file
            if nargin < 2
                fName = obj.getFileName();
            end
            ledValues = obj.mapToStimulator();
            makeLEDStimulusFile(fName, ledValues);
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            % Define how the total stimulus time is calculated
            value = obj.preTime + obj.stimTime + obj.tailTime;
        end
    end
end
```

You might notice a this protocol used few functions and properties that weren't defined. These are inherited from `aod.core.Protocol`. For example, several methods are defined for converting between seconds and samples (`obj.sec2samples(sec)`, `obj.samples2sec(samples)`) which use the value you set for `sampleRate`. To convert between seconds and the stimulator's timing, there's `obj.sec2pts(sec)` and `obj.pts2sec(pts)` which use your value for `stimRate`. There's also a property `totalTime` which calls the function `obj.calculateTotalTime()`. See the `aod.core.Protocol` code for more.


To create a `Steps` protocol, provide the `ledMaxPowers` and any of the optional arguments if you want to use something other than their default value (defined in the `inputParser` block)...
```matlab
obj = Steps([1 1 1], 'PreTime', 10, 'StimTime', 20, 'TailTime', 10);

% Check the stimulus
figure(); plot(obj.generate());

% Make a contrast decrement
obj = Steps([1 1 1], 'BaseIntensity', 0.5, 'Contrast', -1);
% Make a 50% contrast increment
obj = Steps([1 1 1], 'BaseIntensity', 0.5, 'Contrast', 0.5);

```

The utility of creating stimuli in this way is one class can create a range of stimuli (contrast increments, contrast decrements, intensity increments) in a standardized way. If you provide the same inputs later on, you get the same stimulus so there's no ambiguity on what you displayed during an experiment.

The other advantage is the integration with `aod.core.Stimulus`. 