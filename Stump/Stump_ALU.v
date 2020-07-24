// Stump ALU
// Implement your Stump ALU here
//
// Created by Paul W Nutter, Feb 2015
//
// ** Update this header **
//

`include "src/Stump/Stump_definitions.v"

// 'include' definitions of function codes etc.
// e.g. can use "`ADD" instead of "'h0" to aid readability
// Substitute your own definitions if you prefer by
// modifying Stump_definitions.v

/*----------------------------------------------------------------------------*/

module Stump_ALU (input  wire [15:0] operand_A,		// First operand
                  input  wire [15:0] operand_B,		// Second operand
		  input  wire [ 2:0] func,		// Function specifier
		  input  wire        c_in,		// Carry input
		  input  wire        csh,  		// Carry from shifter
		  output reg  [15:0] result,		// ALU output
		  output reg  [ 3:0] flags_out);	// Flags {N, Z, V, C}


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Declarations of any internal signals and buses used                        */

/*reg [2:0] current_state;
  */
reg  carry_out;                                                              //this is for carry out flag
reg  [15:0] sum_out;                                                         

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Verilog code                                                               */

always @ (*)
begin
           
case(func)
     
      3'b000:     
                  begin                                                              //flags bits set as N Z V C 3 2 1 0
                    result = operand_A + operand_B;
                    if(result == 16'h0000)            flags_out[2] = 1;              //if result is 0 set zero bit to 1 else set to 0
                    else                              flags_out[2] = 0;

                    if(result[15] ==  1)              flags_out[3] = 1;              //numbers are signed hence if bit 16 is 1 number is negative
                    else                              flags_out[3] = 0;

                    /*the overflow flag can be evaluated by looking at the signs of the operands this operation is an add hence there is 2 outcomes 
                    if either a or b is negative then an overflow cannot occur as both numbers were in range to begin with. If both are positive or both 
                    are negative then it is possible for an overflow to occur because the number could go out of range. As bits are signed we can do this 
                    by evaluting the 16th bit; 1 for negative 0 for positive*/

                    if((operand_A[15] == 1 & operand_B[15] == 1 & result[15] == 0) |(operand_A[15] == 0 & operand_B[15] == 0 & result[15] == 1)) 
                    //if both operands negative and result is poisitive or both operands positive and result is negative - set overflow flag
                                                      flags_out[1] = 1;                    
                    else                              flags_out[1] = 0;
                                                                 
                    {carry_out, sum_out[15:0]} = ({1'b0, operand_A[15:0]} + {1'b0, operand_B[15:0]});   //concatenate operands to 17 bits to check carry out
                    if(carry_out == 1'b1)             flags_out[0] = 1;                                 //carry out flag is measured by the 17th bit - operands should be added and 17th bit then evaluated
                    else                              flags_out[0] = 0;                                 //set the C flag depending on carry out         
                  end
             


     3'b001:     begin
                result = operand_A + operand_B + {15'b000000000000000, c_in};                      //same as case above apart from carry in also must be added 
              
                    if(result == 16'h0000)            flags_out[2] = 1;                            //if result is 0 set zero bit to 1 else set to 0
                    else                              flags_out[2] = 0;

                    if(result[15] ==  1'b1)           flags_out[3] = 1;                            //numbers are signed hence if bit 16 is 1 number is negative
                    else                              flags_out[3] = 0; 

                    if((operand_A[15] == 1 & operand_B[15] == 1 & result[15] == 0) |(operand_A[15] == 0 & operand_B[15] == 0 & result[15] == 1)) 
                    //if both operands negative and result is poisitive or both operands positive and result is negative - set overflow flag
                                                      flags_out[1] = 1;                    
                    else                              flags_out[1] = 0;

                    {carry_out, sum_out[15:0]} = ({1'b0, operand_A[15:0]} + {1'b0, operand_B[15:0]} + {16'h0000, c_in});   //concatenate operands to 17 bits to check carry out
                    if(carry_out == 1'b1)             flags_out[0] = 1;                                                    //carry out flag is measured by the 17th bit - operands should be added and                                                                                                                        //17th bit then evaluated
                    else                              flags_out[0] = 0;                                                    //set the C flag depending on carry out
         
               end
              
     3'b010:     begin 
                result = operand_A + ~operand_B + 16'h0001;

                    if(result == 16'h0000)            flags_out[2] = 1;     //if result is 0 set zero bit to 1 else set to 0
                    else                              flags_out[2] = 0;

                    if(result[15] ==  1'b1)           flags_out[3] = 1;     //numbers are signed hence if bit 16 is 1 number is negative
                    else                              flags_out[3] = 0;

                    /*next oveflow check is a subtraction so an overflow could occur if (-A) - (+B) result is decreasing overflow to positive
                    (+A) - (-B) result is increasing overflow to negative */
                    
                    if((operand_A[15] == 1 & operand_B[15] == 0 & result[15] == 0) | (operand_A[15] == 0 & operand_B[15] == 1 & result[15] == 1))
                                                      flags_out[1] = 1;
                    else                              flags_out[1] = 0;

                    {carry_out, sum_out[15:0]} = ({1'b0, operand_A[15:0]} + {1'b0, ~operand_B[15:0]} + {1'b0, 16'h0001});   //concatenate operands to 17 bits to check carry out
                    if(carry_out == 1'b1)             flags_out[0] = 0;     //carry out flag is measured by the 17th bit - operands should be added and 17th bit then evaluated
                    else                              flags_out[0] = 1;     //set the C flag depending on carry out MUST BE INVERITED        
                 end
             


     3'b011:    begin 
               result = operand_A + ~operand_B + {15'b000000000000000, ~c_in};          //If the carry flag is currently set then the result needs to be reduced by 1 to form a borrow.	
 
                    if(result == 16'h0000)            flags_out[2] = 1;     //if result is 0 set zero bit to 1 else set to 0
                    else                              flags_out[2] = 0;

                    if(result[15] ==  1'b1)           flags_out[3] = 1;     //numbers are signed hence if bit 16 is 1 number is negative
                    else                              flags_out[3] = 0;

                    /*next oveflow check is a subtraction so an overflow could occur if (-A) - (+B) result is decreasing overflow to positive
                    (+A) - (-B) result is increasing overflow to negative */
                    
                    if((operand_A[15] == 1 & operand_B[15] == 0 & result[15] == 0) | (operand_A[15] == 0 & operand_B[15] == 1 & result[15] == 1))
                                                      flags_out[1] = 1;
                    else                              flags_out[1] = 0;

                    {carry_out, sum_out[15:0]} = ({1'b0, operand_A[15:0]} + {1'b0, ~operand_B[15:0]} + {16'h0000, ~c_in});   //concatenate operands to 17 bits to check carry out
                    if(carry_out == 1'b1)             flags_out[0] = 0;       //carry out flag is measured by the 17th bit - operands should be added and 17th bit then evaluated
                    else                              flags_out[0] = 1;       //set the C flag depending on carry out MUST BE INVERITED        
                end
               


     3'b100:     begin
               result = operand_A & operand_B;
              
                    if(result == 16'h0000)            flags_out[2] = 1;     //if result is 0 set zero bit to 1 else set to 0
                    else                              flags_out[2] = 0;

                    if(result[15] ==  1'b1)           flags_out[3] = 1;     //numbers are signed hence if bit 16 is 1 number is negative
                    else                              flags_out[3] = 0;
                    
                                                      flags_out[1] = 0;     //overflow flag always set to 0 
                 
                    if(csh == 1'b1)                   flags_out[0] = 1;     //carry out flag set to value in csh
                    else                              flags_out[0] = 0;
               end
              

     3'b101:      begin 
               result = operand_A | operand_B;
               
                    if(result == 16'h0000)            flags_out[2] = 1;     //if result is 0 set zero bit to 1 else set to 0
                    else                              flags_out[2] = 0;

                    if(result[15] ==  1'b1)           flags_out[3] = 1;     //numbers are signed hence if bit 16 is 1 number is negative
                    else                              flags_out[3] = 0;
                    
                                                      flags_out[1] = 0;     //overflow flag always set to 0 
                 
                    if(csh == 1'b1)                   flags_out[0] = 1;     //carry out flag set to value in csh
                    else                              flags_out[0] = 0;
               end
                

     3'b110:    begin
               result = operand_A + operand_B;  //for load str operations when passes through the pc the pc gets incremented to point to next instruction hence simple addition.
               flags_out = 4'bxxxx;
               end

     3'b111:     begin
               result = operand_A + operand_B; //for branch instructions - the pc states branch to this address but addresses cant fit inside instructions like that so are in a register
               flags_out = 4'bxxxx;            //hence the addition functin used to add offset to address in register so branch can be performed.
               end 
 
      default: begin
               result = 16'hxxxx;
               flags_out = 4'bxxxx;
               end

//only problem I had when testing was the subtracts - because i was extending to 17 bits and inverting - i was inverting the extra 0's i had added to 1's amd hence was messing up my flags
//only need to invert operand_B exactlty none of the extra bits because it would carry over the carry.

   endcase     

  end
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

/*----------------------------------------------------------------------------*/

endmodule

/*============================================================================*/
