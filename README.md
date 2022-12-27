# AOData

AOData is a object-oriented framework for organizing the data, metadata and code related to an experiment in a single standardized and searchable format (an HDF5 file). AOData is designed for adaptive optics imaging of the eye but may apply well to other experiments as well. See the [documentation](docs/ao-data-tools-documentation.pdf) for more details, but be aware that AOData is under active development and is not yet complete. 

### Object Model 
All AO experiments share a common general structure, which can be broken down into a set of elementary components. AOData's object model defines these components and their hierarchy. There are two levels: **Experiment** and **Epoch**. Each Experiment represents one imaging session and each Epoch represents a period of continuous data acquisition within the Experiment. 

- **Experiment**
  - Source
    - Source (nestable) 
  - System
    - Channel
      - Device
  - Calibration
  - ExperimentDataset
  - Epoch
    - EpochDataset
    - Registration
    - Response
    - Stimulus
  - Annotation
  - Analysis
 
 The object model is designed to establish a baseline level of standardization, while remaining as flexible, extensible and unrestrictive as possible. 

### Implementation
The AOData object model is implemented in MATLAB with object oriented programming. AOData consists of two components: the core interface and the persistent interface. 

The core interface is used to define the mapping of information related to an experiment to the AOData object model, prior to writing to an HDF5 file. Users subclass the core classes reflecting the different components of the object model, customizing them to represent the specifics of their experiment. AOData handles the details of writing the data/metadata from MATLAB to HDF5 files behind the scenes, so that users only need to specify the data and metadata relevant to their experiment and how to import it into MATLAB.

The persistent interface provides an API for reading, modifying and extending an existing AOData HDF5 file and is completely independent of the core interface. In other words, the user-defined subclasses in the core interface are used to define the contents of the HDF5 file, while the persistent interface simply reflects the contents of the HDF5 file. While the inner workings of the two interfaces differ, the functions they provide the same user-facing functions and are largely interchangeable. However, the persistent interface offers extended capabilities for viewing the contents of HDF5 files with a customized HDF5 viewer (AODataViewer) and querying the contents of AOData HDF5 files. AOData includes an HDF5 file viewer tailored to AOData files (AODataViewer) along with an API for searching AOData files (AOQuery) and user interface (AOQueryBuilder).


<img src="https://github.com/sarastokes/AOData/blob/main/docs/aodata_code.PNG?raw=true" width="400">

### Examples
Each class is generic and meant to be subclassed and tailored to specific imaging experiments. Examples can be found in the "aod.builtin" package and detailed tutorials are being developed in the "tutorials" folder. A paper describing AOData is in preparation.

### Dependencies
MATLAB 2022b. Earlier versions may work but are not guarenteed. Additional toolboxes are not required, although some of the example classes in "aod.builtin.registrations" use the Image Processing Toolbox. AODataViewer and AOQueryBuilder available as a standalone application usable without a MATLAB license by request.

AOData ships with [h5tools-matlab](https://github.com/sarastokes/h5tools-matlab), a toolbox of high-level functions extending MATLAB's HDF5 support, which was originally written to support AOData. In addition, several third-party open source programs are included in "/lib": [appbox](https://github.com/cafarm/appbox), [getGitInfo](https://www.mathworks.com/matlabcentral/fileexchange/32864-get-git-info), [JSONLab 2.0](https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files?s_tid=ta_fx_results),  [ReadImageJROI](https://github.com/DylanMuir/ReadImageJROI) and [doxymatlab](https://github.com/simgunz/doxymatlab). Author credit for the free icons used in the apps is detailed [here](app/icons/Resources.md).

### More information
- AOData's [documentation](docs/ao-data-tools-documentation.pdf)
- HDF5 files: [The HDF Group](https://www.hdfgroup.org/) and [What is HDF5?](https://www.neonscience.org/resources/learning-hub/tutorials/about-hdf5) 
- Object oriented programming in MATLAB: [documentation](https://www.mathworks.com/products/matlab/object-oriented-programming.html)
- Existing data management systems inspiring AOData: [Symphony-DAS](https://symphony-das.github.io) and [NeurodataWithoutBorders](https://www.nwb.org/)
- [ARIA](https://aria.cvs.rochester.edu/): the Advanced Retinal Imaging Alliance at the University of Rochester
- Feel free to reach out with any questions or comments: spatte16@ur.rochester.edu.