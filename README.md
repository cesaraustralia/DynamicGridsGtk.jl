# CellularAutomataGtk

[![Build Status](https://travis-ci.org/rafaqz/CellularAutomataGtk.jl.svg?branch=master)](https://travis-ci.org/rafaqz/CellularAutomataGtk.jl) 
[![codecov.io](http://codecov.io/github/rafaqz/CellularAutomataGtk.jl/coverage.svg?branch=master)](http://codecov.io/github/rafaqz/Cellular.jl?branch=master) 

Provides a GTK interface for visualising simulations with CellularAutomataBase.jl
and packages that build on it like Dispersal.jl. 

To use:

```julia
using CellularAutomataGtk
GtkOutput(init; fps=25, showfps=fps, store=false, processor=GreyscaleProcessor())
```

Where init is the init array for the simulation. All keyword arguments are
optional, with defaults shown above.

## Documentation

See the documentation for [CellularAutomataBase.jl](https://rafaqz.github.io/CellularAutomataBase.jl/dev/)
