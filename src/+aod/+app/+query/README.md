# AOQuery App

- QueryView 
    - ExperimentPanel
    - CodePanel
    - MatchPanel
        - EntityTree
        - EntityBox
    - FilterPanel
        - FilterBox
            - InputBox
            - FilterControls
            - SubfilterBox 

1. **EntityTree**
    - SelectedNode
    - DeselectedNode
2. **ExperimentPanel**
    - AddExperiment
    - RemoveExperiment
3. **FilterPanel**
    - AddNewFilter
    - ClearFilters
4. **FilterBox**
5. **InputBox**
    - ChangedFilterType
    - NameProvided
    - ValueProvided
    - SearchNames
    - AddSubfilter  
6. **FilterControls**
    - `AddFilter` - create the filter and add to QueryManager
    - RemoveFilter
    - `CheckFilter` - create the filter and run, but don't add to parent QueryManager
    - EditFilter
7. **CodePanel**
    - ExportCode
    - CopyCode
8. **MatchPanel**
    - PanelExpanded
    - PanelMinimized


UpdateTypes
- `ChangedExperiments`
- `ChangedFiltering`