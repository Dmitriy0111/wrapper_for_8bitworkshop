
help:
	$(info make help           	- show this message)
	$(info make clean          	- delete synth and simulation folders)
	$(info make sim            	- the same as sim_gui)
	$(info make synth          	- clean, create the board project and run the synthesis (for default board))
	$(info make open           	- the same as synth_gui)
	$(info make load           	- the same as synth_load)
	$(info make sim_cmd        	- run simulation in Modelsim (console mode))
	$(info make sim_gui        	- run simulation in Modelsim (gui mode))
	$(info make synth_create   	- create the board project)
	$(info make synth_build_q  	- build the board project with quartus)
	$(info make synth_gui_q    	- open the board project with quartus)
	$(info make synth_load_q   	- program the default FPGA board with quartus)
	$(info make board_all      	- run synthesis for all the supported boards)
	$(info Open and read the Makefile for details)
	@true

PWD     := $(shell pwd)
BRD_DIR  = $(PWD)/board
RUN_DIR  = $(PWD)/run
RTL_DIR  = $(PWD)/rtl
TB_DIR   = $(PWD)/tb

BOARDS_SUPPORTED ?= de10_lite rz_easyFPGA_A2_1 Storm_IV_E6_V2
BOARD            ?= rz_easyFPGA_A2_1

########################################################
# common make targets

show_pwd:
	PWD

clean: \
	sim_clean \
	board_clean \
	prog_clean

sim_all: \
	sim_cmd 

sim: sim_gui

create: synth_create

synth_q: \
	synth_clean \
	synth_create \
	synth_build_q

load_q: synth_load_q

open_q: synth_gui_q

########################################################
# simulation - Modelsim

VSIM_DIR = $(PWD)/sim_modelsim

VLIB_BIN = cd $(VSIM_DIR) && vlib
VLOG_BIN = cd $(VSIM_DIR) && vlog
VSIM_BIN = cd $(VSIM_DIR) && vsim

VSIM_OPT_COMMON += -do $(RUN_DIR)/script_modelsim.tcl -onfinish final

VSIM_OPT_CMD     = -c
VSIM_OPT_CMD    += -onfinish exit

VSIM_OPT_GUI     = -gui -onfinish stop

sim_clean:
	rm -rfd $(VSIM_DIR)

sim_dir: sim_clean
	mkdir $(VSIM_DIR)

sim_cmd: sim_dir
	$(VSIM_BIN) $(VSIM_OPT_COMMON) $(VSIM_OPT_CMD)

sim_gui: sim_dir
	$(VSIM_BIN) $(VSIM_OPT_COMMON) $(VSIM_OPT_GUI) &

########################################################
# synthesis - default board only

MAKEFILE_PATH   = $(PWD)/board
SYNTH_DIR       = $(PWD)/synth_$(BOARD)
SYNTH_TEMPLATE  = $(BRD_DIR)/$(BOARD)
CABLE_NAME 	   ?= "USB-Blaster"

synth_clean:
	rm -rfd $(SYNTH_DIR)

synth_create: synth_clean
	cp -r  $(SYNTH_TEMPLATE) $(SYNTH_DIR)

synth_build_q:
	quartus_sh --flow compile $(PWD)/synth_$(BOARD)/$(BOARD)

synth_gui_q:
	quartus $(PWD)/synth_$(BOARD)/$(BOARD).qpf &

synth_load_q:
	quartus_pgm -c $(CABLE_NAME) -m JTAG -o "p;synth_$(BOARD)/$(BOARD).sof"

########################################################
# program compile

PROG_NAME ?= racing_game_simple

prog_comp:
	mkdir -p schoolMIPS-01_mmio/program_file
	java -jar schoolMIPS-01_mmio/scripts/bin/Mars4_5.jar nc a dump .text HexText schoolMIPS-01_mmio/program_file/program.hex schoolMIPS-01_mmio/program/$(PROG_NAME)/main.S

prog_clean:
	rm -rfd program_file

########################################################
# synthesis - all the supported boards

BOARD_NAME         = $@
BOARD_TEMPLATE_DIR = $(BRD_DIR)/$(BOARD_NAME)
BOARD_BUILD_DIR    = $(PWD)/synth_$(BOARD_NAME)

$(BOARDS_SUPPORTED):
	rm -rfd $(BOARD_BUILD_DIR)
	cp -r  $(BOARD_TEMPLATE_DIR) $(BOARD_BUILD_DIR)
	make -C $(BOARD_BUILD_DIR) create
	make -C $(BOARD_BUILD_DIR) build

board_all: $(BOARDS_SUPPORTED)

board_clean:
	rm -rfd $(PWD)/synth_*
	