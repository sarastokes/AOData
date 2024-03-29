# AOData Test Suite

## Code Coverage
As of 25May2023, the ```aod``` package report contains **200 files** and has:
- **80.42%** statement coverage (6779 executable). 
- **86.25%** function coverage (1135 executable).

## Tests
The AOData test suite currently contains the following:
- User interfaces:
  - ```AODataManagerTest``` - tests display, preference setting and interaction with AODataManagerApp
  - ```AOQueryAppTest``` - tests user interface for building AOData queries
  - ```AODataViewerTest``` - tests display and user interaction with the AODataViewer app
  - ```CustomSubclassTest``` - tests the framework and UI for generating template subclasses
- Built-in classes:
  - ```BuiltinClassTest``` - tests operation of builtin subclasses. 
  - ```FileReaderTest``` - tests builtin file readers
- Common interface
  - ```CoreApiTest``` - tests core interface queries
- Core interface  
  - ```CoreInterfaceTest``` - tests basic functions of the core interface not covered in dedicated tests. 
  - ```EpochTest``` - tests core Epoch interface
  - ```ResponseTest``` - tests core Response interface
  - ```SourceTest``` - tests core Source interface
  - ```SyncTest``` - tests validation performed when adding an entity to an experiment
- Persistent interface
  - ```FilterTest``` - tests AOQuery filters
  - ```InterfaceTest``` - tests equality between persistent and core interfaces
  - ```PersistentInterfaceTest``` - tests reading HDF5 files into MATLAB interface
  - ```PersistorTest``` - tests modification of HDF5 files from persistent interface
- HDF5 tests
  - ```HDFTest``` - tests I/O accuracy for MATLAB data types to HDF5 datasets and attributes
  - All other tests can be found in the h5tools-matlab package
- Schema tests
  - ```PrimitiveTest``` - tests primitives for AOData schemas
  - ```SchemaTest``` - tests framework for working with full schemas
  - ```SpecificationTest``` - tests validators, decorators and default values for Records (formerly: templates for specifying AOData subclasses)
- Miscellaneous tests
  - ```CustomDisplayTest``` - ensures custom displays do not throw errors
  - ```EnumeratedTypeTest``` - tests basic functioning of enumeration classes not covered elsewhere
  - ```ProtocolTest``` - tests the protocol class and integration with experimental hierarchy
  - ```UtilityTest``` - tests the AOData's util package. Some components have dedicated tests:


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
result = runAODataTest('CoreInterfaceTest',... 
    'Package', 'aod.core', 'Debug', true,... 
    'KeepFiles', false. 'ResetFiles', true);
```