MATLAB code for reading and writing CIFTI files, v2, alpha testing
==================================================================

This code is intended to be fully compatible with the CIFTI-2 format,
without external dependencies (except that cifti-1 files require
wb_command for conversion), returning a matlab structure that exposes
the information contained in the cifti XML with minimal translation, as
well as the data matrix with no added padding.

Additionally, it provides numerous helper functions to make many common
operations (such as extracting the data for one structure) into a single
line of intuitive code.

The previous code that was derived from FieldTrip is in the "ft_cifti"
folder.

Currently, the cifti structure returned by this library uses 0-based
indices for vertex and voxel indices, 1-based for cifti indices, and
the helper functions return 1-based indices for everything.  Be aware
that this library is in alpha testing, and conventions such as this may
change.
