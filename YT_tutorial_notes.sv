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

// Lesson 3 - Aggregate Classes
// classes with properties that are class instances

// in other workds, a class property can be an instance of another class. this creates an aggregate or composite class

class frame;
    bit [4:0] addr;
    bit [7:0] payload;

    function new(input int add, dat);
        addr = add;
        payload = dat;
    endfunction
    
    // the following function is used to describe encapsulation. this function prints the values of addr and payload for that class
function void print();
    $display("addr = %0h", addr);
    $display("payload = %0h", payload);
endfunction

endclass

class twoframe;  // a class that creates two instances of class frame with handles f1 and f2
    int count;
    frame f1;
    frame f2;

    function new(input int addr, d1, d2); // a method within the class that instantiates the two classes with arguments from the input
        f1 = new(addr, d1);
        f2 = new(addr+1, d2);

    // the following function is used to describe encapsulation, see above function defined in class "frame"
    function void print();
                                        // Encapsulation - each class ir responsible for handling its own properties

        $display("count = %0d", count); // displays the current count value for class "twoframe"
        f1.print();                     // then calls print() function that prints both values of the instances from class f1 and f2 that exist within "twoframe"
        f2.print();                     // this function is defined in the class "frame" and prints values addr, and payload
    endfunction : print                 // this is similar to module instantiation
endclass


twoframe double = new(2,3,4);  // instance of the class twoframe with handle "double" that instantiates the two subclasses f1 and f2
initial begin
    double.f2.addr = 4; // you can then use a class hierarchy of class.subclass.argument/method
                        // here we set the addr property of the f2 instance
    $display("base %h", double.f1.addr);

    // these instances are individually created in memory and are referenced when seen from the scope of the higher class

end

// Lesson 4 - Inheritance
// a class declaration can extend another

class frame;                    // now the parent class
    logic [4:0] addr;
    logic [7:0] payload;
    bit parity;

function new(input int add, dat);  // this function will serve as an example for badtagframe and goodtagframe
addr = add;
payload = dat;
endfunction

endclass

class tagframe extends frame;   // a subclass of frame inherits all the members of the parent
                                // can add more members and can re-declare (over-ride) parent members
    // the parent constructor is automatically called by the subclass constructor as the first line in the subclass
    static int frmcount;
    int tag;
    ...
endclass

// the following class serves as an example of when the comand super must be used to call arguments from the parents class in the subclass
// super allows a subclass to access parent members
class badtagframe extends frame;
    static int frmcount; // 
    int tag;

    function new();
    // we need a call to "frame" constructor here. this is because the values required for this function to overwrite the pervious new() function
    // must be referenced. t
//      super.new(); // is automatically added, but doesn't call the previous function to pass the values
        frmcount++;
        tag = frmcount;
    endfunction
endclass

// the following class shows the correct way to extend a class that involves overwriting the previous class's function 
class goodtagframe extends frame;
    function new(input int add, dat);
    super.new(add,dat);
    frmcount++;
    tag = frmcount;
    endfunction

// Multilayer inheritance
// can keep defining subclasses to parents as long as the chain of calls is unbroken if you are overwriting class functions
// can only pass arguments one level at a time
// super.super.new() is not allowed

// Lesson 5 - Polymorphism
// a sublcass creates a new type. you need to easily change between subclass types wihtout having to rewrite testbench
// any subclass instance can be stored in a parent handle

// introcudces the concept of a handle type
// can create an handle of the parent class, this can contain an instance of the parent class or any subclass of it

class baseframe;
...
    function void iam();
        $display ("Base Frame");
    endfunction : iam
...

class shortframe extends baseframe;
...
    bit s1;

    function void iam();
        $display ("Short Frame");
    endfunction : iam
endlcass : shortframe

baseframe bf;           // parent class handle
shortframe sf = new();  // subclass instance

initial begin
    bf = sf;            // can copy a subclass instance into a parentclass handle
                        // if you call or access any methods or properties of the handle, these are resolved according to handle type
    bf.iam();           // returns string "Baser Frame" as it resolves the call as the bf class type
    
    bf.s1 = 1'b1;       // calling s1 property as bf returns an error, even if this property was written in from the subclass before
                        // this is because if even if there is a subclass instance in bf, you can't access the subclass properties from the baseframe handle
end                     // so what do you do to access this info as you wrote it into the parent handle?

// this example shows how to resolve the situation above so that you can access all properties of the subclass and handle, uses the same class definitions as before

baseframe bf;
shortframe sf1 = new();
shortframe sf2;

initial begin
    bf = sf1;           // copes sublcass to parent handl;e
    bf.iam();           // returns "Base Frame"
//  sf2 = bf;           // you can essentailly copy the baseframe handle back to a shortframe handle to recover the shorframe instance
                        // but, sf2 = bf; is the incorrect syntax as it makes assumptions the subclass handle points to the parent handle
    $cast(sf2, bf);     // this action copies the sf1 contents and pointers and checks to make sure that these are compatible 
    sf2.iam();          // returns "Short Frame", lets you know that the shortframe instance has been recovered
end 

// now an example using this, I assume that this function iw within a class?

function baseframe get_item();
    baseframe base;     // parent class handle
    shortframe short;   // subclass handle
    randcase            // randomly chooses one of the following statements
        1: base = new();// creates a parent class instance or
        1: begin        // creates a subclass instance and copies it into parent handle
            short = new();
            base = short;
        end
    endcase             // end of randcase
    return (base);
endfunction

baseframe bf;           // parent class handle
shortframe sf;          // subclass handle
initial begin
    bf = get_item();    // randomly creates parentclass or creates subclass then copies into parent handle
                        // and the following will decipher which of the two instances actually occured 
    if ($cast(sf, bf))
        $display("shortframe"); // this means the bf handle contains a shortframe instance
    else
        $display("baseframe");  // doesn't contain a shortframe subclass instance
end

// $cast (destination, source)
// $cast is actually a subroutine, aka an assignment and a typecheck
// defined as both a function and a task
// on first example we used the task for since it performed the copy into a new subclass handle
// on the last example we used the function form as it helped to perform the typecheck

// If the source does not contain a matching instance for the destination:
// task gives a run-time error
// function returns 0, used for logical statement

// another polymorphism example
baseframe frame[7:0];               // array of frame 8 handles
shortframe sf;
mediumframe mf;

initial begin
    foreach (frame [i])
        randcase                    // randomly generates either a shortframe or mediumframe instance and copies that into the next element of the frame array
            2 : begin               // essentially loading up the baseframe array with different subclass instances
                sf = new(.pa());    // dynamically selects which subclass instance to load into array
                frame[i] = sf;      //
            end                     // Advantages - the type of frame is decided at the start of stimulus
            1 : begin               // all subsequent refrences can be to the base array variable
                mf = new(.pa(1));   // more subclasses can be easily added to design
                frame[i] = mf;
            end
        endcase
end

// Lesson 6 - Virtual Classes and Methods

class base;
    function void iam();
        $display ("Base")
    endfunction : iam
endclass : base

class parent extends base;
    function void iam();
        $display ("Parent");
    endfunction
endclass : parent

class shild extends parent;
    function void iam();
        $display ("Child");
    endfunction : iam
endclass child

base    b1;
parent  p1 = new();
child   c1 = new();

initial begin
    b1 = p1;    // can take parent instance p1 and copy it into base handle b1
    b1.iam()    // "Base" treated under base handle type

    p1 = c1;    // 
    p1.iam();   // "Parent" treated under parent handle type, but you still can't access any subclass instance values from parent class handle
    // can use cast to access these subclass instances from the parent class, but there is an easier way using virtual methods

end

// example of virtual method implementation

class base;
    virtual function void iam();    // use keyword "virtual" before function definition to make it a virtual method
        $display ("Base")
    endfunction : iam
endclass : base

class parent extends base;
    virtual function void iam();    // vitual is option to write out here since it's declared in the parentclass for this function 
        $display ("Parent");
    endfunction
endclass : parent

class shild extends parent;
    virtual function void iam();    // vitual is option to write out here since it's declared in the parentclass for this function 
        $display ("Child");
    endfunction : iam
endclass child

base    b1;
parent  p1 = new();
child   c1 = new();

initial begin
    b1 = p1;
    b1.iam();    // if you now call a base handle method, it finds that the method is virtual and points to the parent class instance within the base handle

    // works for the child class as  well
    p1 = c1;
    p1.iam();   // "Child"
    // now you can access the members of a subclass instance when it's held in a parent class handle
end

// So when a method is accessed of a class handle, which method is used?
// 1. examine the class declaration of the handle type - look for a virtual method
// 2. If method is not virtual, then the call is directed to the handle class
// 3. If method is virtual, then examine contents of handle - 
//      - if handle contains a subclass isntance, the call is directed to the subclass
//      - if handle doesn't contain a subclass instance, the call is directed back to the handle class

// virtual class

virtual class base; // a virtual class exists only to be inherited, it cannot be instantiated. aka an abstract class
...
    pure virtual function void iam();   // a pure virtual method can only be contained in a virtual class
                                        // this method is a prototype only, no implementation. single line, no action
                                        // if you extend from a virtual class that contains a pure virtual method, then you MUST 
                                        // provide an implementation for your virtual method in your virtual class

endclass : base

class parent extends base;
...
    virtual function void iam();        // here is that forced implementation of the iam() function in the subclass to base
        $display ("Parent");
    endfunction

endclass : parent


class child extends parent;
...
    virtual function void iam();        // here is that forced implementation of the iam() function in the subclass to base
        $display ("Child");
    endfunction

endclass : child

                                        // doing this means you can call the iam() method from any subclass in base

base    b1 = new(); // instance is illegal, will return an error as virutal class base cannot contain an instance
parent  p1 - new();

initial begin
    b1 = p1;
    b1.iam();       // "Parent", thus you can call iam() method from base and it will show the instance that exists within this base handle
end



// Lesson 7 - Randomization of class properties

// rand     - random with uniform distribution
// randc    - random-cyclic randomly iterates through all values without repitition, goes through iterations where all values are used once


class randclass;
    rand    bit [1:0] p1;
    randc   bit [1:0] p2;

    function void post_randomize();             // example of the post_randomization class declaration that user can define
        parity = p1 ^ p2;
    endfunction
endclass

randclass myrand = new();
int ok;

initial begin                                   // randomize the properties of a class isntanceby calling the randomize() function
    ok = myrand.randomize();                    // every class has a built-in randomize virtual method
    if (!myrand.randomize() )                   // you cannot redeclare this method
        $display ("myrand randomize failure")   // returns 1 on success, 0 otherwise
end

// randomize() automatically calls two "hook" functions:
// pre_randomize() before randomization
// post_randomize() after randomization
// if defined, these methods are automatically executed as part of the randomize() function. should never be called individually


// Randomization in aggregate classes

class randclass;
    rand    bit[1:0] p1;
    randc   bit[1:0] p2;
endclass

class randwrap;
    rand int prw;       // randomizes local property prw

    rand randclass c1;  // will push into c1 instance of randclass and randomize the p1 and p2 properties in it, but only if we use the rand keyword
                        // if rand is not added to this handle declaration it will be skipped in the randomization
    function new();
        c1 = new();
    endfunction
endclass
randwrap mywrap = new();// creates the mywrap instance, also creating the c1 instance of the randclass within it
int ok;

initial begin
    ok = mywrap.randomize();    // randomizes both c1 and prw within the randwrap class
end

// controlling randomization: rand_mode()
// enabled by default (1)
// if disabled (0), the property will not be randomized


// if called off a random property, the task changes the mode of that property
// if called of an instance, the task changes the mode for all ranodm properties of instance
task rand_mode(bit on_off);

// mode can be read with function rand_mode
function int rand_mode();
// only rnadom properties have rand_mode, calling method off a nonrandom property is a compile error

// rand_mode() example

class randclass;                // class with two randomization properties and two regular properties
    rand    bit[1:0] p1;
    randc   bit[1:0] p2;
            bit[1:0] s1, s2;
endclass

randclass myrand = new();       // instance of the above class

int ok, state;                  

initial begin
   myrand.rand_mode(0);         // disables all randomization properties 
   myrand.p2.rand_mode(1);      // enables p2 randc property 

   state    = myrand.p2.rand_mode();    // returns 1 since p2 randomization property is currently enabled

   ok       = myrand.randomize();       // only p2 is randomized here

   state    = myrand.s1.rand_mode();    // we get an error as s1 is not a random variable
end

// Lesson 8 - Constraints
// declarative constraints for class randomization

class randclass;
    rand bit    [1:0] p1;
    randc bit   [1:0] p2;

    constraint c1 { p1 != 2'b00; }
endclass

randclass myrand = new;

int ok;

initial begin
    ok = myrand.randomize();
    ...
end

// constraints can be inherited 

class randclass;
    rand bit    [1:0] p1;
    randc bit   [1:0] p2;

    constraint not0 { p1 != 2'b00; }    // contrains p1 in base class
endclass

class rcx1 extends randclass;
    constraint not3 { p1 != 2'b11; }    // adds constraint not3 to not0 from base class
endclass

class rcx2 extends randlcass;
    constraint not0 { p1 != 2'b01; }    // rcx2 overrides not0 from the base class
endclass

class rcx3 extends randclass;
    constraint not0 {}                  // removes the constraint of not0
    constraint not1 { p1 != 2'b01; }    // defines new constraint with a relevant name like not1
endclass

... 
rcx1 myrand = new();
initial begin 
    ok = myrand.randomize();            // p1 is either 01 or 10

// Constraint Expressions: set membership
// inside operator is useful in constraint expressions

class randclass;
    rand bit [7:0] p3;
    constraint c1 { p3 inside {3, 7, [11:20]}; }    // c1 constrains p3 to the set 3, 7, 11 - 20

    // can also use the ! operator to invert the expression
    constraint c2 { !( p3 inside {1,7, [10:255 ] } ); }     // identifies a list of values the rand cannot take
endclass

randclass myrand = new;

int ok;

initial begin 
    ok  = myrand.randomize();
    ...
end

// Constraint Expressions: weighted distributions
// you can change distribution by defining weights for values using dist
// default weight is 1

class randclass;
    rand bit [7:0] p3;
    constraint c2 { p3 dist { [0:127] : = 2, [128:255]: = 1 }; }
                //  this makes values in range 0 to 127 twice as liekly as 128 - 255
endclass
// two ways to assign weight. this is the second way
// : = assigns weight to the item or every value in a range
// : / assigns weight to the item or to a range as a whole

class randclass;
    rand int p4;
    // 7 has weight of 7, 11 - 20 each have a weight of 3, and 26-30 each share a weight of 5, so each has 1/5 weight
    constraint c3 { p4 dist { 7:=5, [11:20]:=3, [26:30]:/1}; }

// Constraint expressions: Conditional Constraints
// there are two ways of defining conditional constraints:
// both of these examples define that if the variable mode is set to either 1 or 0, then 
// p3 will be less than 100 or p3 will be greater than 10000, respectively
// implication using -> operator

class randclass1;
    rand int p3l
    bit mode;
    constraint c1
    {
        mode == 1 -> p3 < 100;
        mode == 0 -> p3 > 10000;
    }
endclass

// if-else, using if .. else construct

class randclass2;
    rand int p4;
    bit mode;
    constraint c2
    {
        if (mode == 1)
            p4 < 100;
        else // else is optional
            p4 > 10000;
    }
endclass

// Controlling Constaints: constraint_mode()
// enabled by default (1)
// if disabled (0), the constraint block will not be used
// mode can be written with task constraint_mode
task constaint_mode(bit on_off);

// Application of constraint_mode()
class randclass;
    rand bit [1:0] p1;
    constraint blue     { p1 != 2'b00; }    // blue constrains p1 to not 00
    constraint green    { p1 != 2'b11; }    // green constrains p1 to not 11
endclass

randclass myrand = new;

int state, ok;

initial begin
   myrand.constraint_mode(0);               // disables all constraints to myrand
   myrand.blue.constraint_mode(1);          // re-enables blue constraint

   state = myrand.green.constraint_mode();  // can test the value of constraint mode switch

   ok = myrand.randomize();                 // randomizes without green constraint, p1 will be 01, 10, or 11
end