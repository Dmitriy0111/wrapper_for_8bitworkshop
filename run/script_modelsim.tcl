
vlib work

#set test "test_hvsync_tb"
set test "racing_game_tb"

if {$test == "test_hvsync_tb"} {

    set i0 +incdir+../../fpga-examples/ice40
    set i1 +incdir+../tb

    set s0 ../../fpga-examples/ice40/test_hvsync.v
    set s1 ../../fpga-examples/ice40/hvsync_generator.v
    set s2 ../tb/test_hvsync_tb.*v

    vlog $i0 $i1 $s0 $s1 $s2

    vsim -novopt work.test_hvsync_tb
    add wave -position insertpoint sim:/test_hvsync_tb/*

} elseif {$test == "racing_game_tb"} {

    set i0 +incdir+../../fpga-examples/ice40
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../../fpga-examples/ice40/hvsync_generator.v
    set s1 ../../fpga-examples/ice40/sprite_bitmap.v
    set s2 ../../fpga-examples/ice40/sprite_renderer.v
    set s3 ../../fpga-examples/ice40/racing_game.v
    set s4 ../rtl/wrapper_racing_game.v
    set s5 ../tb/racing_game_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3 $s4 $s5

    vsim -novopt work.racing_game_tb
    add wave -position insertpoint sim:/racing_game_tb/*
    add wave -position insertpoint sim:/racing_game_tb/wrapper_racing_game_0/racing_game_top_0/*

}
#} elseif {$test == "test_hvsync_tb"} {
#    vsim -novopt work.test_hvsync_tb
#}

run -all

wave zoom full

#quit
