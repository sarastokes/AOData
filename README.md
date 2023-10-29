# AOData

AOData is a object-oriented framework for organizing and mapping experimental data, metadata and code into a standardized and searchable format. AOData is designed to facilitate data sharing, collaboration and reproducibility for adaptive optics (AO) imaging of the eye but may apply well to other experiments as well.

AOData's development was guided by the [FAIR Data Sharing Principles](https://www.nature.com/articles/sdata201618) that emphasize findability, accessibility, interoperability and reusability.

### Goals
AOData was designed around the following goals:
- Labs already have well-defined systems for organizing the data and metadata collected during an experiment. To minimize the cost of adoption and ensure backwards compatibility, a new framework must integrate with, rather than replace, these existing lab standards for data storage. Where a new framework would add value is:
  - Collecting all the information related to an experiment into a single file that is both human and machine-readable.
  - Accommodating the full lifetime of an experiment, from calibrations to analyses for publication.
  - Tracking of the custom code used for designing, processing and interpreting experiments.
- Provide a baseline level of standardization while remaining as modular, flexible and unrestrictive as possible. This standardization establishes the predictable organization necessary for querying diverse experiments and facilitates collaboration by establishing a "shared language" between users.
- Output files must be suitable for long-term archival and collaboration
  - File format at must be platform/language independent and widely-supported.
  - Interaction with the contents of the file must be independent of the custom code used to generate the file.

### Object Model
All AO experiments share a common general structure, which can be broken down into a set of elementary components. AOData's object model defines a generic set of components making up an AO imaging experiment and their relationships. Conceptually, there are two key levels of organization: **Experiment** and **Epoch**. Each Experiment represents one imaging session and each Epoch represents a period of continuous data acquisition within the Experiment.

- **Experiment**
  - Source
    - Source (nestable)
  - System
    - Channel
      - Device
  - Calibration
  - ExperimentDataset
  - **Epoch**
    - EpochDataset
    - Registration
    - Response
    - Stimulus
  - Annotation
  - Analysis

The object model is designed to establish a baseline level of standardization, while remaining as flexible, extensible and unrestrictive as possible.

### Implementation
The AOData object model is implemented in MATLAB, the dominant programming language among the AO community. The resulting HDF5 files are platform-independent and can be used in virtually all major programming languages.

<img src="https://github.com/sarastokes/AOData/blob/main/docs/aodata_code.PNG?raw=true" width="400">

AOData consists of two components: the core interface and the persistent interface.

- The core interface is used to define the mapping of information related to an experiment to the AOData object model, prior to writing to an HDF5 file. Users subclass the core classes reflecting the different components of the object model, customizing them to represent the specifics of their experiment. AOData handles the details of writing the data/metadata from MATLAB to HDF5 files behind the scenes.
- The persistent interface provides an API for reading, modifying and extending an existing AOData HDF5 file and is completely independent of the core interface classes used to create the file.

In other words, the user-defined subclasses in the core interface are used to specify the contents of the HDF5 file, while the persistent interface simply reflects the contents of the HDF5 file. While the inner workings of the two interfaces differ, they provide the same user-facing functions and are largely interchangeable. AOData HDF5 files are intended to be living documents and users can continue to add new components from the core interface, such as analyses, as their research progresses.

The persistent interface offers extended capabilities for viewing the contents of HDF5 files with a customized HDF5 viewer (**AODataViewer**) and an API for querying the contents of one or more AOData HDF5 files (**AOQuery**).

In addition to managing metadata, AOData provides a standardized framework for the code used to  design, represent and analyze experiments. Support for tracking git repositories is included with AOData and information about the underlying git repositories is written to each file. For users new to AOData or object oriented programming, **AOSubclassCreator** provides a user interface for creating template subclasses, so that users can paste in their existing workflows with minimal disruption.

### Timeline
AOData is largely stable and well-documented within the code. Current development is focused on improving AOQuery, creating useful tutorials and expanding the test suite. As of April, code coverage is >80%. Over the next few months, AOData will be tested within the Williams lab, then formally released. In the meantime, reach out if your group is interested in learning more about AOData.

The hope is that AOData will become useful to all adaptive optics imaging labs and continue to develop to meet the community's needs.

### Dependencies
AOData is currently developed in MATLAB 2023a, but should work fine with MATLAB 2022a or higher. Earlier versions may work but have not been tested. Additional MATLAB toolboxes are not required, although some of the example classes in "aod.builtin.registrations" package rely on the Image Processing Toolbox. AODataViewer and AOQueryApp are both available as a standalone application that does not require a MATLAB license by request.

AOData ships with [h5tools-matlab](https://github.com/sarastokes/h5tools-matlab), a toolbox of high-level functions extending MATLAB's HDF5 support, which was originally written to support AOData. In addition, several third-party open source programs are included: [appbox](https://github.com/cafarm/appbox), [doxymatlab](https://github.com/simgunz/doxymatlab), [getGitInfo](https://www.mathworks.com/matlabcentral/fileexchange/32864-get-git-info), [JSONLab 2.0](https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files?s_tid=ta_fx_results), [ReadImageJROI](https://github.com/DylanMuir/ReadImageJROI), [superbar](https://github.com/scottclowe/superbar), [weblab](https://github.com/lordtumnus/weblab). Author credit for the free icons used in the apps is detailed [here](app/icons/Resources.md).

### More information
- AOData's [documentation](docs/ao-data-tools-documentation.pdf) and [testing](test/README.md)
- HDF5 files: [The HDF Group](https://www.hdfgroup.org/) and [What is HDF5?](https://www.neonscience.org/resources/learning-hub/tutorials/about-hdf5)
- Git: [official website](https://git-scm.com/), article about use in scientific research from [Blischak et al (2016) *PLoS Comp Biol*](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1004668)
- Object oriented programming in MATLAB: [documentation](https://www.mathworks.com/products/matlab/object-oriented-programming.html)
- Existing data management systems that were useful in AOData's development: [Symphony-DAS](https://symphony-das.github.io), [ooML](http://g-node.github.io/python-odml/), [BIDS](https://bids.neuroimaging.io/), [NWB](https://www.nwb.org/) and [Neo](https://neuralensemble.org/neo/).
- [ARIA](https://aria.cvs.rochester.edu/): the Advanced Retinal Imaging Alliance at the University of Rochester
- Feel free to reach out with any questions or comments: spatte16@ur.rochester.edu.