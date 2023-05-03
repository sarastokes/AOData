# Persistent Interface Dev Notes
Details about how the persistent interface is implemented. 

#### Renaming entities
1. Confirm user wants to change group name and impact HDF5 paths
    - `aod.app.dialogs.NameChangeDialog`
2. Check whether new group name will be unique
    - `aod.persistent.util.getEntityGroupCohort`
3. Move entity's group to new name group
    -  `h5tools.move`
4. Overwrite all links to original HDF5 path (using cached entities if available to ensure workspace variables are correct)
    - `aod.h5.collectExperimentLinks`
5. Update HDF5 path property of child entities in cache (because these are handle classes all existing variables in user's workspace *should* be updated accordingly)
6. Update entity table