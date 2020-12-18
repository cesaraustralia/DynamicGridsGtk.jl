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

### Arguments:
- `init::AbstractArray`: initialisation array.

### Keyword Arguments:
- `tspan`: `AbstractRange` timespan for the simulation
- `fps::Real`: frames per second to display the simulation
- `store::Bool`: whether to store the simulation frames for later use
- `processor`: `GridProcessor` to convert output grid(s) to an image.
- `minval::Number`: minumum value to display in the simulaiton
- `maxval::Number`: maximum value to display in the simulaiton
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
# Defaults are passed in from ImageOutput constructor
function GtkOutput(; 
    frames, running, extent, graphicconfig, imageconfig,
    canvas=_newcanvas(), window=_newwindow(canvas), kwargs...
)
    GtkOutput(frames, running, extent, graphicconfig, imageconfig, window, canvas) |> _initialise
end

window(o) = o.window
canvas(o) = o.canvas

_newwindow(canvas) = Gtk.Window(canvas, "DynamicGrids Gtk Output")
_newcanvas() = Gtk.@GtkCanvas()

DG.isrunning(o::AbstractGtkOutput) = o.running && _isalive(o)
DG.isasync(o::AbstractGtkOutput) = false
DG.initialisegraphics(o::AbstractGtkOutput, data::DG.AbstractSimData) = begin
    _initialise(o)
    DG.showframe(o, data)
end
DG.showimage(image::AbstractArray, o::AbstractGtkOutput, data::DG.AbstractSimData) = begin
    # Cairo shows images permuted
    img = permutedims(image)
    Gtk.@guarded Gtk.draw(canvas(o)) do widget
        ctx = Gtk.getgc(canvas(o))
        Cairo.image(ctx, Cairo.CairoImageSurface(img), 0, 0,
                    Graphics.width(ctx), Graphics.height(ctx))
    end
end

Base.display(o::AbstractGtkOutput) =
    if !_isalive(o)
        _initialise(o)
    end


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
