using DynamicGrids, DynamicGridsGtk, Gtk, Test, Colors, ColorSchemes

# life glider sims

init =  [0 0 0 0 0 0
         0 0 0 0 0 0
         0 0 0 0 0 0
         0 0 0 1 1 1
         0 0 0 0 0 1
         0 0 0 0 1 0]

test =  [0 0 0 0 0 0
         0 0 0 0 0 0
         0 0 0 0 1 1
         0 0 0 1 0 1
         0 0 0 0 0 1
         0 0 0 0 0 0]

test2 = [0 0 0 0 0 0
         0 0 0 0 0 0
         1 0 0 0 1 1
         1 0 0 0 0 0
         0 0 0 0 0 1
         0 0 0 0 0 0]


@testset "Simulation" begin

    ruleset = Ruleset(Life(); init=init, overflow=WrapOverflow())

    @testset "converted results from ArrayOutput match glider behaviour" begin
        output = ArrayOutput(init, 5)
        sim!(output, ruleset; tspan=(1, 5))
        output2 = GtkOutput(output)
        @test output2[3] == test
        @test output2[5] == test2
        destroy(output2.window)
    end

    @testset "GtkOutput stored simulation matches glider behavior" begin
        # TODO test Gtk canvas image
        # g0 = RGB24(0)
        # g1 = RGB24(1)
        # grey2 = [g0 g0 g0 g0 g0 g0
        #          g0 g0 g0 g0 g0 g0
        #          g1 g0 g0 g0 g1 g1
        #          g1 g0 g0 g0 g0 g0
        #          g0 g0 g0 g0 g0 g1
        #          g0 g0 g0 g0 g0 g0]

        # l0 = get(ColorSchemes.leonardo, 0)
        # l1 = get(ColorSchemes.leonardo, 1)

        # leonardo2 = [l0 l0 l0 l0 l0 l0
        #              l0 l0 l0 l0 l0 l0
        #              l1 l0 l0 l0 l1 l1
        #              l1 l0 l0 l0 l0 l0
        #              l0 l0 l0 l0 l0 l1
        #              l0 l0 l0 l0 l0 l0]
        
        output = GtkOutput(init; store=true)
        sim!(output, ruleset; tspan=(1, 2))
        resume!(output, ruleset; tstop=5)
        @test output[3] == test
        @test output[5] == test2
        # TODO @test the canvaas images == leonardo2
        destroy(output.window)
        @testset "display" begin
            @test DynamicGridsGtk.isalive(output) == false
            display(output)
            @test DynamicGridsGtk.isalive(output) == true
            destroy(output.window)
            @test DynamicGridsGtk.isalive(output) == false
        end
    end
end


@testset "Float output" begin

    flt = [0.0 0.0 0.0 0.1 0.0 0.0
           0.0 0.3 0.0 0.0 0.6 0.0
           0.2 0.0 0.2 0.1 0.0 0.6
           0.0 0.0 0.0 1.0 1.0 1.0
           0.0 0.3 0.3 0.7 0.8 1.0
           0.0 0.0 0.0 0.0 1.0 0.6]

    int = [0 0 0 0 0 0
           0 0 0 0 0 0
           0 0 0 0 0 0
           0 0 0 1 1 1
           0 0 0 0 0 1
           0 0 0 0 1 0]

    @testset "GtkOutput works" begin
        output = GtkOutput(int)
        DynamicGrids.showgrid(output, 1)
        Gtk.destroy(output.window)

        output = GtkOutput(flt)
        DynamicGrids.showgrid(output, 1)
        Gtk.destroy(output.window)
    end
end
