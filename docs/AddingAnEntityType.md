# Adding an entity type

Contact me if you think you need a new entity type. If it's something I have overlooked that would be useful to multiple groups, I would like to add it to AOData. 

**Information Needed:**
- Where in the AOData object model does the new type go? 
- What are the parent and child entity types, if applicable

The process of adding a new Entity would take an hour or two and backwards compatibility is possible. 

```aod.common.EntityTypes```
- Add to enumeration
- Add to ```validParentTypes```
- Add to ```validChildTypes```
- Add to ```parentContainer```
- Add to ```empty```
- Add to ```getByClass```
- Add to ```get```

Create new core and persistent classes (use existing classes as a template)

```aod.core.Experiment```
- Add to ```get```
- Add to ```remove``` or ```removeByEpoch```, if needed

Add to parent class 
- Add to ```get()``` - if parent class isn't Experiment
- Add to ```add()```
- Add to ```remove()``` 
- Add to properties (core)
- Add entity container and entity container method (persistent)

Add to `aod.core.MixedEntitySet`