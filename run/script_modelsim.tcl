
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
#set test "sprite_rotation_tb"
#set test "racing_game_v2_tb"
#set test "racing_game_v3_tb"
#set test "sprite_scanline_renderer_tb"

if {$test == "test_hvsync_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../tb

    set s0 ../fpga-examples/test_hvsync.v
    set s1 ../fpga-examples/hvsync_generator.v
    set s2 ../tb/test_hvsync_tb.*v

    vlog $i0 $i1 $s0 $s1 $s2

    vsim -novopt work.test_hvsync_tb
    add wave -position insertpoint sim:/test_hvsync_tb/*

} elseif {$test == "racing_game_v3_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/sprite_bitmap.v
    set s2 ../fpga-examples/sprite_renderer.v
    set s3 ../fpga-examples/racing_game_v3.v
    set s4 ../rtl/wrapper_racing_game_v3.v
    set s5 ../tb/racing_game_v3_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3 $s4 $s5

    vsim -novopt work.racing_game_v3_tb
    add wave -position insertpoint sim:/racing_game_v3_tb/*
    add wave -position insertpoint sim:/racing_game_v3_tb/wrapper_racing_game_v3_0/racing_game_top_v3_0/*

} elseif {$test == "racing_game_v2_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/sprite_bitmap.v
    set s2 ../fpga-examples/sprite_renderer.v
    set s3 ../fpga-examples/racing_game_v2.v
    set s4 ../rtl/wrapper_racing_game_v2.v
    set s5 ../tb/racing_game_v2_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3 $s4 $s5

    vsim -novopt work.racing_game_v2_tb
    add wave -position insertpoint sim:/racing_game_v2_tb/*
    add wave -position insertpoint sim:/racing_game_v2_tb/wrapper_racing_game_v2_0/racing_game_top_v2_0/*

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
    set i2 +incdir+../schoolMIPS-01_mmio/src
    set i3 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/sprite_bitmap.v
    set s2 ../fpga-examples/sprite_renderer.v
    set s3 ../fpga-examples/racing_game_cpu.v
    set s4 ../schoolMIPS-01_mmio/src/*.*v
    set s5 ../rtl/wrapper_racing_game_cpu.v

    set s6 ../tb/racing_game_cpu_tb.*v

    vlog $i0 $i1 $i2 $i3 $s0 $s1 $s2 $s3 $s4 $s5 $s6

    vsim -novopt work.racing_game_cpu_tb
    add wave -divider  "testbench signals"
    add wave -position insertpoint sim:/racing_game_cpu_tb/*
    add wave -divider  "sm_top signals"
    add wave -position insertpoint sim:/racing_game_cpu_tb/wrapper_racing_game_cpu_0/sm_top_0/*
    add wave -divider  "sm_cpu signals"
    add wave -position insertpoint sim:/racing_game_cpu_tb/wrapper_racing_game_cpu_0/sm_top_0/sm_cpu/*
    add wave -divider  "sm_matrix signals"
    add wave -position insertpoint sim:/racing_game_cpu_tb/wrapper_racing_game_cpu_0/sm_top_0/matrix/*
    add wave -divider  "racing game cpu signals"
    add wave -position insertpoint sim:/wrapper_racing_game_cpu_0/sm_top_0/matrix/racing_game_cpu_top_0/*

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

} elseif {$test == "sprite_rotation_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/sprite_rotation.v
    set s2 ../rtl/wrapper_sprite_rotation.v
    set s3 ../tb/sprite_rotation_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3

    vsim -novopt work.sprite_rotation_tb
    add wave -position insertpoint sim:/sprite_rotation_tb/*
    add wave -position insertpoint sim:/sprite_rotation_tb/wrapper_sprite_rotation_0/tank_top_0/tank_controller_0/*
    add wave -position insertpoint sim:/sprite_rotation_tb/wrapper_sprite_rotation_0/tank_top_0/tank_controller_0/renderer/*
    
} elseif {$test == "sprite_scanline_renderer_tb"} {

    set i0 +incdir+../fpga-examples
    set i1 +incdir+../rtl
    set i2 +incdir+../tb

    set s0 ../fpga-examples/hvsync_generator.v
    set s1 ../fpga-examples/sprite_scanline_renderer.v
    set s2 ../rtl/wrapper_sprite_scanline_renderer.v
    set s3 ../tb/sprite_scanline_renderer_tb.*v

    vlog $i0 $i1 $i2 $s0 $s1 $s2 $s3

    vsim -novopt work.sprite_scanline_renderer_tb
    add wave -position insertpoint sim:/sprite_scanline_renderer_tb/*
    add wave -position insertpoint sim:/sprite_scanline_renderer_tb/wrapper_sprite_scanline_renderer_0/sprite_scanline_renderer_top_0/*
    add wave -position insertpoint sim:/sprite_scanline_renderer_tb/wrapper_sprite_scanline_renderer_0/sprite_scanline_renderer_top_0/sprite_scanline_renderer_0/*
    
}

run -all

wave zoom full

#quit
