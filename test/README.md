# AOData Test Suite

## Code Coverage
As of 8Jan2023, the ```aod``` package report contains **145 files** and has:
- **66.25%** statement coverage (4753 executable). 
- **66.17%** function coverage (813 executable).

The apps are the least tested, excluding ```aod.app```, code coverage is **70.80%** for statements and **72.28%** for functions.

## Tests
The AOData test suite currently contains the following:
- ```AODataViewerTest``` - tests display and user interaction with the AODataViewer app
- ```BuiltinClassTest``` - tests operation of builtin subclasses
- ```CoreApiTest``` - tests core interface queries
- ```CoreInterfaceTest``` - tests basic functions of the core interface
- ```CustomDisplayTest``` - ensures custom displays do not throw errors
- ```EnumeratedTypeTest``` - tests basic functioning of enumeration classes not covered elsewhere
- ```HDFTest``` - tests I/O accuracy for MATLAB data types to HDF5 datasets and attributes
- ```FileReaderTest``` - tests builtin file readers
- ```FilterTest``` - tests AOQuery filters
- ```PersistorTest``` - tests modification of HDF5 files from persistent interface
- ```ProtocolTest``` - tests the protocol class and integration with experimental hierarchy
- ```ResponseTest``` - tests Response entity in core interface
- ```SourceTest``` - tests Source entity in core interface
- ```SubclassGeneratorTest``` - tests the framework and UI for generating template subclasses
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
or with optional debugging and code coverage through:
```matlab
result = runTestWithDebug('CoreInterfaceTest', 'aod', true);
```