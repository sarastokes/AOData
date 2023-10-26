## AOData Change Log

*Development notes - work in progress*

Each entity change is logged with the *UUID* and the *hdfPath*. In addition, the following is recorded to fully document the change:

When an <u>entity</u> changes:
- **Added** - *name*, *UUID*
- **Renamed** - *name*, *oldName*
- **Removed** - *name*
- **Replaced** - *newUUID*, *oldUUID*

When an <u>attribute</u> changes:
- **Removed** - *name*
- **Added** - *name*
- **Set** - *name*
- **Renamed** - *name*, *oldName*

When a <u>dataset</u> changes:
- **Removed** - *name*
- **Set** - *name*
- **Added** - *name*
- **Renamed** - *name*, *oldName*

When a specification (<u>expected dataset</u>) changes:
- **Changed** - *name*, *field*
- **Retyped** - *name*, *newType*