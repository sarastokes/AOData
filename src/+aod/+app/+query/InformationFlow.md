# Information Flow through AOQuery App
Each `aod.app.Component` has a `Handler` property for an  associated `aod.app.EventHandler`, which listens to events triggered by the Component (`aod.app.Event`).  When a component triggers an event using the `publish()` method of `aod.core.Component`, it first travels up the component hierarchy through the chain of `aod.app.EventHandler`'s in each object. Each Component has the decision whether to act on the event and whether to pass it to their `Parent`'s `Handler` (default is to pass). 

Information can travel back down the component hierarchy when an EventHandler calls their Component's `update()` method. Each Component's update method can choose to act on the event and whether to pass it to their child Components.  

Generally, information reaches a target component, which acts on it and then triggers the update chain. This is valuable, for example, when adding a filter, the filter information travels up to `QueryView` and the filter is created, then added to the entity. If this is successful, the information flows back down and other Components can react to the successful addition of a filter. 

|Object|Event|Upstream|Downstream|
|-|-|-|-|
|ExperimentPanel|AddExperiment|QueryView|CodePanel, ExperimentPanel|
|ExperimentPanel|RemoveExperiment|QueryView|CodePanel, ExperimentPanel|
|EntityTree|SelectedNode|QueryView|EntityBox|
|EntityTree|DeselectedNode|MatchPanel|EntityTree|
|EntityBox|OpenViewer|QueryView|N/A|
|EntityBox|ParentRequest|MatchPanel|EntityTree|
|FilterPanel|ClearFilters|QueryView|CodePanel, FilterPanel (FilterBox)|
|InputBox|AddSubfilter|FilterBox|SubfilterBox|
|InputBox|SearchRequest|QueryView|InputBox|
|InputBox|ChangedFilterType|FilterBox|InputBox, FilterControls|
|InputBox|ChangedSubfilterType|SubfilterBox|InputBox, FilterControls|
|InputBox|ChangedFilterInput|FilterBox|FilterControls|
|InputBox|ChangedSubfilterInput|SubfilterBox|FilterControls|
|FilterControls|PushFilter|QueryView|CodePanel, EntityTree, FilterPanel (FilterBox, SubfilterBox, FilterControls)|
|FilterControls|PullFilter|QueryView|CodePanel, EntityTree, FilterPanel (FilterBox, SubfilterBox, FilterControls|
|FilterControls|EditFilter|FilterBox|FilterPanel --> FilterBox, SubfilterBox, FilterControls|