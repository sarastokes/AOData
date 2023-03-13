# AOQuery

*(under development!)*

Workflow for processing AOQuery chains

1. Create `aod.api.QueryManager` with one or more HDF5 files. The QueryManager will maintain:
    - ```allGroupNames``` - A list of all group names in the HDF5 files that correspond to entities
    - ```filterIdx``` - Logical array specifying whether each group matches the queries or not. All groups being as `true` and must be eliminated through queries.
    - ```fileIdx``` - Array listing the index of the file each group in ```allGroupNames``` comes from.
    - ```Filters``` - List of all filters in the query, which will be applied in order.

2. Add Filters to `aod.api.QueryManager`. Each filter has a method called `apply()` which performs the following:
   1.  Queries the parent `filterIdx` to ensure previously eliminated groups are not processed (assigned to `localIdx` property).
   2.  Performs the query, setting each entry of `localIdx` to false if it fails the query
   3.  Provides a single output, which is the contents of `localIdx`. 
   4.  Parent object (usually `aod.api.QueryManager`) will then use that output to update it's property `filterIdx`.

3. Filters querying other entities may also have Filters (e.g., `aod.api.ChildFilter`). 