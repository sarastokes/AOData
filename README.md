# ao-data-tools

Framework for organizing and analyzing imaging experiments. Designed for adaptive optics but likely applies well to other imaging datasets.

### Organization 

For storing data and metadata associated with an experiment.

- **Dataset**
  - Subject
    - Eye 
  - System
    - Calibration
  - Regions
  - Epoch
    - Registration
    - **Response**
    - Stimulus
   - Analysis

Although there are multiple approaches for converting an experiment into a `Dataset` object, 

For creating stimulus protocols, there is also the `Protocol` class. The advantage of using this class is standardizing stimulus creation. The `Stimulus` class stores the `Protocol` name and parameters, making it possible to recreate the exact stimulus used.


### Examples
Each class is generic and meant to be subclassed and tailored to specific imaging experiments. Examples can be found in the `\packages` folder.


### Dependencies
- MATLAB (developed in 2022a, compatible with 2021a and 2021b)
- The core classes do not require additional toolboxes. Some of the examples in `\packages` require the Signal Processing Toolbox and Image Processing Toolbox.

### Included dependencies:
- [JSONLab 2.0](https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files?s_tid=ta_fx_results)
- [ReadImageJROI](https://github.com/DylanMuir/ReadImageJROI)
- Other misc 3rd party functions are found in `\lib`