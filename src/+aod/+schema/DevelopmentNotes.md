# Specification

### Todo list
**Requirements**
- [ ] Validation performed in MATLAB while maintaining language independence
- [ ] Schema documentation in a language-independent format (YAML > JSON)
- [ ] Decentralized but with support for standardization, along with navigation of schema evolution
- [ ] User-friendly

**Representation**
- [ ] Combine `expectedAttributes` and `expectedDatasets` into a single property (`schema`?)
- [ ] Add `expectedFiles` with descriptions or is that too excessive?
- [ ] Units Decorator (implement siunitx)?

**Methods of schema validation**
- [ ] Check an individual file before writing
- [ ] Always with `setProp` from persistent interface. Option to use `setProp` from core interface
- [ ] Always with `setAttr` from either interface

**Schema persistence**
- [ ] When to perform, how frequently?
    - Update *after* successful write to an HDF5 file
    - Update on user request
- [ ] Schema folder in HDF5 file?
- [ ] Schema UUIDs assigned on first persistence
    - Independent of class name (renaming class maps to same UUID)
    - Add option to cleanup and remove extraneous classes from "current schema"
- [ ] Schema versioning at the entity level
  - [ ] Cleanup old versions unused by existing files
  - [ ] Mark as deprecated

**Schema evolution**
- [ ] Quick update by class
- [ ] `setProp` with optional schema input, then convert

**Alias management**
- [ ] AliasManager class (look at MATLAB's existing alias support for design ideas)
  - [ ] Alias class containing old name and cutoff date
- [ ] How to persist?
- [ ] Change class names in file (but need to maintain reference to old class name too)

**User options**
- [ ] Show schema for a specific data type in UI (as a tree? text?)


### Schema JSON (or YAML)
Should entire package be in one file or separate files referenced by a "schema registry"? If the files are large, might want to serialize with msgpack.
- Schema UUID
  - *Versions*
    - Class name
    - *Aliases*
      - Class name
      - Cutoff date
    - *Datasets*
    - *Attributes*
    - DateCreated

### Class Hierarchy
The each parent-child relationship in the hierarchy is one-to-many. Parent classes have properties for containing the child classes. The child classes maintain a reference to the parent class with a property called `Parent`.
- **`aod.common.Entity`**
  - `SchemaManager` (`AttributeManager` and `DatasetManager`)
    - `Entry`: a specific attribute or dataset defined by a `Primitive` which has a specific `PrimitiveType`
      - `Specification` (`Validator` and `Decorator`) - the PrimitiveType determines specifications for a given Entry

### Primitives
Each primitive inherits from `aod.specification.primitives.Primitive` and include a specific set of validators (discussed below).

|Name|Matlab Classes| Description|
|----|--------------|------------|
|Boolean|logical||
|Date|datetime||
|Duration|duration||
|File|string||
|Integer|uint8, int8, etc...||
|Link|aod.common.Entity subclasses||
|Number|double||
|Text|string, char| |

You can have a `double` that is specified as an __Integer__. Nevermind?? Just removed support for this on 25Oct2023.


### Validators
| Name | Types | Description |
|------|-------|-------------|
|EntityType|Link|Specifies the allowable entity types for a link (e.g., `["System", "Channel"]` enforces only systems and channels)|
|Enum|Text| Specifies an allowable set of answers (e.g., `["Low", "Medium", "High"]` restricts the value to only those three words) |
|ExtensionType|File| Specifies allowable file extensions (e.g., `[".json", ".txt"]`|
|Length|Text   | Specifies the length of a string (e.g., "test" is 4)|
|Maximum|Number, Integer| Specifies the inclusive maximum allowable number (e.g., `-1` enforces only negative numbers and not 0)|
|Minimium|Number, Integer| Specifies the inclusive minimum allowable number (e.g., `0` enforces only positive numbers and 0)|


Some primitives will set default values (unless user provides something more specific). This includes:
- _Integer_: if the class is an integer class, the appropriate *Minimum* and *Maximum* values will be set (e.g., `uint8` sets the minimum to 0 and the maximum to 255).
- _Categorical_ sets the *Enum* validator to the provided names.

### Components
Basic types (**validator**, *decorator*):
- Shared between all types
    - *Description* - information on the paramter
    - **Format** - this is the underlying MATLAB class
    - **Size**
- Number: (double/float)
    - **Minimum** - inclusive minimum
    - **Maximum** - inclusive maximum
    - *Units*
- String:
    - **Enum**
    - **Regexp** - accepts MATLAB function handles
    - **Length** - characters in the string
- Datetime
    - Format: 'yyyyMMdd HH:mm:ss'
- Date (```yyyymmdd(datetime)```)
    - Format: 'yyyyMMdd'
- Time
- Duration
    - **Units**
- Table
    - **NumFields**
    - **Length**
    - _Fields_ (consists of other objects)


### Writing an AOData HDF5 file
1. `checkSchemaIntegrity` - are schemas viable
2. `checkGitRepo` - are classes committed? Only prompt if schemas are viable
3. `updateSchemas` - update schemas before writing

### Misc notes
- Don't use numeric indexing for tables, use the column names so it's clear what data is used (and how to modify the code if the table changes in the future)
- Values are only validated if not empty (or not "" in the case of `string`)
- Avoid `char`, `struct` and `containers.Map`


### Interaction
```matlab
    function value = specifyAttributes(obj)
        value.add("Name", "type", varargin{:});
    end
```