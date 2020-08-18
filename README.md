MATLAB code for reading and writing CIFTI files, v2, alpha testing
==================================================================

This code is intended to be fully compatible with the CIFTI-2 format,
without external dependencies (except that CIFTI-1 files require
wb_command for conversion), returning a structure that exposes the
information contained in the CIFTI-2 XML with minimal translation, as well
as the data matrix with no added padding.  The read_cifti function is
the intended starting point, ciftiopen and similar are compatibility
wrappers so that the library can be used in older code.

Additionally, the library provides numerous helper functions to make many
common operations (such as extracting the data for one structure) into a
single line of intuitive code.

The previous code that was derived from FieldTrip is in the "ft_cifti"
folder.

Currently, the cifti structure returned by this library uses 0-based
indices for vertex and voxel indices, 1-based for cifti indices, and
the helper functions return 1-based indices for everything.  Be aware
that this library is in alpha testing, and conventions such as this may
change.

# Usage
All exposed functions have usage information available through the `help` command:

```
>> help read_cifti
 function outstruct = read_cifti(filename, ...)
    Read a cifti file.
...
```

The simplest practical usage is to load a cifti file with `read_cifti`, take
its data from the `.cdata` field, modify it, store it back into the `.cdata` field,
and write it back out to a new file with `write_cifti`:

```octave
mycifti = read_cifti('something.dscalar.nii');
mycifti.cdata = sqrt(mycifti.cdata);
write_cifti(mycifti, 'sqrt.dscalar.nii');
```

The `ciftiopen`, `ciftisave`, and `ciftisavereset` functions provide backward
compatibility with a previous cifti library (option B of [HCP FAQ 2](https://wiki.humanconnectome.org/display/PublicData/HCP+Users+FAQ#HCPUsersFAQ-2.HowdoyougetCIFTIfilesintoMATLAB?)),
and you can also use this `ciftisavereset` function even if you use `read_cifti`.
An alternative way to do the equivalent of `ciftisavereset` is to use the
`cifti_file_create_from_template` helper function (which has an option to set
the names of the maps):

```octave
mycifti = read_cifti('something.dscalar.nii');

write_cifti(cifti_file_create_from_template(mycifti, mycifti.cdata(:, 1), 'dscalar', 'namelist', {'map #1'}), 'firstmap.dscalar.nii');
%ciftisave equivalent (keeping mycifti unmodified):
newcifti = mycifti;
newcifti.cdata = mycifti.cdata(:, 1);
ciftisavereset(newcifti, 'firstmap.dscalar.nii');
clear newcifti;
```

The `cifti_file_*` helper functions should handle most cases of working with
common cifti files, including extracting the data for one cortical surface,
doing some computation on it, and replacing the surface data with the new values:

```octave
mycifti = read_cifti('something.dscalar.nii');
leftdata = cifti_file_dense_extract_surface_data(mycifti, 'CORTEX_LEFT');
newleftdata = 1 - leftdata;
newcifti = cifti_file_dense_replace_surface_data(mycifti, newleftdata, 'CORTEX_LEFT');
```

The `cifti_diminfo_*` helpers are lower-level and require more understanding of the
internals of the cifti format, so you should generally look at the `cifti_file_*`
helpers first.
