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
An individual test can be run as:
```matlab
result = runtests('HDFTest');
```


##### Code Coverage
|Folder|Statement|Function|
|------|---------|---------|
|core|51.9%|48.36%|
|h5|54.04%|54.38%|
|persistent|16.92%|18.89%|
|util|10.78%|21.73%|


TODO: Specific tests for custom displays, enumerations
