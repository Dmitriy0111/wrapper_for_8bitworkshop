
vlib work

#set test "test_hvsync_tb"
#set test "racing_game_tb"
set test "racing_game_cpu_tb"
#set test "spritetest_tb"
#set test "digits10_tb"
#set test "starfield_tb"
#set test "crttest_tb"
#set test "tiletest_tb"
#set test "ball_paddle_tb"

if {$test == "test_hvsync_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../tb

    set s0 ../fpga-examples/test_hvsync.v
    set s1 ../fpga-examples/hvsync_generator.v
    set s2 ../tb/test_hvsync_tb.*v

    vlog $i0 $i1 $s0 $s1 $s2

    vsim -novopt work.test_hvsync_tb
    add wave -position insertpoint sim:/test_hvsync_tb/*

} elseif {$test == "racing_game_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/sprite_bitmap.v
    set s2 ../fpga-examples/sprite_renderer.v
    set s3 ../fpga-examples/racing_game.v
    set s4 ../rtl/wrapper_racing_game.v
    set s5 ../tb/racing_game_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3 $s4 $s5

    vsim -novopt work.racing_game_tb
    add wave -position insertpoint sim:/racing_game_tb/*
    add wave -position insertpoint sim:/racing_game_tb/wrapper_racing_game_0/racing_game_top_0/*

} elseif {$test == "racing_game_cpu_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/sprite_bitmap.v
    set s2 ../fpga-examples/sprite_renderer.v
    set s3 ../fpga-examples/racing_game_cpu.v
    set s4 ../fpga-examples/cpu8.v
    set s5 ../rtl/wrapper_racing_game_cpu.v
    set s6 ../tb/racing_game_cpu_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3 $s4 $s5 $s6

    vsim -novopt work.racing_game_cpu_tb
    add wave -position insertpoint sim:/racing_game_cpu_tb/*
    add wave -position insertpoint sim:/racing_game_cpu_tb/wrapper_racing_game_cpu_0/racing_game_cpu_top_0/*
    add wave -position insertpoint sim:/racing_game_cpu_tb/wrapper_racing_game_cpu_0/racing_game_cpu_top_0/cpu/*

} elseif {$test == "digits10_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/digits10.v
    set s2 ../rtl/wrapper_digit10.v
    set s3 ../tb/digits10_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3

    vsim -novopt work.digits10_tb
    add wave -position insertpoint sim:/digits10_tb/*
    add wave -position insertpoint sim:/digits10_tb/wrapper_digit10_0/test_numbers_top_0/*
    add wave -position insertpoint sim:/digits10_tb/wrapper_digit10_0/test_numbers_top_0/numbers/*

} elseif {$test == "starfield_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/starfield.v
    set s2 ../fpga-examples/lfsr.v
    set s3 ../rtl/wrapper_starfield.v
    set s4 ../tb/starfield_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3 $s4

    vsim -novopt work.starfield_tb
    add wave -position insertpoint sim:/starfield_tb/*
    add wave -position insertpoint sim:/starfield_tb/wrapper_starfield_0/starfield_top_0/lfsr_gen/*

} elseif {$test == "crttest_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/crttest.v
    set s2 ../rtl/wrapper_crttest.v
    set s3 ../tb/crttest_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3

    vsim -novopt work.crttest_tb
    add wave -position insertpoint sim:/crttest_tb/*
    add wave -position insertpoint sim:/crttest_tb/wrapper_crttest_0/crttest_0/*

} elseif {$test == "spritetest_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/spritetest.v
    set s2 ../fpga-examples/sprite_bitmap.v
    set s3 ../fpga-examples/sprite_renderer.v
    set s4 ../rtl/wrapper_spritetest.v
    set s5 ../tb/spritetest_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3 $s4 $s5

    vsim -novopt work.spritetest_tb
    add wave -position insertpoint sim:/spritetest_tb/*
    add wave -position insertpoint sim:/spritetest_tb/wrapper_spritetest_0/spritetest_0/*

} elseif {$test == "tiletest_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/ram.v
    set s2 ../fpga-examples/tile_renderer.v
    set s3 ../fpga-examples/font_cp437_8x8.v
    set s4 ../fpga-examples/tiletest.v
    set s5 ../rtl/wrapper_tiletest.v
    set s6 ../tb/tiletest_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3 $s4 $s5 $s6

    vsim -novopt work.tiletest_tb
    add wave -position insertpoint sim:/tiletest_tb/*
    add wave -position insertpoint sim:/tiletest_tb/wrapper_tiletest_0/test_tilerender_top_0/*

} elseif {$test == "ball_paddle_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/digits10.v
    set s2 ../fpga-examples/scoreboard.v
    set s3 ../fpga-examples/ball_paddle.v
    set s4 ../rtl/wrapper_ball_paddle.v
    set s5 ../tb/ball_paddle_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3 $s4 $s5

    vsim -novopt work.ball_paddle_tb
    add wave -position insertpoint sim:/ball_paddle_tb/*
    add wave -position insertpoint sim:/ball_paddle_tb/wrapper_ball_paddle_0/ball_paddle_top_0/*
    add wave -position insertpoint sim:/ball_paddle_tb/wrapper_ball_paddle_0/ball_paddle_top_0/score_gen/*
    add wave -position insertpoint sim:/ball_paddle_tb/wrapper_ball_paddle_0/ball_paddle_top_0/score_gen/digits/*

}

run -all

wave zoom full

#quit
