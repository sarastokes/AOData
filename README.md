# ao-data-tools

Framework for organizing and analyzing imaging experiments. Designed with adaptive optics experiments in mind but applies well to other imaging datasets. Draws on ideas from other open source data frameworks, especially [NeurodataWithoutBorders](https://github.com/NeurodataWithoutBorders) and [Symphony](https://github.com/Symphony-DAS/symphony-matlab). 

### Organization 

For storing data and metadata associated with an experiment:

- **Experiment**
  - Source
    - Source (nestable) 
  - System
    - Channel
      - Device
  - Calibration
  - Region
  - Epoch
    - Registration
    - Response
      - Timing
    - Stimulus
   - Analysis

Although there are multiple approaches for converting an experiment into a `Experiment` object, the `Creator` class has access to all the building functions within `Experiment` and can provide a standardized way of building customized `Experiment` objects.

For creating stimulus protocols, there is also the `Protocol` class. The advantage of using this class is standardizing stimulus creation. The `Stimulus` class stores the `Protocol` name and parameters, making it possible to recreate the `Protocol` object later on and regenerate the exact stimulus used.

### Examples
Each class is generic and meant to be subclassed and tailored to specific imaging experiments. Examples can be found in the `\packages` folder.

### Dependencies
- MATLAB (developed in 2022a, compatible with 2021a and 2021b)
- The core classes do not require additional toolboxes. Some of the examples in `\packages` require the following additional MATLAB toolboxes: Signal Processing, Image Processing and Symbolic Math.

### Included 3rd party toolboxes:
(Currently, these may only be necessary for packages)
- [JSONLab 2.0](https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files?s_tid=ta_fx_results)
- [ReadImageJROI](https://github.com/DylanMuir/ReadImageJROI)
- Other misc 3rd party functions are found in `\lib`

### Optional toolboxes:
The examples in packages also rely on several toolboxes which are not included. Where necessary, each is mentioned in the class/function documentation.
- [Psychtoolbox](https://github.com/Psychtoolbox-3/Psychtoolbox-3)
- [Silent Substitution Toolbox](https://github.com/spitschan/SilentSubstitutionToolbox)
- [Stage-VSS](https://github.com/Stage-VSS/stage)