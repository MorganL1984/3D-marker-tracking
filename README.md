# 3D-marker-tracking
A MATLAB script to track markers from multiple cameras, triangulate to 3D world coordinate using camera calibration, and determine object orientation by matching to known marker locations on a CAD model



## Description

<!--- Provide description of the contents of the code repository   
    * Provide information about what the code does  
    * Provide links for demos, blog posts, etc. (if applicable)  
    * Mention any caveats and assumptions that were considered  
-->  
Codes (run in steps):

STEP01_extract_marker.m: extract marker pixel locations in each camera image, and save to marker_data/[filename]_marker_pos.mat

STEP02_marker_world_coord.m: triangulate marker pixel locations from multiple cameras to 3D world coordinates using pinhole camera model, and save marker world coordinates to marker_data/[filename]_marker_coord.mat

STEP03_image2CAD.m: determine the orientation of the object by matching marker world coordinates to known marker locations

Folders:

pitching_wing_5hz: 100 images of a pitching wing with markers. Each .tiff contains images taken at the same time instance by 3 cameras, stacked vertically. The images are 12-bit.
cam_calib_data: cam_calib.mat contains pinhole camera model parameters for the 3 cameras.

aerofoil_data: .mat file contains ground truth marker location in 3D world coordinate in mm

marker_data: contains intermediate marker pixel location and world coordinate data generated in STEP01 and STEP02.


## History




## Authors or Maintainers

<!--- Provide information about authors, maintainers and collaborators specifying contact details and role within the project, e.g.:   
    * Full name ([@GitHub username](https://github.com/username), [ORCID](https://doi.org/...), email address, institution/employer (role)  
-->
Mogeng (Morgan) Li, https://orcid.org/0000-0002-9875-6468, TU Delft

Images credit: Pere Valls Badia, Octavian Soare, TU Delft



## Requirements  

Developed in MATLAB R2021b



## License

The contents of this repository are licensed under a **Apache License 2.0** license (see LICENSE file).

Copyright notice:  

TU Delft hereby disclaims all copyright interest in the program “3D-marker-tracking”.  

© 2024, M. Li, P. Valls Badia, O. Soare



## References

Singular value decomposition of Wahba's problem:
https://en.wikipedia.org/wiki/Wahba%27s_problem



## Citation

<!--- Make the repository citable 

    * If you will be using the 4TU.ResearchData-Github integration, add the following reference and the DOI of the 4TU.ResearchData repository:

        If you want to cite this repository in your research paper, please use the following information:   
        Reference: [Connecting 4TU.ResearchData with Git](https://data.4tu.nl/info/about-your-data/getting-started)   
-->
