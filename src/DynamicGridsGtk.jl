module DynamicGridsGtk
# Use the README as the module docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) DynamicGridsGtk

using DynamicGrids,
      Cairo,
      Gtk,
      Graphics

const DG = DynamicGrids

export GtkOutput


abstract type AbstractGtkOutput{T,F} <: ImageOutput{T,F} end

"""
    GtkOutput(init::AbstractMatrix; fps=25, store=false,
              processor=ColorProcessor(), extrainit=Dict())

Constructor for GtkOutput.

# Arguments

- `init::AbstractArray`: initialisation array.

# Keywords

- `tspan`: `AbstractRange` timespan for the simulation
- `aux`: NamedTuple of arbitrary input data. Use `get(data, Aux(:key), I...)` 
    to access from a `Rule` in a type-stable way.
- `mask`: `BitArray` for defining cells that will/will not be run.
- `padval`: padding value for grids with neighborhood rules. The default is `zero(eltype(init))`.
- `font`: `String` font name, used in default `TextConfig`. A default will be guessed.
- `text`: `TextConfig` object or `nothing` for no text.
- `scheme`: ColorSchemes.jl scheme, or `Greyscale()`.
- `renderer`: `Renderer` such as `Layout` or `Image`.
- `minval`: minimum value(s) to set colour maximum.
- `maxval`: maximum values(s) to set colour minimum.
"""
mutable struct GtkOutput{T,F<:AbstractVector{T},E,GC,IC,W,C} <: AbstractGtkOutput{T,F}
    frames::F
    running::Bool
    extent::E
    graphicconfig::GC
    imageconfig::IC
    window::W
    canvas::C
end
function GtkOutput(; 
    # Defaults are passed in from the generic ImageOutput constructor
    frames, running, extent, graphicconfig, imageconfig,
    canvas=_newcanvas(), window=_newwindow(canvas), kwargs...
)
    GtkOutput(frames, running, extent, graphicconfig, imageconfig, window, canvas) |> _initialise
end

# Getters
window(o) = o.window
canvas(o) = o.canvas

# DynamicGrids Output/GraphicOutput/ImageOutput interface
DG.isrunning(o::AbstractGtkOutput) = o.running && _isalive(o)
DG.isasync(o::AbstractGtkOutput) = false
function DG.initialisegraphics(o::AbstractGtkOutput, data::DG.AbstractSimData)
    _initialise(o)
    DG.showframe(o, data)
end
function DG.showimage(image::AbstractArray, o::AbstractGtkOutput, data::DG.AbstractSimData)
    # Cairo shows images permuted
    img = permutedims(image)
    Gtk.@guarded Gtk.draw(canvas(o)) do widget
        ctx = Gtk.getgc(canvas(o))
        Cairo.image(ctx, Cairo.CairoImageSurface(img), 0, 0,
                    Graphics.width(ctx), Graphics.height(ctx))
    end
end

# Base interface
Base.display(o::AbstractGtkOutput) = _isalive(o) || _initialise(o)

# Local methods
_newwindow(canvas) = Gtk.Window(canvas, "DynamicGrids Gtk Output")
_newcanvas() = Gtk.@GtkCanvas()

_isalive(o::AbstractGtkOutput) = canvas(o).is_realized

function _initialise(o::AbstractGtkOutput)
    o.running && return o
    if !_isalive(o)
        o.canvas = _newcanvas()
        o.window = _newwindow(o.canvas)
    end
    canvas(o).mouse.button1press = (widget, event) -> DG.setrunning!(o, false)
    show(canvas(o))
    return o
end

end
