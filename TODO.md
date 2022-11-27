## TODO

##### Major
- [x] Add UIDs to all Entitys
- [x] Implement search by UID
- [x] Replace duplicated epoch from Creator
- [x] Decide where allowableParentTypes go
- [ ] Units to dataset metadata?
- [x] Mapping Calibration property of Protocol (can't easily go in parameters)
- [x] Where should converting files to relative be done?
- [x] Dependent but not hidden properties should be written (e.g. epochIDs)
- [x] Abandon Timing core class
- [x] Remove entity-specific add methods
- [ ] Remove() method
- [ ] Fillmissing error type
- [ ] Consider making channels and devices at the same level

##### Package
- [x] Add rotation to 1P-specific SpatialProtocol
- [ ] Test SpatialProtocol file writer 
- [x] Dates for SpectralProtocol file names
- [x] Add Location to SubjectFactory
- [x] Ensure eye-specific parameters go to Eye, not subject
- [x] Get specific Calibration (at Dataset) from Stimulus in Epoch

##### HDF5
- Write data from persistent interface
  - [ ] Set property for dynamicprops
  - [x] Overwrite string, char, datetime (dimensions don't matter)
  - [x] Overwrite numeric dataset with same dimensions
  - [x] Overwrite numeric dataset with different dimensions
- [ ] Could copying the file replicate h5repack?
- [ ] Testing for int and uint

##### Minor
- [x] Name vs name
- [x] files property should be lowercase
- [ ] How to handle Reader properties
- [x] Devices with same UUID in multiple channels?
- [ ] Figure out identification of existing Sources when adding Source hierarchy

##### Documentation
- [x] Handle class
- [ ] Date formats
