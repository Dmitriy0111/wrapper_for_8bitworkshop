#   PLAYER_X_A      = 6'h00,    // player X coordinate
#   PLAYER_Y_A      = 6'h04,    // player Y coordinate
#   ENEMY_X_A       = 6'h08,    // enemy X coordinate
#   ENEMY_Y_A       = 6'h0c,    // enemy Y coordinate
#   ENEMY_DIR_A     = 6'h10,    // enemy direction (left - 0, right - 1)
#   SPEED_A         = 6'h14,    // player speed
#   TRACKPOS_A      = 6'h18,    // track position
#   IN_FLAGS_A      = 6'h1C;    // flags: [0, 0, collision, vsync, hsync, 0, 0, display_on]

.eqv        PLAYER_X        0x00
.eqv        PLAYER_Y        0x04
.eqv        ENEMY_X         0x08
.eqv        ENEMY_Y         0x0c
.eqv        ENEMY_DIR       0x10
.eqv        SPEED           0x14
.eqv        TRACKPOS        0x18
.eqv        FLAGS           0x1c

.eqv        COLLISION_F     0x20
.eqv        VSYNC_F         0x10
.eqv        HSYNC_F         0x08
.eqv        DISPLAY_ON_F    0x01

.eqv        EXS             0x140   # enemy_x start
.eqv        MAX_SPEED       0xFA
.eqv        MIN_SPEED       0x10
.eqv        STOP_VERT       0x1E0
.eqv        STOP_RV         0x244
.eqv        STOP_LV         0x34
.eqv        SHIFT_SPD       0x04    # shift speed
.eqv        ENEMY_STEP      0x01
.eqv        SPEED_STEP      0x01

            .text

init:       move    $t0, $0
            move    $t1, $0
            move    $t2, $0
            move    $t5, $0
            # set address of racing game
            addiu   $t2, $t2, 0x00004000    # set address 0x0000_8000
            addiu   $t2, $t2, 0x00004000    # set address 0x0000_8000
            # init enemy_x
            move    $t3, $0                 # set enemy_x position to center 320
            addiu   $t3, $t3, EXS           # set enemy_x position to center 320
            sw      $t3, ENEMY_X ($t2)      # set enemy_x position to center 320
            # init enemy_y
            move    $t3, $0                 # set enemy_y position to center 0
            sw      $t3, ENEMY_Y ($t2)      # set enemy_y position to center 0
            # wait for vsync = 0
wait_vs_0:  lw      $t1, FLAGS ($t2)        # get flags register
            andi    $t1, $t1, VSYNC_F       # find vsync flag
            bne     $t1, $0,  wait_vs_0     # while vsync != 0 go to wait_vs_0

            # check frame collision
            lw      $t1, FLAGS ($t2)        # load flags register
            andi    $t1, $t1, COLLISION_F   # find collision flag
            lw      $t5, SPEED ($t2)        # get old speed
            beq     $t1, $0,  ch_fc         # check frame collision
            addiu   $t5, $0,  MIN_SPEED     # set default speed
ch_fc:      addiu   $t1, $0,  MAX_SPEED     # load max speed
            sltu    $t1, $t5, $t1           # current speed < max speed ?
            beq     $t1, $0,  new_speed     # if (current speed < max speed ) -> inc current speed
            addiu   $t5, $t5, SPEED_STEP    # inc current speed
new_speed:  sw      $t5, SPEED ($t2)        # set new speed

            # edit enemy_y position
            srl     $t5, $t5, SHIFT_SPD     # shift speed
            lw      $t3, ENEMY_Y ($t2)      # get old enemy_y position
            addu    $t3, $t3, $t5           # addition enemy_y position with speed
            addiu   $t4, $0, STOP_VERT      # load stop vertical value
            sltu    $t4, $t3, $t4           # current enemy_y position < stop vertical value ?
            bne     $0,  $t4, st_enemy_y    # check enemy_y position
            move    $t3, $0                 # move enemy_y to top
st_enemy_y: sw      $t3, ENEMY_Y ($t2)      # set new enemy_y position

            # edit enemy_x position
            lw      $t3, ENEMY_X ($t2)      # get old enemy_x position
            lw      $t4, PLAYER_X ($t2)     # get player_x position
            beq     $t3, $t4, st_enemy_x    # if player_x position = enemy_x position -> go to set new enemy value
            sltu    $t4, $t3, $t4           # enemy_x position < player_x position?
            beq     $t4, $t0, left          # go to left
right:      addiu   $t4, $t4, ENEMY_STEP    # load enemy step value
            addu    $t3, $t3, $t4           # increment enemy_x position
            beq     $0,  $0,  st_enemy_x    # go to set new enemy_x position
left:       addiu   $t4, $t4, ENEMY_STEP    # load enemy step value
            subu    $t3, $t3, $t4           # decrement enemy_x position
st_enemy_x: sw      $t3, ENEMY_X ($t2)      # set new enemy_x position

            # edit track position
            lw      $t3, TRACKPOS ($t2)     # get old track position
            addu    $t3, $t3, $t5           # addition track position with speed
            sw      $t3, TRACKPOS ($t2)     # set new track position

            # wait for vsync = 1
wait_vs_1:  lw      $t1, FLAGS ($t2)        # get flags register
            andi    $t1, $t1, VSYNC_F       # find vsync flag
            beq     $t1, $0,  wait_vs_1     # while vsync != 1 go to wait_vs_1
            # go to waiting new frame
            beq     $0 , $0,  wait_vs_0     # go to wait_vs_0
