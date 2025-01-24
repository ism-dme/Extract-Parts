## Version History

### 5.1.1 (2025-01-24)
- Update test data
- Update documentation


### 5.1.0 (2024-12-11)
- Accept string as input for `$P_PARAMETERS` (#108)
- #bugfix https://gitlab.mozarteum.at/dme/dime/tools/extract-parts/-/issues/74#note_8114 
- Add `$P_LIB_PATH` (#109)

### 5.0.0 (2024-11-21)
- ControlEvents that points to an Event nested in app/choice (#92)
- ConrolEvents nested in choice/app/supplied (#74)
- Update allPartsRequested for split (#88)
- controlEvents that are attached to one layer only (#89)
- controlEvents that apply to a split stave (@tstamp) (#93)
- Update controlEvent@staff when renumberStaves (#91)
- Refactoring of controlEvents.xsl (#94)
- @type=staff (#85)
- Mandatory @layer attribute (#96)
- Develop add-missing-layers utility (#106)
- Processing sb/pb (#98)

### 4.2.0 (2024-10-02)
- Split <staff> (#87)
- #bugfix: processing of ControlEvents, when one staff has `mei:mRest` (#86)
- Enhance parameter configuration (#80) 

### 4.1.0 (2024-09-17)
- Communicate "split" (#82)
- Renumber `<staff>`s (#73)
- Implement 'renumberStaves' parameter (#84)
- Adjust `scoreDef@xml:id` (#72)
- Split staffDef (#77)
- Implement staffDef@label (#83)
- Move @decls (#81)
- Implement 'renumberStaves' parameter (#84)
- Update unit tests with new parameters syntax (#79)

### 4.0.0 (2024-08-28)
- Changed parameter format for defining staves and layers to extract from string to XML (#3).
- Large refactoring of the code base (#10, #15, #17, #18, #19).

### 3.1.0 (2024-07-08)
- Set up extract-parts as a separate project (dme/dime/project-management/#38).
- Moved documentation to Markdown.
- Made output path configurable (#2).

### 3.0.0 (2024-01-24)
- Implemented the usage of `instruments.xml` to find instrument names.
- Added parameter `P_LANGUAGE`.
- Created a new mechanism for generating instrument names and abbreviations (#95).
- If instruments of different groups are present, do not include integers in the `<label>` (#92).
- Changed the logic to reflect the updated guidelines for `<dir>` (#118).

### 2.0.0 (2023-12-05)
- When extracting a `<layer>`, delete the `@layer` attribute for `controlEvents` with `@tstamp` (#103).
- Handle dynamics for asynchronous Events (#75).
- For dirs 'a 2' and 'Solo', preserve `@place=above` (#72).
- Added a feature for creating `<multiRest>`s (#68).

### 1.5.1 (2023-10-31)
- `tempo|dir|fermata@part=%all` (#66).
- A requested `staff@n` which does not exist (#102).

### 1.5.0 (2023-10-11)
- Convert `mSpace` and `space` to `mRest` and `rest` respectively (#40).
- #bugfix: adding of `xmlns:ns0` to the copied nodes and attributes (#99).
- Improved fermata handling: swap `@startid`, delete `@layer`, `*@sameas`, `@tstamp` (#96, #97, #74, #98).

### 1.4.1 (2023-09-27)
- Delete `tempo@part="%all"` if only one part is extracted (#76).

### 1.4.0 (2023-08-29)
- When extracting a single part, delete visual information such as `@ploc`/`@oloc` for rests and `@stem.sameas`/`@stem.dir` for notes (#83).
- Implemented resolving of `@startid`/`@endid` for `beam@sameas` descendants (#39).
- Updated documentation.

### 1.3.0 (2023-08-02)
- Included requested parts in the output file name.
- Improved handling of cases when all or no parts are requested.

### 1.2.0 (2023-07-31)
- `staffDef@symbol` (#8).
- Implemented the case when all parts are selected for extraction.

### 1.1.2 (2023-07-17)
- Refactoring and optimization.
- Added unit tests for `<scoreDef>` and minimal running examples.

### 1.1.1 (2020-08-20)
- Added configuration file for options.

### 1.1.0 (2020-03-04)
- Changed logic for the mode `extractLayer` due to deprecated encoding guidelines for beamed notes.
- Original `@doxml:id`s are preserved, except for children of the `@sameas` elements.

### Previous Versions

- 2019-12-16: _1.0.2_
- 2019-11-22: _1.0.1_
- 2019-10-24: _1.0.0_