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


### Schema JSON
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
  - `EntitySchema`
    - *`SchemaCollection`*: three subclasses `AttributeCollection`, `FileCollection` and `DatasetCollection`
      - `Record`: a specific attribute or dataset defined by a *`Primitive`* which has a specific `PrimitiveType`. Some primitive types can contain other primitives (*`Container`*)
        - Multiple *`Specification`* (*`Validator`*, *`Decorator`* and `Default`) - the PrimitiveType determines specifications for a given Record

### Primitives
Each primitive inherits from `aod.schema.primitives.Primitive` and include a specific set of validators (discussed below). Primitives in *italics* are Containers that hold other primitives (subclasses of `aod.schema.primitives.Container`). They map to H5T_COMPOUND so can only hold valid primitive types (boolean, date, duration, file, integer, number, text).

|Name|Matlab|Python| Description|
|----|------|--------|------------|
|`Boolean`|logical|bool|True or false|
|`Date`|datetime|datetime||
|`Duration`|duration|timedelta||
|`File`|string|string|An absolute or relative file path|
|`Integer`|uint8, int8, etc...|int||
|`Link`|aod.common.Entity subclasses|||
|_`List`_|cell|list|Contains items of different types or with different specifications. Unlike Object, they are not distinguished by name but by index, like a numbered list|
|`Number`|double|float|Standard MATLAB numbers|
|_`Object`_|struct, handle|dict| Use this when the dataset contains multiple data types distinguished by name|
|`Text`|string| string||

You can have a `double` that is specified as an __`Integer`__. Nevermind?? Just removed support for this on 25Oct2023. Should probably integrate `single` support into __`Number`__

Currently not supporting `char` as it can cause issues with the queries (e.g., each character can be considered equal to a double).

### Validators
| Name | Types | Description |
|------|-------|-------------|
|Class|all|Specifies allowable MATLAB classes (some primitives set automatically)|
|EntityType|Link|Specifies the allowable entity types for a link (e.g., `["System", "Channel"]` enforces only systems and channels)|
|Enum|Text, Integer, Number| Specifies an allowable set of answers (e.g., `["Low", "Medium", "High"]` restricts the value to only those three words) |
|Extension|File| Specifies allowable file extensions (e.g., `[".json", ".txt"]`|
|Interval|duration|The time interval (seconds, minutes, etc see `IntervalTypes`)|
|Length|Text   | Specifies the length of a string (e.g., "test" is 4)|
|Maximum|Number, Integer| Specifies the *inclusive* maximum allowable number (e.g., `-1` enforces only negative numbers and not 0)|
|Minimium|Number, Integer| Specifies the *inclusive* minimum allowable number (e.g., `0` enforces only positive numbers and 0)|
|Regexp|Text, File| Uses regular expressions to validate text |
|Size|all|The specific size or number of dimensions|

Some primitives will set default values (unless user provides something more specific). This includes:
- _Integer_: if the class is an integer class, the appropriate *Minimum* and *Maximum* values will be set (e.g., `uint8` sets the minimum to 0 and the maximum to 255).
- _Categorical_ sets the *Enum* validator to the provided names.

### Decorators
Decorators add metadata but do not perform any validation on user-provided values.
|Name|Primitives|Description|
|----|----------|-----------|
|Description| all | Text scalar describing the entry.|
|Units|Number, Integer|Units for a number (preferrably SI)|


### Components
Basic types (**validator**, *decorator*):
- Shared between all types
    - *Description* - information on the paramter
    - **Format** - this is the underlying MATLAB class
    - **Size**
- Number: (double/float)
    - **Minimum** - inclusive minimum
    - **Maximum** - inclusive maximum
    - __Enum__
    - *Units*
- Integer:
    - **Minimum**
    - **Maximum**
    - __Enum__
    - *Units*
- String:
    - **Enum**
    - **Regexp** - standard regular expression string or can convert some MATLAB function handles
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
2. `validate` - do provided values pass schema validation?
3. `checkRequirements` - are required values provided? AOData sticks to soft requirements and users can choose to leave a required value blank.
4. `checkGitRepo` - are classes committed? Only prompt if schemas are viable
5. `updateSchemas` - update schemas before writing

### Misc notes
- Don't use numeric indexing for tables, use the column names so it's clear what data is used (and how to modify the code if the table changes in the future)
- Values are only validated if not empty (or not "" in the case of `string`)
- Avoid `char`, `struct` and `containers.Map`

### Validation error messages
For a Record that is not nested:
- BOOLEAN Size violation for Dataset "DsetName" in EPOCH "Epoch1" of "ExptName" (\Experiment\Epochs\Epoch1)
- `PrimitiveType` `ValidatorType` violation for  `CollectionType` **RecordName** in `EntityType` **EntityName** of **ExperimentName** (*EntityPath*)

For a Primitive that is nested and named:
- BOOLEAN Size violation for "ItemName" in TABLE Dataset "DsetName" in EPOCH "Epoch1" of "ExptName" (\Experiment\Epochs\Epoch1)
- `PrimitiveType` `ValidatorType` violation for **ItemName** in `ContainerType` `CollectionType` **RecordName** in `EntityType` **EntityName** of **ExperimentName** (*EntityPath*)

Necessary access from Validator (provides `ValidatorType` and exception message):
- getPrimitive - provides `PrimitiveType` (if nested, **ItemName** or **ItemID**)
- getRecord - provides **RecordName** (if nested extract `ContainerType`)
- getCollection - provides `CollectionType`
- getEntity - provides `EntityType`, **EntityName**, **ExperimentName** and *EntityPath*

### Interaction
```matlab
    function value = specifyAttributes(obj)
        value.add("Name", "type", varargin{:});
    end
```

### Syntax
##### Number
```matlab
obj.set('DsetName', 'NUMBER',...
    'Description', 'This is an example');

% Examples
3.14159
[1 2 3; 4 5 6]
zeros(3, 3, 3)

obj.set('DsetName', 'NUMBER',...
    'Minimum', 2, 'Maximum', 3,...
    'Units', 'mV', 'Description', 'Must be between 2 and 3 (inclusive)');

% Examples
2.5
[2, 2.4; 3, 2.9]
2:0.1:3

obj.set('DsetName', 'NUMBER',...
    'Minimum', 2, 'Maximum', 3, 'Size', '(1,:)',...
    'Units', 'mV', 'Description', 'Must be a row between 2 and 3 (inclusive)');

% Examples
2.5
2:0.1:3
```

##### Text
TODO: Add regexp demos, enum
```matlab
obj.set('TextData', 'TEXT',...
    'Description', 'One or more strings');

% Examples
"hey"
["hey", "hello", "hi"]
["hey", "hej"; "hey", "hej"]

obj.set('TextData', 'TEXT',...
    'Length', 3,...
    'Description', 'One or more 3 character strings');

% Examples
"hey"
["hey", "hej"; "hey", "hej"]

obj.set('TextData', 'TEXT',...
    'Count', 3, 'Size', '(1,1)',...
    'Description', 'One three character string');

% Examples
"hey"
```

##### List
Note that some validators are set automatically. For the example below, "Count" is set to 3.

To define items starting from scratch:
1. When initializing, a cell containing other cells (1 per item) could be passed to `parse` via the `set` method.
2. The same could be performed to totally reset the Items field (subclass action)

To modify existing or inherited items without reseting;
1. An existing field could be changed with `set` and sent to `parse` (?) as a cell that does not contain other cells.
2. A new field could be added with `addField`
3. A field could be removed with `removeField`
4. Existing fields could be reordered with `reorderFields`

```matlab
obj.set('ArrayData', 'LIST',...
    'Items', {
        {'NUMBER', 'Size', '(1,1)', 'Description', 'A number'},
        {'TEXT', 'Length', 3, 'Description', 'A three letter string'},
        {'INTEGER', 'Class', 'uint8', 'Default', uint8(3), 'Description', 'An integer'}},...
    'Description', 'An object that is a number, a 3 letter string, then an integer');

% Examples
{3.5, "abc", uint8(4)}

obj.setItem(1, 'Maximum', 3);

% Examples
{2.5, "abc", uint8(4)}

obj.addItem(4, 'TEXT', 'Enum', ["low", "medium", "high"],...
    'Description', 'A text value limited to low medium or high');

% Examples
{2.5, "abc", uint8(4), "low"}

```