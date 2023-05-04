# Persistent Interface Dev Notes
Details about how the persistent interface is implemented. 

#### Renaming entities
1. Confirm user wants to change group name and impact HDF5 paths
    - `aod.app.dialogs.NameChangeDialog`
2. Check whether new group name will be unique
    - `aod.persistent.util.getEntityGroupCohort`
3. Trigger `aod.persistent.events.NameEvent` (**Entity** --> **Persistor**)
4. Move entity's group to new name group
    - `h5tools.move` (**Persistor**)
5. Trigger `aod.persistent.events.HdfPathEvent` (**Persistor** --> **EntityFactory**)
6. Overwrite all links to original HDF5 path (via h5tools functions as entities will not load due to invalid softlinks)
    - `aod.h5.collectExperimentLinks`
7. Update HDF5 path property of child entities in cache (because these are handle classes all existing variables in user's workspace *should* be updated accordingly)
    - `aod.persistent.Entity\setHdfPath`
8. Reload cached entities to ensure link properties are valid
9. Update entity table
    - `EntityManager\collect`