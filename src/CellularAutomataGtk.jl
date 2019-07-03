module CellularAutomataGtk

using CellularAutomataBase, Cairo, Gtk, Images, Graphics

# Mixins
using CellularAutomataBase: @ImageProc, @FPS, @Output, frametoimage

import CellularAutomataBase: showframe, isrunning

export GtkOutput

abstract type AbstractGtkOutput{T} <: AbstractOutput{T} end

"""
Shows output live in a Gtk window.
"""
@ImageProc @FPS @Output mutable struct GtkOutput{W,C} <: AbstractGtkOutput{T}
    window::W
    canvas::C
end

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
GtkOutput(frames::AbstractVector; fps=25, showfps=fps, store=false, processor=GreyscaleProcessor()) = begin
    timestamp = 0.0; tref = 0; tlast = 1; running = false

    canvas = Gtk.@GtkCanvas()
    window = Gtk.Window(canvas, "Cellular GtkOuput")
    show(canvas)
    output = GtkOutput(frames[:], running, fps, showfps, timestamp, tref, tlast, store,
                       processor, window, canvas)

    canvas.mouse.button1press = (widget, event) -> output.running = false
    showframe(output, 1)
    output
end

CellularAutomataBase.isrunning(o::GtkOutput) = o.running && o.canvas.is_realized

CellularAutomataBase.showframe(o::AbstractGtkOutput, frame::AbstractArray, t) = begin
    # Cairo shows images permuted
    img = permutedims(frametoimage(o, frame, t))
    println(t)
    Gtk.@guarded Gtk.draw(o.canvas) do widget
        ctx = Gtk.getgc(o.canvas)
        Cairo.image(ctx, Cairo.CairoImageSurface(img), 0, 0,
                    Graphics.width(ctx), Graphics.height(ctx))
    end
end

end
