// this program is not intended to compile, but to keep track of notes from a systemverilog tutorial I've been following on YT

// Lesson 1 - Basics
// Properties, methods and constructors

module beginner_test;
    class myclass;
        int number;

    function new();
        number = 5; // 
    endfunction

    endclass

    myclass c1;
endmodule

initial begin
    c1 = new;  // one way to initialize a class with a state. number = 5 due to function new being defined
end

myclass c2 = new;
// this initializes c2's number argument as 5. if new were not defined up top, it would initialize to 0.
// this new initialization is dependent on the datatype of the argument

class argcon;
    int number;

    function new(input int ai);
        number = ai;
    endfunction
endclass

argcon c3 = new(3);
// sets c3.number = 3 using the built in function of the class

// example class "frame"

class frame;
    bit [4:0] addr;     // 5 bit address argument
    bit [7:0] payload   // 8 bit payload argument
    bit parity          // single parity bit

    function new (input in add, dat);
        addr = add;     // sets addr argument to input from this function
        payload = dat;  // sets payload argument to input from this function
        genpar();       // calls function genpar defined in the class
    endfunction

    function void genpar(); // definition of function genpar
        parity = ^{addr, payload};
    endfunction

    function bit [13:0] getframe();     // generates the output of the frame class with all data arranged, parity bit generated
        return({addr,payload,parity}); // this is also known as a packing method, creates a single 14 bit vector
    endfunction
endclass


// now let's use our class

bit [13:0] framedata;
frame one = new(3, 16); // initialize instance of the frame class with add = 3 and payload = 16

initial begin
    
    @(negedge clk);
    framedata = one.getframe(); // calls the getframe function to generate the output for this class with istance (3,16)
end
// end of lesson 1


// Lesson 2 - Static Members
// Static properties and methods

// Static properties
// a property of a class that is equal in all instances of a class
// we reuse "frame" from the video
class frame;
    int tag;                // this is a dynamic property. it can be a different value in each sort of class definition.
    static int frmcount;    // this is a static property. changing this value will change the value in each instance of the class
                            // a static property is pre-allocated in memory at elaboration, meaning it can be referenced with each new instance
endclass

frame f1, f2;
initial begin
    f1 = new();             // initializing each instance with both tag and frmcount = 0
    f2 = new();
    f1.frmcount = 4;
    $display(f2.frmcount);  // this will display as 4, indicating that frmcount is static across all instances
end

// Static methods
// a method that is declared with a "static" keyword and has the restriction that it can only access 
// static properties and other static methods

// this allows you to call a static method without needing a handle on the class

class frame;
    static int frmcount;
    int tag;

    static function int getcount();  // initialization of a static method
        return(frmcount);
    endfunction

endclass

frame f1; // this creates a null handle, is not an instance since it hasn't been instantiated with new() or any values
int frames;

initial  begin
    frames = frame::getcount(); // calls the static method getcount()
                                // note how we didn't need to call f1 instance handle since we are only calling a static method
                                // double colon :: is called a resolution operator access
    frames = f1.getcount();     // another method of calling getcount, can be called from any class handle, even null handles
                                // note that this handle hasn't been instantiated, so it is a null handle
end

// static properties and methods class example
// increment static frmcount in constructor and assign to tag, giving each instance a unique tag dependant on order created

class frame;
    static int frmcount;
    int tag;

    function new(...);
    ...
    frmcount++;     // increments frmcount with each new instantiation of a class
    tag = frmcount; // sets the current frmcount to the the unique tag for each class instantiation
    endfunction

    static function int  getcount(); // returns the latest framecount
        return (frmcount);
    endfunction
endclass

frame f1 = new(...);    // sets framecount 1 and tag 1 for f1

frame f2 = new(...):    // sets framecount 2 and tag 2 for f2,  f1's values are frmcount 2 and tag 1
