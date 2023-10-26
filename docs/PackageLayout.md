# AOData Package

This is the standard folder organization for a custom AOData package:

- `+lab`
    - `+user`
      - `+analyses`
      - `+calibrations`
      - `+channels`
      - `+devices`
      - `+epochs`
      - `+epochdatasets`
      - `+experiments`
      - `+experimentdatasets`
      - `+factories`
      - `+modules`
      - `+protocols`
      - `+readers`
      - `+registrations`
      - `+responses`
      - `+sources`
      - `+stimuli`
      - `+systems`

There is one subpackage per entity type along with the following:
- `+factories` - classes that streamline creation of common entities
- `+modules` - code that can be accessed by both the core and persistent interface
- `+readers` - specialized file readers for importing data into MATLAB
- `+protocols` - templates for creating stimuli or imaging paradigms used during an experiment