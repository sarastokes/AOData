# App development

Notes on how AOData's apps are designed

## AODataViewer
- `ExperimentPresenter`
- `ExperimentView`

Components are defined along three enumertations:
- `GroupLoadState` - only for `H5NodeTypes.GROUP`. Indicates whether attributes, contents are populated. 
- `H5NodeTypes` - HDF5 type (group, dataset, link) that determines I/O 
- `AONodeTypes` - Detailed identity that determines node display. Responsibilities include:
    - Providing the appropriate icon for the node
    - Determining the display type
    - Reformatting data, if necessary, for display

There are 4 types of nodes: entity, container, dataset and link. All types have a struct called nodeData
- Dataset (currently uses **`h5info`** for Attributes):
    - **H5Node**: `H5NodeTypes.DATASET`
    - **EntityPath**: extracted from parent node's tag
    - **AONode**: `AONodeTypes` class/name-dependent from **`AONodeTypes.get(data, dsetName)`** 
    - **Attributes**: `containers.Map()` from fcn **`attributes2map(info.Attributes)`**
- Group (attributes already loaded so are assigned immediately)
    - **LoadState**: `GroupLoadState.ATTRIBUTES` by default
    - **AONode**: `AONodeTypes.ENTITY` or `AONodeTypes.CONTAINER` based on Class attribute
    - **Attributes**: **`attributes2map(group.Attributes)`**
- Link (attributes currently not loaded!)
    - **LinkPath**: target HDF5 group name
    - **H5Node**: `H5NodeTypes.LINK`
    - **AONode**: `AONodeTypes.LINK`

Groups nodes are all created on startup and because the **`h5info`** call required for parsing the groups loads attributes, these are immediately assigned. This could be refactored to greatly improve speed in the future. 

Thoughts on a better workflow:
- Use the list of HDF5 paths and corresponding entity types from `EntityManager` to populate groups
    - Sort by name to ensure shorter ones (parents) are processed before longer ones (children)
    - Populate all container groups based on entity type - use `aod.core.EpochTypes`: `validChildTypes` and if not empty `childContainers`
    - Only populate placeholder nodes for entities that do not have containers (Device, Registration, Stimulus, Response, EpochDataset, Annotation, Calibration) - 
    - Do not populate group attributes (`GroupLoadState.NAME`)
- On click of a node, attributes are loaded if not already present (`GroupLoadState.hasAttributes`)
    - If `AONodeTypes.ENTITY`, delete the placeholder node