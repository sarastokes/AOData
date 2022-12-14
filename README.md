# ao-data-tools

Object-oriented framework for organizing the data, metadata and code related to an experiment. Designed with adaptive optics experiments in mind but applies well to other imaging datasets. 

### Organization 
For storing data and metadata associated with an experiment:

- **Experiment**
  - Source
    - Source (nestable) 
  - System
    - Channel
      - Device
  - Calibration
  - Annotation
  - Epoch
    - Dataset
    - Registration
    - Response
    - Stimulus
  - Analysis

After creating the experiment hierarchy, the experiment is written to an HDF5 file and can be read back into MATLAB or taken to other programming languages.

For creating stimulus protocols, there is also the `Protocol` class. The advantage of using this class is standardizing stimulus creation. The `Stimulus` class stores the `Protocol` name and parameters, making it possible to recreate the `Protocol` object later on and regenerate the exact stimulus used.

### Examples
Each class is generic and meant to be subclassed and tailored to specific imaging experiments. Examples can be found in the `\packages` folder.

### Dependencies
- MATLAB 2022b (earlier versions may work but are not guarenteed). AODataViewer is available as a standalone application usable without a MATLAB license by request.
- The core classes do not require additional toolboxes. Some of the examples in `\packages` require the following additional MATLAB toolboxes: Signal Processing, Image Processing and Symbolic Math.

### Included 3rd party toolboxes:
(Currently, these may only be necessary for packages)
- [JSONLab 2.0](https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files?s_tid=ta_fx_results)
- [ReadImageJROI](https://github.com/DylanMuir/ReadImageJROI)
- [appbox](https://github.com/cafarm/appbox)
- Other misc 3rd party functions are found in `\lib`

### Optional toolboxes:
The examples in packages also rely on several toolboxes which are not included. Where necessary, each is mentioned in the class/function documentation.
- [Psychtoolbox](https://github.com/Psychtoolbox-3/Psychtoolbox-3)
- [Silent Substitution Toolbox](https://github.com/spitschan/SilentSubstitutionToolbox)
- [Stage-VSS](https://github.com/Stage-VSS/stage)