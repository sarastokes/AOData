# CHANGELOG

Documentation of changes prior to alpha release, beginning 30Apr2023

#### 18-Jun-2023
- Fell off logging changes... 
- Adding events to specification framework to support future full file validation and specification comparison

#### 3-May-2023
- Restructured persistent interface to support HDF5 path changes that occur when changing a group's name

#### 2-May-2023
- Added in `expectedDatasets` parameter but have not implemented checking yet
- Laying the groundwork for major HDF5 edits from persistent interface (e.g., changing group name, replace/remove groups)

#### 30-Apr-2023
- Deprecated `aod.builtin.stimuli.VisualStimulus`
- Implemented expected parameter checking in `aod.core.Entity` parameter methods  