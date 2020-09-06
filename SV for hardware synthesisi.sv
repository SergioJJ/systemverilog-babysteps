// Features of systemverilog
// 
// 3 main features of SV include: RTL+ programming, assertions, and testbench 
// 

// RTL is basically in improvement to verilog

// Assertions are for writing checkers

// Test bench is for creating constrained random verification environments

// in sv you can simply list all the inputs and outputs in the module statement by default. ANSCII styel port list
module blk (input a, b, c, output f, g, h);

    assign f = ( a & b ) & c;

    assign g = ( a | b ) & ~c;

    assign h = ~( a | b | c );

endmodule

// can use parameterize your moddules, syntax
// this is also an example for module instantiation

module blk #( parameter n = 1, m = n ) (
    // here a is a single wire, but b is a vector as defined by the parameter n, as is g a parameter defined by m
    input   a, [ n-1:0 ] b, input c,
    output  f, [ m-1:0 ] g, output h
);

    assign f = ~a;
    assign g = ~b;
    assign h = ~c;

endmodule

module top;
    // notice the logic variable type. this is the same as reg in verilog. it can have 4 states: 0, 1, Z, X
    // .. except in SV, logic isn't so much a variable but a datatype so it can be used in other contexts
    logic p, r, x, z;
    logic [3:0] q, y;
    // module instantiates the blk module, but also modifies the parameters of n and m to be 4
    blk #(.n(4), .m(4)) inst (p, q, r, x, y, z);
endmodule

// no need for wires, can be replaced by a lgoic datatype and get rid of the need for wire statements

module inv ( input logic a, output logic f);
    // in SV, you are allowed to make a continuous assignment to a variable
    assign f = ~a;
endmodule

module top;
    logic a, f; // a variable
    
    assign a = 1;
    // another difference from verilog is that variables can be directly connected to the output of a module
    inv m (a, f);
endmodule
/*
A variable can be assigned with a procedural assignment
or exactly one continuous assignment
or exactly one output port
*/

// some shorthand for when you are connecting ports across modules
// often you are connecting ports that have the same name
// SV gives you a shorthand to connect these ports that share names

module flop ( input ck, d, output logic q );
// following three statements are all equivalent
flop inst1 (.ck(ck), .d(d), .q(q));

flop inst2 (.ck, .d, .q);
// connects every port that shares a port name
flop inst3 (.*);

// **************
// when using .*, you can use exceptions for when some of the ports are being used to connect different names
// following three statements are all equivalent
flop inst4 (.ck(clock, .d, .q));

flop inst5 (.ck(clock), .*);

flop inst6 (.*, .ck(clock));


// RTL coding style in SV
// there are 3 ways to express combinational logic, just as in verilog or VHDL

// through module instantiation, assuming that the modules you instantiate are combinational
ModuleName Instance(....);

// through continous assignment
assign Output = ...;

// through always blocks, as long as you use the 3 "golden rules" of RTL writing
always @*

begin                   // complete sensitivity -
                        // the event control at the top of the always block must include every single variable or wire that is read by the block
                        // can be achieved using contruct always @*
    ...
    Output = ....;      // complete assignment -
                        // every single variable that is assigned in the always block must be assigned in every possible execution of the block

end                     // no feedback -
                        // means no feedback

// Combination Logic and Registers 

always @(posedge clock or posedge reset)
    if (reset)
        Output <= value_on_asynchronoise_reset;
    else
        Output <= function_of_inputs_and_state;

// Synthesis-friendly always construct
// a veriable must not be assigned by more than one process
always_comb // sensitive to the changes within the contents of a function, including arguments. similar to always @*, but even more sensitive

always_latch // intended to synthesize transparent latches, not so widely used

always_ff   // intended for clocked always blocks. must have exactly one event control, appearing after the always_ff statement

// Symthesis - friendly If / Case

module M1 ( input [1:0] a, b, c, d, output logic [1:0] f );
    always_comb
        // the if statement is evaluated in procedure, with the first true condition being evaluated without testing the rest
        // the use of the priority statment makes it explicit. at least one condition must match, and will get a runtime warning if
        // there is an input that doesn't match the condition if there is no else statement
        priority if ( a == b )
            f = 1;
        
        else if ( a == c )
            f = 2;
        else if ( a == d)
            f = 3;
endmodule 

// priority case statement
module M1 ( input [1:0] a, b, c, d, output logic [1:0] f );
    always_comb 
    // a,b,c,d are all variables
        // the expression at the top is compared to each of the statement labels one by one until a match is found
        // once again priority keyword creates a warning if there is no match
        priority case (a)
            b: f = 1;

            c: f = 2;

            d: f = 3;
        endcase
endmodule 

// unique if
module M3 ( input [3:0] state, output logic [1:0] f);
    always_comb
        // unique enforces complete assignemnt. requires that branches of the if statement be mutually exclusive
        // gives a runtime warning if no conditions match or more than one condition matches
        unique if ( state[0] )
            f = 0;
        else if ( state[1] )
            f = 1;
        else if ( state[2] )
            f = 2;
        else if ( state[3] )
            f = 3;
endmodule 

// unique case
module M4 ( input [3:0] state, output logic [1:0] f);
    always_comb 
    // once again, runtime warning if no conditions match or more than one condition matches
        unique case (1'b1)
            state[0] : f = 0;

            state[1] : f = 1;

            state[2] : f = 2;

            state[3] : f = 3;

        endcase
endmodule

// Wild equality operator
// allows you to test conditions with a "wildcard" in the variable
// X and Z on the right hand side mean don't care
module M5   (input logic [3:0] a,
            output logic [3:0] f);
    always_comb 
        unique_if ( a ==? 4'b1xxx )
            f = 3;
        else if ( a ==? 4'b01xx )
            f = 2;
        else if ( a ==? 4'b001x )
            f = 1;
        else if ( a ==? 4'b0001 )
            f = 0;
endmodule 