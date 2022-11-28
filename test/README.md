# AOData Test Suite


## Code Coverage
As of 27Nov2022, the ```aod``` package report contains **131 files** and has:
- **43.52%** statement coverage (4184 executable lines) 
- **45.67%** function coverage (716 executable lines).

## Tests
The AOData test suite currently contains the following:
- ```BuiltinClassTest``` - tests operation of builtin subclasses
- ```CoreInterfaceTest``` - tests basic functions of the core interface
- ```CustomDisplayTest``` - ensures custom displays do not throw errors
- ```EnumerationTest``` - tests basic functioning of enumeration classes not covered elsewhere
- ```HDFTest``` - tests I/O accuracy for MATLAB data types
- ```FileReaderTest``` - tests builtin file readers
- ```FilterTest``` - tests AOQuery filters
- ```PersistorTest``` - tests modification of HDF5 files from persistent interface
- ```SyncTest``` - tests validation performed when adding an entity to an experiment


## Use
The full test suite can be run with:
```matlab
results = runAODataTestSuite();
```
A code coverage report for the full ```aod``` package can be run with:
```matlab
results = runAODataTestSuite('Coverage', true);
```
An individual test can be run as:
```matlab
result = runtests('HDFTest');
```