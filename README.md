FESTUNG
======
**FESTUNG** (Finite Element Simulation Toolbox for Unstructured Grids) is a Matlab / GNU Octave toolbox for the discontinuous Galerkin method on unstructured grids. It is primarily intended as a fast and flexible prototyping platform and testbed for students and developers. 

FESTUNG relies on fully vectorized matrix/vector operations to deliver optimized computational performance combined with a compact, user-friendly interface and a comprehensive documentation.

## Download
* Tarballs of the code and further information about the project can be found on our [Project page](https://math.fau.de/FESTUNG).
* The latest development versions can always be downloaded from the [Github repository](https://github.com/FESTUNG/project).

## Usage
To check out the latest development version, run `git clone https://github.com/FESTUNG/project.git`

Have a look at the script file `main.m`, where parameters for the computation are set and the algorithm is implemented. In MATLAB / GNU Octave, run 

    $ main

to start the computation.

Output files are written in [VTK format](http://www.vtk.org/VTK/img/file-formats.pdf) and can be visualized, e.g., using [Paraview](http://www.paraview.org/)

## Development
When developing code for or with FESTUNG we suggest to stick to the [Naming Convention](NAMING_CONVENTION.md) to allow for better readability and a similar appearance of all code parts.

## Contributors

FESTUNGs main developers are Florian Frank (Rice University), [Balthasar Reuter](https://math.fau.de/reuter), and [Vadym Aizinger](https://math.fau.de/aizinger). Its initial release was developed at the [Chair for Applied Mathematics I](https://www.mso.math.fau.de/applied-mathematics-1.html) at [Friedrich-Alexander-University Erlangen-Nürnberg](https://www.fau.eu).

### Third party libraries
* FESTUNG makes extensive use of the built-in routines in MATLAB / GNU Octave.
* [triquad](https://github.com/FESTUNG/project/blob/master/triquad.m) was written by Greg von Winckel. See [triquad.txt](https://github.com/FESTUNG/project/blob/master/triquad.txt) for license details.
* [m2cpp.pl](https://github.com/FESTUNG/project/blob/master/thirdParty/doxygenMatlab/m2cpp.pl) by Fabrice to generate a [Doxygen](http://www.stack.nl/~dimitri/doxygen/) documentation. See [license.txt](https://github.com/FESTUNG/project/blob/master/thirdParty/doxygenMatlab/license.txt) for license details.

## License 
* see [LICENSE](https://github.com/FESTUNG/project/blob/master/LICENSE) file

## Version 
* Version 0.1 as published in the paper *Frank, Reuter, Aizinger, Knabner:* "FESTUNG: A MATLAB / GNU Octave toolbox for the discontinuous Galerkin method. Part I: Diffusion operator". *In: Computers & Mathematics with Applications 70 (2015) 11-46, Available online 15 May 2015, ISSN 0898-1221, http://dx.doi.org/10.1016/j.camwa.2015.04.013.*

## Contact
* Homepage: [https://math.fau.de/FESTUNG](https://math.fau.de/FESTUNG)
