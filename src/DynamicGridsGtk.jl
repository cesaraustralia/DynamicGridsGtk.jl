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
    GtkOutput(init; kw...)

Constructor for GtkOutput.

# Arguments

- `init`: initialisation `AbstractArray` or `NamedTuple` of `AbstractArray`

# Keywords

#### `DynamicGrids.Extent` keywords:

$(DynamicGrids.EXTENT_KEYWORDS)

An `Extent` object can be also passed to the `extent` keyword, and other keywords will be ignored.

#### `DynamicGrids.GraphicConfig` keywords:

$(DynamicGrids.GRAPHICCONFIG_KEYWORDS)

A `GraphicConfig` object can be also passed to the `graphicconfig` keyword, and other keywords will be ignored.

#### `DynamicGrids.ImageConfig` keywords:

$(DynamicGrids.IMAGECONFIG_KEYWORDS)

An `ImageConfig` object can be also passed to the `imageconfig` keyword, and other keywords will be ignored.
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
