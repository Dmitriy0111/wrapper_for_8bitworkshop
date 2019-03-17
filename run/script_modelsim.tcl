
vlib work

set test "test_hvsync_tb"

#set i0 +incdir+../../fpga-examples/ice40
#set i1 +incdir+../tb

#set s0 ../../fpga-examples/ice40/*.*v
#set s1 ../tb/*.*v

#vlog $i0 $i1 $s0 $s1

if {$test == "test_hvsync_tb"} {

    set i0 +incdir+../../fpga-examples/ice40
    set i1 +incdir+../tb

    set s0 ../../fpga-examples/ice40/test_hvsync.v
    set s1 ../../fpga-examples/ice40/hvsync_generator.v
    set s2 ../tb/*.*v

    vlog $i0 $i1 $s0 $s1 $s2

    vsim -novopt work.test_hvsync_tb
    add wave -position insertpoint sim:/test_hvsync_tb/*
}
#} elseif {$test == "test_hvsync_tb"} {
#    vsim -novopt work.test_hvsync_tb
#} elseif {$test == "test_hvsync_tb"} {
#    vsim -novopt work.test_hvsync_tb
#}

run -all

wave zoom full

#quit
