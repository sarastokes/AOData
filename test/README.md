# AOData Test Suite

## Code Coverage
As of 20Dec2022, the ```aod``` package report contains **127 files** and has:
- **51.85%** statement coverage (3683 executable). 
- **52.81%** function coverage (635 executable).

The apps are the least tested, excluding ```aod.app```, code coverage is **60.10%** for statements and **63.73%** for functions.

## Tests
The AOData test suite currently contains the following:
- ```AODataViewerTest``` - tests the AODataViewer app
- ```BuiltinClassTest``` - tests operation of builtin subclasses
- ```CoreApiTest``` - tests core interface queries
- ```CoreInterfaceTest``` - tests basic functions of the core interface
- ```CustomDisplayTest``` - ensures custom displays do not throw errors
- ```EnumerationTest``` - tests basic functioning of enumeration classes not covered elsewhere
- ```HDFTest``` - tests I/O accuracy for MATLAB data types to HDF5 datasets and attributes
- ```FileReaderTest``` - tests builtin file readers
- ```FilterTest``` - tests AOQuery filters
- ```PersistorTest``` - tests modification of HDF5 files from persistent interface
- ```SyncTest``` - tests validation performed when adding an entity to an experiment
- ```UtilityTest``` - tests the utility functions supporting AOData


## Use
The full test suite can be run with:
```matlab
results = runAODataTestSuite();
```

A code coverage report for the full ```aod``` package can be run as shown below. An additional optional output packageCoverage returns a table with code coverage broked down by subpackage (e.g. ```aod.core```, ```aod.persistent```). The code coverage output will be stored in a folder called "coverage_report" within the "test" folder.
```matlab
[results, packageCoverage] = runAODataTestSuite('Coverage', true);
```

An individual test can be run as:
```matlab
result = runtests('HDFTest');
```