// Stump control decode module.
// Behavioural Verilog module describing combinatorial logic.
//
// P W Nutter
//
// April 2019
//
// Update


`include "src/Stump/Stump_definitions.v"

/*----------------------------------------------------------------------------*/

module Stump_control_decode (input  wire [1:0]  state,      // current state of FSM
		             input  wire [3:0]  cc,         // current status of cc
              	             input  wire [15:0] ir,	    // current instruction
                             output reg         fetch,
                             output reg         execute,    // current state
                             output reg         memory,
 		             output reg         ext_op,		      
 		             output reg         reg_write,  // register write enable
		             output reg  [2:0]  dest,	    // destination register		      
		             output reg  [2:0]  srcA,	    // Source register operand A
		             output reg  [2:0]  srcB,	    // Source register operand B
		             output reg  [1:0]  shift_op,
              	             output reg         opB_mux_sel,// operandB mux select
		             output reg  [2:0]  alu_func,   // function derived from ir
              	             output reg         cc_en,      // cc register enable
                             output reg         mem_ren,    // Memory read enable		      
                             output reg         mem_wen	    // Memory write enable
                      );

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Declarations of any internal signals and buses used                        */

//I have ran out of time to complete all testing - only did tests 1 and 2 
//hence cannot confirm it works fully


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Control decoder                                                             */

always @ (*)
        begin
	case (state)
		`FETCH: begin
				fetch = 1'b1;
				execute = 1'b0;
				memory = 1'b0;
				ext_op = 1'b0;
				reg_write = 1'b1;
				dest = 3'b111;
				srcA = 3'b111;
				srcB = 3'bx;
				shift_op = 2'b00;
				opB_mux_sel = 1'bx;
				alu_func = `ADD;
				cc_en = 1'b0;
				mem_ren = 1'b1;
				mem_wen = 1'b0;
			end

		`EXECUTE: begin
				if(ir[15:12] == 4'b1111)
						begin                      //type3:
						 fetch = 1'b0;
						 execute = 1'b1;
						 memory = 1'b0;
						 ext_op = 1'b1;
						 if (Testbranch(ir[11:8], cc[3:0]) == 1)  //checks flags with BCC function eg BAL BGT
						 	reg_write = 1'b1;
						 else
							reg_write = 1'b0;
						 dest = 3'b111;              //if coniditon satisfied destination is pc
						 srcA = 3'b111;              //srcA = pc
						 srcB = 3'bx;
						 shift_op = 2'b00;
						 opB_mux_sel =1'b1;
						 alu_func = ir[15:13];            //add offset to pc always only put in pc if conidtion satisfied
						 cc_en = 1'b0;
						 mem_ren = 1'b0;              //type 1 instructions that aren't ldst dont have to access memory at all! 
						 mem_wen = 1'b0;
						 end
                                 else if(ir[15:13] == 3'b110)
						begin                         //ldst
						 fetch = 1'b0;
						 execute = 1'b1;
						 memory = 1'b0;
						           //BIT 12 = 0 = TYPE 1
						 ext_op = 1'b0;
						 
						
						 reg_write = 1'b0;
						 dest = 3'bx;              //if coniditon satisfied destination is pc
						 srcA = ir[7:5];              //srcA = pc
						 if(ir[12] == 0)
						 	srcB = ir[4:2];
						 else
							srcB = ir[4:2];
						 if(ir[12] == 0)
						 	shift_op = ir[1:0];
						 else
							shift_op = 2'b00;
						 if(ir[12] == 0)
						 	opB_mux_sel =1'b0;
						 else
							opB_mux_sel =1'b1;
						 alu_func = `LDST;            //add offset to pc if coniditon is satisfied
						 cc_en = 1'b0;
						 mem_ren = 1'b0;              //type 1 instructions that aren't ldst dont have to access memory at all! 
						 mem_wen = 1'b0;
						end
			
				else if(ir[12] == 0)
						begin                         //type1: but not 1110 this is not an instruction
						 fetch = 1'b0;
						 execute = 1'b1;
						 memory = 1'b0;
						 ext_op = 1'b0;
						 reg_write = 1'b1;
						 dest = ir[10:8];
						 srcA = ir[7:5];
						 srcB = ir[4:2];
						 shift_op = ir[1:0];
						 opB_mux_sel =1'b0 ;
						 alu_func = ir[15:13];
						 cc_en = ir[11];
						 mem_ren = 1'b0;              //type 1 instructions that aren't ldst dont have to access memory at all! 
						 mem_wen = 1'b0;
						end
				else //if(ir[12] == 1)                          //type 2 not ldst
						begin
						 fetch = 1'b0;
						 execute = 1'b1;
						 memory = 1'b0;
						 ext_op = 1'b0;
						 reg_write = 1'b1;
						 dest = ir[10:8];
						 srcA = ir[7:5];
						 srcB = 3'bx;
						 shift_op = 2'b0;
						 opB_mux_sel =1'b1 ;
						 alu_func = ir[15:13];
						 cc_en = ir[11];
						 mem_ren = 1'b0;             
						 mem_wen = 1'b0;
						end
			
                        end

			
		`MEMORY: begin
				if(ir[11] == 0)
						begin                         //bit 11 == 0; ld
						 fetch = 1'b0;
						 execute = 1'b0;
						 memory = 1'b1;
						 ext_op = 1'bx;
						 reg_write = 1'b1;
						 dest = ir[10:8];            
						 srcA = 3'bx;              
						 srcB = 3'bx;
						 shift_op = 2'bx;
						 opB_mux_sel =1'bx;
						 alu_func = 3'bx;            
						 cc_en = 1'b0;
						 mem_ren = 1'b1;              
						 mem_wen = 1'b0;
						end	

				else
						begin                         //bit 11 == 0; str
						 fetch = 1'b0;
						 execute = 1'b0;
						 memory = 1'b1;
						 ext_op = 1'bx;
						 reg_write = 1'b0;
						 dest = 3'bx;              
						 srcA = ir[10:8];              
						 srcB = 3'bx;
						 shift_op = 2'bx;
						 opB_mux_sel =1'bx;
						 alu_func = 3'bx;            
						 cc_en = 1'b0;
						 mem_ren = 1'b0;              
						 mem_wen = 1'b1;
						end

                                 end


				
				default:begin
						 fetch = 1'bx;
						 execute = 1'bx;
						 memory = 1'bx;
						 ext_op = 1'bx;
						 reg_write = 1'bx;
						 dest = 3'bx;
						 srcA = 3'bx;
						 srcB = 3'bx;
						 shift_op = 2'bx;
						 opB_mux_sel =1'bx ;
						 alu_func = 3'bx;
						 cc_en = 1'bx;
						 mem_ren = 1'bx;             
						 mem_wen = 1'bx;
			  		end
			endcase
                  end





/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Condition evaluation - an example 'function'                               */

function Testbranch; 		// Returns '1' if branch taken, '0' otherwise
input [3:0] condition;		// Condition bits from instruction
input [3:0] CC;				// Current condition code register
reg N, Z, V, C;

begin
  {N,Z,V,C} = CC;			// Break condition code register into flags
  case (condition)
     0 : Testbranch =   1;	// Always (true)
     1 : Testbranch =   0;	// Never (false)
     2 : Testbranch = ~(C|Z);
     3 : Testbranch =   C|Z;
     4 : Testbranch =  ~C;
     5 : Testbranch =   C;
     6 : Testbranch =  ~Z;
     7 : Testbranch =   Z;
     8 : Testbranch =  ~V;
     9 : Testbranch =   V;
    10 : Testbranch =  ~N;
    11 : Testbranch =   N;
    12 : Testbranch =   V~^N;
    13 : Testbranch =   V^N;
    14 : Testbranch = ~((V^N)|Z) ;
    15 : Testbranch =  ((V^N)|Z) ;
  endcase
end
endfunction

/*----------------------------------------------------------------------------*/

endmodule

/*============================================================================*/
