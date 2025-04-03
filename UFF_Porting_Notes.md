# What can be learned from porting the UFF file format to Julia 

## Obvious struggle with OOP paradigm
- All of USTB is based upon objects
- Strongly apparent in the UFF fileformat code
- Julia is not an OOP language
    - This might also be a problem for porting to other languages
- UFF fileformat code is not very modular
- Currently, all UFF structs inherit from a base UFF struct
    - This is not very useful, as the base struct is never used
    - This is a clear sign of the OOP paradigm
    - This is not very useful for porting to other languages
    - Saving the structs to file carry along unused data
    - Why does the Scan defined in a data need to have a reference
    to the author and the version of the UFF file format, if the 
    base object written to the UFF file also has this information?

### What could be done?
- Decouple the UFF fileformat from relying on objects
- Have clear spesifications of structures which are passed around
- Allow for modular code by limiting wrapping of functions in objects
- For publication and creditability, a "Header" struct containing
    information about the UFF file is a solution, and would decouple
    the redundant information from the data.

## Scan Structure
The scan structure is a very important part of the UFF fileformat,
as it defines the pixel space for the data. However, since this
class only contains data, it is not very useful to wrap it in an
object.

### Current approach
- Currently, there are 5 different scan structures, all of which
    inherit from the base Scan class.
- The scans are used solely for the purpose of defining the pixel
    space of the data, which is not a very object oriented task.
- All child classes of Scan only contain additional properties to
    help define how this pixel space is created. 
- Once created, the defining properties are irrelevant.

### What could be done?
- Remove the Scan class and have a single scan structure
    containing the pixel space
- For Matlab and other OOP languages, the current approach
    is definitely the way to go, but to generalize the UFF format,
    requireing the use of only one scan structure is the way to go.
- For Non-OOP languages, the current approach is not possible,
    and the scan structure should be defined as a structure
    containing the pixel space.
    - Inherited classes can be defined by composition, where an
    internal Scan-structure is updated based on properties of the
    inherited class.
    - The composite structs should never be written to file, only
    the composed Scan-structure.
    - Any functions or processes which require a scan, should never
    require a composite struct, only the Scan-structure.
    - A conversion from a composite struct to a Scan-struct is
    trivial, and would allow for the use of the same functions on
    both the Scan and composite structs.

### Specific implications
- In OOP languages, a Scan-inherited class is created which in-turn
    creates the pixel space defined in the Scan class.
    - When writing this object, only the Scan-class properties
    should be written.
    - Processes or functions built upon scans, should only require
    the base Scan class, not any wrapper.
    - Functions which require a specific scan type, should be able
    to differentiate between the different scan types based on
    pixel properties.
- In Non-OOP languages, a Scan can then be created by defining the
    pixel space and then passing it to the function which requires
    it.
    - This is the same as the current approach, but without the
    Scan class.
    - This would decouple the UFF fileformat from the OOP paradigm.


## UFF Reading
- Reading UFF relies on the OOP paradigm
- Constructing objects when reading uses metaprogramming
    - This is a bad approach as it does not guarantee that the
    data contained in the UFF file is valid.
    - Adding features to the UFF fileformat is simple due to
    the metaprogramming, but this is not a good approach.
    - Changes between versions of the UFF fileformat would 
    require special cases in the metaprogramming.
    - The metaprogramming is not very readable and porting
    this to other languages requires rewrites.

### What could be done?
- Use more generic functions to read the UFF fileformat
- Do not rely on metaprogramming to interpret the data as classes

### Misc
- Why is there a reference to probe in the Wave struct when there is a probe defined in the compulsory apodization applied to the wave?
    - Yes, it is not guaranteed that the probe in the apodization is an aperture apodization, which means the probe is not set in the apodization, but the apodization given to the Wave struct is must be a aperture apodization, no?

