## AOQuery

AOQuery provides a number of **filters** that together enable access to all aspects of an AOData file. 

Each filter is associated with a class (e.g. `aod.api.NameFilter` for querying entity names). 


##### `aod.api.NameFilter`
Inputs: 
1. `Value`: text or a function handle

Examples:
```matlab
% Filter by a specific name
{'Name', 'VisiblePmt'}
% Filter with a custom function
{'Name', @(x) contains(x, 'PMT')}  % Match names containing "PMT"
{'Name', @(x) endsWith(x, 'PMT')}  % Match names ending with "PMT"
```

##### `aod.api.ClassFilter`
```matlab
% Filter by a specific class
```