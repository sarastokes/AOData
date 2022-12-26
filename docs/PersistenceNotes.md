# Persistence Notes

### Adding an entity
- ```add``` (entity specific, e.g. ```aod.persistent.Epoch```)
  - Sets the new entity's parent (```setParent``` in ```aod.core.Entity```)
  - Sends new entity to ```addEntity```
- ```addEntity``` in ```aod.persistent.Entity``` makes the ```GroupEvent``` data and triggers event ```GroupChanged```
- ```onGroupChanged``` - callback in ```aod.persistent.Entity```
    - Makes the change in the HDF5 file
    - Reflects the change in the entity
    - Creates ```EntityEvent``` data and triggers event ```EntityChanged```
- ```onEntityChanged``` in ```aod.persistent.EntityFactory```
  - Makes sure change is reflected in entity UUID list