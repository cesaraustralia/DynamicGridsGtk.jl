# DynamicGridsGtk

[![Build Status](https://travis-ci.org/cesaraustralia/DynamicGridsGtk.jl.svg?branch=master)](https://travis-ci.org/cesaraustralia/DynamicGridsGtk.jl) 
[![codecov.io](http://codecov.io/github/cesaraustralia/DynamicGridsGtk.jl/coverage.svg?branch=master)](http://codecov.io/github/cesaraustralia/Cellular.jl?branch=master) 

Provides a GTK interface for visualising simulations with [DynamicGrids.jl](https://github.com/cesaraustralia/DynamicGrids.jl) and packages that build on it like [Dispersal.jl](https://github.com/cesaraustralia/Dispersal.jl). 

To create a Gtk window for use as a simulation output:

```julia
using DynamicGridsGtk
output = GtkOutput(init; fps=25, showfps=fps, store=false, processor=ColorProcessor())
```

Where `init` is the initialisation array for the simulation, and processor can
be any `FrameProcessor` from DynamicGrids.jl. Keyword arguments are
optional, with defaults shown above.

## Documentation

See the documentation for [DynamicGrids.jl](https://cesaraustralia.github.io/DynamicGrids.jl/dev/)

Note: using Gtk on Windows will lead to very slow performance of the REPL and
IDEs like Atom. Use DynamicGridsInteract instead.
