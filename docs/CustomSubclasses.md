# Custom Subclasses

*Under development, not complete!*


#### Naming subclasses (```Name``` and ```label``` properties)
Subclass names can be either *user-defined* or *automatically generated*. User-defined names are found in the ```Name``` property while automatically generated names are found in the ```label``` property. You can't set label directly, instead it is set to the output of the protected method ```getLabel()```. 

By default, all AOData entities require user-defined names (i.e. have "Name" as a first input to the constructor), although you can provide an empty name ```[]```. 
By default, ```label``` will be the class name.

When writing to the HDF5 file, ```Name``` takes precedence over ```label```.

Check out the different options in ```AODataSubclassCreator``` to see how they impact the constructor. 


## Advanced
#### User-defined UUIDs (```UUID``` property)
If you have an entity that is repeated across experiments, it is possible to assign the same UUID to that entity. Ideally, the entities should be recognizable as the same by their metadata (which can be queried by AOQuery) so I am considering just doing away with ```setUUID``` entirely...


#### Tracking changes (```LastModified``` property)
**Core interface** - Designate properties as "SetObservable" to update the ```LastModified``` property when changed.

**Persistent interface** - All changes are tracked by default. 