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

##### Package
- [x] Add rotation to 1P-specific SpatialProtocol
- [ ] Test SpatialProtocol file writer 
- [ ] Dates for SpectralProtocol file names
- [x] Add Location to SubjectFactory
- [x] Ensure eye-specific parameters go to Eye, not subject
- [x] Get specific Calibration (at Dataset) from Stimulus in Epoch

##### HDF5
- Write data from persistent interface
  - [ ] Set property for dynamicprops
  - [x] Overwrite string, char, datetime (dimensions don't matter)
  - [ ] Overwrite numeric dataset with same dimensions
  - [ ] Overwrite numeric dataset with different dimensions
- [ ] Could copying the file replicate h5repack?

##### Minor
- [x] Name vs name
- [x] files property should be lowercase
- [ ] How to handle Reader properties
- [ ] Devices with same UUID in multiple channels?

##### Documentation
- [x] Handle class

##### Other
- [ ] Don't forget to register for SFN by early deadline!!!!!