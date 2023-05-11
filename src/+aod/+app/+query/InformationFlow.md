

|Object|Event|Upstream|Downstream|
|-|-|-|-|
|ExperimentPanel|AddExperiment|QueryView|ExperimentPanel|
|ExperimentPanel|RemoveExperiment|QueryView|ExperimentPanel|
|EntityTree|NodeSelected|QueryView|EntityBox|
|EntityTree|ParentRequest|MatchPanel|EntityTree|
|InputBox|AddSubfilter|FilterBox|SubfilterBox|
|InputBox|SearchRequest|QueryView|InputBox|
|InputBox|ChangedFilterType|FilterBox|InputBox, FilterControls|
|InputBox|ChangedSubfilterType|SubfilterBox||
|InputBox|ChangedFilterInput|FilterBox|FilterControls|
|InputBox|ChangedSubfilterInput|SubfilterBox|FilterControls|
|FilterControls|PushFilter|QueryView|FilterPanel --> FilterControls|
|FilterControls|PullFilter|QueryView|FilterPanel --> FilterControls|
|FilterControls|EditFilter|FilterBox|FilterControls|