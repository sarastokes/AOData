# AOData Test Suite

## Code Coverage
As of 20Dec2022, the ```aod``` package report contains **128 files** and has:
- **54.11%** statement coverage (3711 executable). 
- **55.72%** function coverage (638 executable).

The apps are the least tested, excluding ```aod.app```, code coverage is **60.41%** for statements and **64.27%** for functions.

## Tests
The AOData test suite currently contains the following:
- ```AODataViewerTest``` - tests display and user interaction with the AODataViewer app
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
result = runtests('CoreInterfaceTest');
```