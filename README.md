# ao-data-tools

Framework for organizing and analyzing imaging experiments. Designed for adaptive optics but likely applies well to other imaging datasets.


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

Each class is generic and meant to be subclassed and tailored to specific imaging experiments. Examples can be found in the `\packages` folder.

##### Included dependencies:
- [JSONLab 2.0](https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files?s_tid=ta_fx_results)
- [ReadImageJROI](https://github.com/DylanMuir/ReadImageJROI)
- Other misc 3rd party functions are found in `\lib`