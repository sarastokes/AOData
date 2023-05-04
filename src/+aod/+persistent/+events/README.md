

| Event       | EventData Class | Source | Target | Description |
| ----------- | ----------- | --- | --- | --- |
| EntityChanged      | EntityEvent       | Persistor | EntityFactory | HDF5 group change |
| HdfPathChanged   | HdfPathEvent        | Persistor | EntityFactory | HDF5 group path change (renamed entity) |


When working with a file through the persistent interface, `aod.persistent.EntityFactory` serves as the middle layer between MATLAB and the HDF5 file. All entities within a file are logged by `aod.h5.EntityManager` (property of EntityFactory) and entities are requested and cached in the EntityFactory. 

Any change made through an `aod.persistent.Entity` subclass is implemented at the level of the HDF5 file by `aod.persistent.Persistor`. If the change has side effects for other entities or requires modification to middle layer (EntityFactory), these changes are handled by `aod.persistent.EntityFactory`. 

#### When entity is added or removed
**GroupChanged** (**GroupEvent**): `Entity` --> `Persistor`
**EntityChanged** (**EntityEvent**): `Persistor` --> `EntityFactory`