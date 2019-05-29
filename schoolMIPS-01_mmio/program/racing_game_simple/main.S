#   PLAYER_X_A      = 6'h00,    // player X coordinate
#   PLAYER_Y_A      = 6'h04,    // player Y coordinate
#   ENEMY_X_A       = 6'h08,    // enemy X coordinate
#   ENEMY_Y_A       = 6'h0c,    // enemy Y coordinate
#   ENEMY_DIR_A     = 6'h10,    // enemy direction (1, -1)
#   SPEED_A         = 6'h14,    // player speed
#   TRACKPOS_LO_A   = 6'h18,    // track position (lo byte)
#   TRACKPOS_HI_A   = 6'h1c,    // track position (hi byte)
#   IN_FLAGS_A      = 6'h20;    // flags: [0, 0, collision, vsync, hsync, vpaddle, hpaddle, display_on]

            .text

init:       move    $t0, $0
            move    $t1, $0
            move    $t2, $0

            addiu   $t2, $t2, 0x00004000    # set address 0x0000_8000
            addiu   $t2, $t2, 0x00004000    # set address 0x0000_8000

            move    $t3, $0                 # set enemy x position to center 320
            addiu   $t3, $t3, 0x140         # set enemy x position to center 320
            sw      $t3, 0x00000008 ($t2)   # set enemy x position to center 320

            move    $t3, $0                 # set enemy y position to center 0
            sw      $t3, 0x0000000C ($t2)   # set enemy y position to center 0

wait_vs_0:  lw      $t1, 0x00000020 ($t2)   # wait vsync = 0
            andi    $t1, $t1, 0x10          # wait vsync = 0
            bne     $t1, $0,  wait_vs_0     # wait vsync = 0

            
            lw      $t3, 0x0000000C ($t2)   # get old enemy y position
            addiu   $t3, $t3, 40            # 
            addiu   $t4, $0, 0x1E0
            sltu    $t4, $t3, $t4
            bne     $0,  $t4, st_enemy_y
            move    $t3, $0                 
st_enemy_y: sw      $t3, 0x0000000C ($t2)   # set new enemy y position

            addiu   $t0, $t0, 1

wait_vs_1:  lw      $t1, 0x00000020 ($t2)   # wait vsync = 1
            andi    $t1, $t1, 0x10          # wait vsync = 1
            beq     $t1, $0,  wait_vs_1     # wait vsync = 1

            beq     $0 , $0,  wait_vs_0     # wait vsync = 0
