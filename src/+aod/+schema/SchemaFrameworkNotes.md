# Schema Framework

*Intended as a development reference rather than a formal documentation*

- `initializePackageSchemas.m`: creates schemas folder, registry.txt and schema.json files.
- `navToRoot`: given `className`, returns root file path (folder containing first subpackage folder). Optional 2nd input can specify `"registry"` to get the registry.txt file or `"json"` to get the schema JSON file.
- `loadSchemaRegistry`: given a package name, loads the registry.txt file into a table (with some extra formatting)
- `collectRegistries`: loops through SearchPaths pref and identifies all registry.txt files, then loads them and compiles into a single table.

TODO:
- Currently no support for integrating changes to existing folders - that should go elsewhere
- SchemaVersion access from `aod.schema.StandaloneSchema`
- Update existing schema json file and registry txt with a change.
- Cross-reference existing schema registry and files with current classes