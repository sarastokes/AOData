### AOData Test Suite


The AOData test suite currently contains the following:
- ```CoreClassInstantiationTest``` - tests instantiation of core classes
- ```BuiltinClassTest``` - tests operation of builtin subclasses
- ```CoreInterfaceTest``` - tests basic functions of the core interface
- ```HDFTest``` - tests I/O accuracy for MATLAB data types
- ```FilterTest``` - tests AOQuery filters
- ```PersistorTest``` - tests modification of HDF5 files from persistent interface
- ```SyncTest``` - tests validation performed when adding an entity to an experiment



The full test suite can be run with:
```matlab
results = runAODataTestSuite();
```
A code coverage report for the full "aod" package can be run with:
```matlab
results = runAODataTestSuite('Coverage', true);
```
An individual test can be run as:
```matlab
result = runtests('HDFTest');
```


##### Code Coverage
As of 23Nov2022, the aod package report contains 127 files and has **30.33%** statement coverage (3992 executable) and **30.17%** function coverage (696 executable).

TODO: Specific tests for custom displays, enumerations
