# DynamicGridsGtk

[![Build Status](https://travis-ci.org/cesaraustralia/DynamicGridsGtk.jl.svg?branch=master)](https://travis-ci.org/cesaraustralia/DynamicGridsGtk.jl) 
[![codecov.io](http://codecov.io/github/cesaraustralia/DynamicGridsGtk.jl/coverage.svg?branch=master)](http://codecov.io/github/cesaraustralia/Cellular.jl?branch=master) 

Provides a GTK interface for visualising simulations with DynamicGrids.jl
and packages that build on it like Dispersal.jl. 

To use:

```julia
using DynamicGridsGtk
GtkOutput(init; fps=25, showfps=fps, store=false, processor=GreyscaleProcessor())
```

Where init is the init array for the simulation. All keyword arguments are
optional, with defaults shown above.

## Documentation

See the documentation for [DynamicGrids.jl](https://cesaraustralia.github.io/DynamicGrids.jl/dev/)
