# Specification package notes

*Still under development*

Known quirks about MATLAB's `meta.property` as a form of specification:
- Some user-defined classes will retain a previous value when set as a class type
- If the description starts with the property name, the property name will be removed.
- If size is specified, the property cannot be empty (this is a big gap). Would like to have two separate specifiers:
  - IsRequired
  - Size