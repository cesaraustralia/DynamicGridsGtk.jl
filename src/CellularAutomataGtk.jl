module CellularAutomataGtk

using CellularAutomataBase, Cairo, Gtk, Images, Graphics, Colors

# Mixins
using CellularAutomataBase: @ImageProc, @Graphic, @Output

import CellularAutomataBase: showframe, isrunning

export GtkOutput

abstract type AbstractGtkOutput{T} <: AbstractImageOutput{T} end

"""
Shows output live in a Gtk window.
"""
@ImageProc @Graphic @Output mutable struct GtkOutput{W,C} <: AbstractGtkOutput{T}
    window::W
    canvas::C
end

window(o) = o.window
canvas(o) = o.canvas

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

CellularAutomataBase.isrunning(o::AbstractGtkOutput) = o.running && o.canvas.is_realized

CellularAutomataBase.showframe(image::AbstractArray{RGB24,2}, o::AbstractGtkOutput, t) = begin
    # Cairo shows images permuted
    img = permutedims(image)
    println(t)
    Gtk.@guarded Gtk.draw(canvas(o)) do widget
        ctx = Gtk.getgc(canvas(o))
        Cairo.image(ctx, Cairo.CairoImageSurface(img), 0, 0,
                    Graphics.width(ctx), Graphics.height(ctx))
    end
end

CellularAutomataBase.showframe(o::GtkOutput, data::CellularAutomataBase.AbstractSimData, t) = begin
    # Cairo shows images permuted
    normed = CellularAutomataBase.normaliseframe(data.ruleset, o[end])
    img = similar(normed, RGB24)
    r = CellularAutomataBase.maxradius(data.ruleset.rules)
    blocksize = 2r
    for i in CartesianIndices(normed)
        blockindex = CellularAutomataBase.indtoblock.((i[1] + r,  i[2] + r), blocksize)
        state = normed[i]
        img[i] = if CellularAutomataBase.sourcestatus(data)[blockindex...]
            if state > 0
                RGB24(state)
            else
                RGB24(0.0, 0.5, 0.5)
            end
        elseif state > 0
            RGB24(1.0, 0.0, 0.0)
        else
            RGB24(0.5, 0.5, 0.0)
        end
    end
    img = permutedims(img)
    println(t)
    Gtk.@guarded Gtk.draw(o.canvas) do widget
        ctx = Gtk.getgc(o.canvas)
        Cairo.image(ctx, Cairo.CairoImageSurface(img), 0, 0,
                    Graphics.width(ctx), Graphics.height(ctx))
    end
end


end
