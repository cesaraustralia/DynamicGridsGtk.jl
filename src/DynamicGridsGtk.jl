module DynamicGridsGtk
# Use the README as the module docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) DynamicGridsGtk

using DynamicGrids, Cairo, Gtk, Images, Graphics, Colors, FieldDefaults

# Mixins
using DynamicGrids: @Image, @Graphic, @Output

import DynamicGrids: showframe, isrunning

export GtkOutput

abstract type AbstractGtkOutput{T} <: AbstractImageOutput{T} end

"""
    GtkOutput(init)

Constructor for GtkOutput.

### Arguments:
- `frames::AbstractVector`: Vector of frames
- `args`: any additional arguments to be passed to the model rule

### Keyword Arguments:
- `fps`: frames per second
- `showfps`: maximum displayed frames per second
"""
@Image @Graphic @Output mutable struct GtkOutput{W,C} <: AbstractGtkOutput{T}
    window::W | nothing
    canvas::C | nothing
end
window(o) = o.window
canvas(o) = o.canvas

GtkOutput(frames::T, running::Bool, starttime::Any, stoptime::Any, fps::FPS, showfps::SFPS, 
          timestamp::TS, stampframe::SF, store::Bool, processor::P, minval::Mi, maxval::Ma, 
          window, canvas) where {T<:AbstractVector,FPS,SFPS,TS,SF,P,Mi,Ma} = begin
    canvas = Gtk.@GtkCanvas()
    window = Gtk.Window(canvas, "DynamicGrids Gtk Ouput")
    output = GtkOutput{T,FPS,SFPS,TS,SF,P,Mi,Ma,typeof(window),typeof(canvas)}(
                 frames[:], running, starttime, stoptime, fps, showfps, timestamp,
                 stampframe, store, processor, minval, maxval, window, canvas)

    canvas.mouse.button1press = (widget, event) -> output.running = false
    show(canvas)
    output
end


DynamicGrids.isrunning(o::AbstractGtkOutput) = o.running && o.canvas.is_realized

DynamicGrids.showframe(image::AbstractArray{RGB24,2}, o::AbstractGtkOutput, f) = begin
    # Cairo shows images permuted
    img = permutedims(image)
    println(f)
    Gtk.@guarded Gtk.draw(canvas(o)) do widget
        ctx = Gtk.getgc(canvas(o))
        Cairo.image(ctx, Cairo.CairoImageSurface(img), 0, 0,
                    Graphics.width(ctx), Graphics.height(ctx))
    end
end

DynamicGrids.isasync(o::GtkOutput) = false

end
