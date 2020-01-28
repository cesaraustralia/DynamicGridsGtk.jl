module DynamicGridsGtk
# Use the README as the module docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) DynamicGridsGtk

using DynamicGrids, Cairo, Gtk, Images, Graphics, Colors, FieldDefaults

# Mixins
using DynamicGrids: @Image, @Graphic, @Output

import DynamicGrids: showgrid, isrunning, starttime

export GtkOutput

abstract type AbstractGtkOutput{T} <: ImageOutput{T} end

"""
    GtkOutput(init::AbstractMatrix, ruleset; fps=25, showfps=fps, store=false,
                   processor=ColorProcessor(), extrainit=Dict())

Constructor for GtkOutput.

### Arguments:
- `init::AbstractArray`: initialisation array.

### Keyword Arguments:
- `fps::Real`: frames per second
- `showfps::Real`: maximum displayed frames per second
- `store::Bool`: store the simulation grids to be used afterwards
- `processor::FrameProcessor
- `minval::Number`: Minumum value to display in the simulaiton
- `maxval::Number`: Maximum value to display in the simulaiton
"""
@Image @Graphic @Output mutable struct GtkOutput{W,C} <: AbstractGtkOutput{T}
    # Field   | Default
    window::W | nothing
    canvas::C | nothing
    GtkOutput(frames::T, running::Bool, starttime::Any, stoptime::Any, fps::FPS, showfps::SFPS,
              timestamp::TS, stampframe::SF, store::Bool, processor::P, minval::Mi, maxval::Ma,
              window, canvas) where {T<:AbstractVector,FPS,SFPS,TS,SF,P,Mi,Ma} = begin
        window, canvas = newwindow()
        output = new{T,FPS,SFPS,TS,SF,P,Mi,Ma,typeof(window),typeof(canvas)}(
                     frames[:], running, starttime, stoptime, fps, showfps, timestamp,
                     stampframe, store, processor, minval, maxval, window, canvas)
        initialise!(output)
    end
end
window(o) = o.window
canvas(o) = o.canvas

newwindow() =  begin
    canvas = Gtk.@GtkCanvas()
    window = Gtk.Window(canvas, "DynamicGrids Gtk Ouput")
    window, canvas
end

initialise!(o::AbstractGtkOutput) = begin
    canvas(o).mouse.button1press = (widget, event) -> o.running = false
    show(canvas(o))
    showgrid(o, 1, starttime(o))
    o
end

isalive(o::AbstractGtkOutput) = canvas(o).is_realized

DynamicGrids.isrunning(o::AbstractGtkOutput) = o.running && isalive(o)

DynamicGrids.showgrid(image::AbstractArray{RGB24,2}, o::AbstractGtkOutput, f, t) = begin
    # Cairo shows images permuted
    img = permutedims(image)
    println("frame: $f at: $t")
    Gtk.@guarded Gtk.draw(canvas(o)) do widget
        ctx = Gtk.getgc(canvas(o))
        Cairo.image(ctx, Cairo.CairoImageSurface(img), 0, 0,
                    Graphics.width(ctx), Graphics.height(ctx))
    end
end

DynamicGrids.isasync(o::GtkOutput) = false

Base.display(o::AbstractGtkOutput) =
    if !isalive(o)
        o.window, o.canvas = newwindow()
        initialise!(o)
    end

end
