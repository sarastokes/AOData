# Schema Framework

*Intended as a development reference rather than a formal documentation*

- __`initializePackageSchemas.m`__: creates schemas folder, registry.txt and schema.json files.
- __`navToRoot`__: given _`className`_, returns root file path (folder containing first subpackage folder). Optional 2nd input can specify _`"registry"`_ to get the registry.txt file or _`"json"`_ to get the schema JSON file.
- __`loadSchemaRegistry`__: given a package name, loads the `registry.txt` file into a table. Better than `readtable` because the loaded data is reformatted to ensure string instead of char
- __`collectRegistries`__: loops through SearchPaths pref and identifies all `registry.txt` files, then loads them and compiles into a single table.
- __`collectAllSchemas`__: collects all schemas in all registries and returns as a `struct`
- __`getNestedField`__: given a class name, returns the nested field containing the schema struct. For use with output of `collectAllSchemas`.

TODO:
- Currently no support for integrating changes to existing folders - that should go elsewhere
- SchemaVersion access from `aod.schema.StandaloneSchema`
- Update existing schema json file and registry txt with a change.
- Cross-reference existing schema registry and files with current classes

1. Update function