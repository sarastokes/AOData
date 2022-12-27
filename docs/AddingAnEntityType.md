

Information Needed:
- Where in the AOData object model does the new type go? 
- What are the parent and child entity types, if applicable

```aod.core.EntityTypes```
- Add to enumeration
- Add to ```validParentTypes```
- Add to ```validChildTypes```
- Add to ```parentContainer```
- Add to ```empty```
- Add to ```getByClass```
- Add to ```get```


```aod.core.Experiment```
- Add to ```get```
- Add to ```remove``` or ```removeByEpoch```, if needed

If parent is different than experiment, in the parent core entity
- Add to ```get```
- Add to ```remove``` 
- Add to properties