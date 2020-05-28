module DynamicGridsGtk
# Use the README as the module docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) DynamicGridsGtk

using DynamicGrids, 
      Cairo, 
      Gtk, 
      Graphics, 
      FieldDefaults

# Mixins
using DynamicGrids: @Image, @Graphic, @Output

import DynamicGrids: showgrid, isrunning, starttime, initialise

export GtkOutput

abstract type AbstractGtkOutput{T} <: ImageOutput{T} end

"""
    GtkOutput(init::AbstractMatrix; fps=25, store=false,
              processor=ColorProcessor(), extrainit=Dict())

Constructor for GtkOutput.

### Arguments:
- `init::AbstractArray`: initialisation array.

### Keyword Arguments:
- `tspan`: `AbstractRange` timespan for the simulation
- `fps::Real`: frames per second to display the simulation
- `store::Bool`: whether ot store the simulation frames for later use
- `processor`: `GridProcessor` to convert output grid(s) to an image.
- `minval::Number`: minumum value to display in the simulaiton
- `maxval::Number`: maximum value to display in the simulaiton
"""
@Image @Graphic @Output mutable struct GtkOutput{W,C} <: AbstractGtkOutput{T}
    window::W
    canvas::C
end
# Defaults are passed in from ImageOutput constructor
GtkOutput(; frames, init, mask, running, tspan, fps, timestamp, stampframe, store, 
          processor, minval, maxval, canvas=newcanvas(), window=newwindow(canvas), kwargs...) = begin
    output = GtkOutput(
        frames, init, mask, running, tspan, fps, timestamp, stampframe, store, 
        processor, minval, maxval, window, canvas
    )
    initialise(output)
end

window(o) = o.window
canvas(o) = o.canvas

newwindow(canvas) = Gtk.Window(canvas, "DynamicGrids Gtk Ouput")
newcanvas() = Gtk.@GtkCanvas()

DynamicGrids.initialise(o::AbstractGtkOutput) = begin
    o.running && return o
    if !isalive(o)
        o.canvas = newcanvas()
        o.window = newwindow(o.canvas) 
    end
    canvas(o).mouse.button1press = (widget, event) -> o.running = false
    show(canvas(o))
    showgrid(o, 1, starttime(o))
    return o
end

isalive(o::AbstractGtkOutput) = canvas(o).is_realized

DynamicGrids.isrunning(o::AbstractGtkOutput) = begin
    o.running && isalive(o)
end

DynamicGrids.showimage(image::AbstractArray, o::AbstractGtkOutput, f, t) = begin
    # Cairo shows images permuted
    img = permutedims(image)
    Gtk.@guarded Gtk.draw(canvas(o)) do widget
        ctx = Gtk.getgc(canvas(o))
        Cairo.image(ctx, Cairo.CairoImageSurface(img), 0, 0,
                    Graphics.width(ctx), Graphics.height(ctx))
    end
end

DynamicGrids.isasync(o::AbstractGtkOutput) = false

Base.display(o::AbstractGtkOutput) =
    if !isalive(o)
        initialise(o)
    end

end
