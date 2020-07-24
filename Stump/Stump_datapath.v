// Stump Datapath
// Implement your Stump datapath in structural Verilog here, no control block
//
// Created by Paul W Nutter, Feb 2015
//
// ** Update this header **

// 'include' definitions of function codes etc.

`include "src/Stump/Stump_definitions.v"

// Main module
/*----------------------------------------------------------------------------*/


module Stump_datapath (input  wire        clk, 			// System clock
                       input  wire        rst,			// Master reset
                       input  wire [15:0] data_in,		// Data from memory
                       input  wire        fetch,		// State from control	
                       input  wire        execute,		// State from control
                       input  wire        memory,		// State from control
                       input  wire        ext_op,		// sign extender control
                       input  wire        opB_mux_sel,	        // src_B mux control
                       input  wire [ 1:0] shift_op,		// shift operation
                       input  wire [ 2:0] alu_func,		// ALU function 
                       input  wire        cc_en,		// Status register enable
                       input  wire        reg_write,	        // Register bank write
                       input  wire [ 2:0] dest,			// Register bank dest reg
                       input  wire [ 2:0] srcA,			// Source A from reg bank
                       input  wire [ 2:0] srcB,			// Source B from reg bank
                       input  wire [ 2:0] srcC,			// Used by Perentie
                       output wire [15:0] ir,			// IR contents for control
                       output wire [15:0] data_out,		// Data to memory
                       output wire [15:0] address,		// Address
                       output wire [15:0] regC,			// Used by Perentie
                       output wire [ 3:0] cc);	 		// Flags



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Declarations of any internal signals and buses used  */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
wire [15:0] reg_data;
wire [15:0] regA;
wire [15:0] regB;
//wire [4:0]  ir
wire [15:0] immed;
wire [15:0] src_2;
wire [15:0] pc_increment;
assign pc_increment = 16'h0001;
wire [15:0] operand_A;
wire [15:0] operand_B;
wire csh;
wire [3:0] alu_flags;
wire [15:0] alu_out;
wire [15:0] addr_reg;

assign data_out = regA;

/* Instantiate register bank                                                  */

Stump_registers registers (.clk(clk),
                           .rst(rst),
                           .write_en(reg_write),
                           .write_addr(dest),
                           .write_data(reg_data),
                           .read_addr_A(srcA), 
                           .read_data_A(regA),
                           .read_addr_B(srcB), 
                           .read_data_B(regB),
                           .read_addr_C(srcC), 		// Debug port address 
                           .read_data_C(regC));		// Debug port data    

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Instantiate other datapath modules here                                    */

//Top mux selection - for choosing data in to reg bank from alu out or memory
Stump_mux16bit       mux_data_in_select (.D0(alu_out),
                                         .D1(data_in),
                                         .S(memory),
                                         .Q(reg_data));

//bottom mux to chose between address from pc in fetch or in ld/st                                         
Stump_mux16bit       mux_address_select (.D0(regA),
                                         .D1(addr_reg),
                                         .S(memory),
                                         .Q(address));

//to select between 1 for fetch and 0 for excecute
Stump_mux16bit       mux_alu_input_select (.D0(src_2),
                                           .D1(pc_increment),
                                           .S(fetch),
                                           .Q(operand_B));

//to select between operand b type 1 and immediate type 2
Stump_mux16bit       mux_type1_or_type2_select (.D0(regB),
                                                .D1(immed),
                                                .S(opB_mux_sel),
                                                .Q(src_2));

//registers
Stump_reg16bit       IR_reg (.CLK(clk),
                             .CE(fetch),
                             .D(data_in),
                             .Q(ir));

Stump_reg16bit       Address_reg (.CLK(clk),
				  .CE(execute),
                                  .D(alu_out),
                                  .Q(addr_reg));

Stump_reg4bit        CC_reg (.CLK(clk),
                             .CE(cc_en),
                             .D(alu_flags),
                             .Q(cc));

//shift
Stump_shifter        shift (.operand_A(regA),
                            .c_in(cc[0]),
                            .shift_op(shift_op),
                            .shift_out(operand_A),
                            .c_out(csh));

//sign extend
Stump_sign_extender  sign_extender (.ext_op(ext_op),
                                    .D(ir[7:0]),
                                    .Q(immed));


//alu
Stump_ALU             alu (.operand_A(operand_A),
                           .operand_B(operand_B),
                           .func(alu_func),
                           .c_in(cc[0]),
                           .csh(csh),
                           .result(alu_out),
                           .flags_out(alu_flags));

    

                                 


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/


/*----------------------------------------------------------------------------*/

endmodule

/*============================================================================*/
