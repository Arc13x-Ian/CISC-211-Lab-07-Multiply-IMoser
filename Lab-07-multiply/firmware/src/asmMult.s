/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Ian Moser"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    
    MOV r2, 0
    LDR r3, =a_Multiplicand
    LDR r4, =b_Multiplier
    STR r2, [r3]
    STR r2, [r4]
    /*setting multiplicand and multiplier to 0, giving them dedicated spaces
     in r3/r4. All the other variables I'm just gonna cycle through r5 one at
     a time*/
    
    LDR r5, =rng_Error
    STR r2, [r5]
    LDR r5, =a_Sign
    STR r2, [r5]    
    LDR r5, =b_Sign
    STR r2, [r5]    
    LDR r5, =prod_Is_Neg
    STR r2, [r5]    
    LDR r5, =a_Abs
    STR r2, [r5]
    LDR r5, =b_Abs
    STR r2, [r5]
    LDR r5, =init_Product
    STR r2, [r5]
    LDR r5, =final_Product
    STR r2, [r5]
    /*all variables zeroed out using that one register.*/
    
    STR r0, [r3]
    STR r1, [r4]
    /*setting the multiplicand and the multiplier. I probably could have done
     that earlier but I wanted to make everything a fresh zero, and then
     start the actual multiplying process here.*/
    
    LDR r10, =32767
    LDR r11, =0xFFFF8000
    /*setting the bounds for range checking*/
    
    CMP r0, r10
    BGT errorTime
    CMP r0,r11
    BLT errorTime
    
    CMP r1, r10
    BGT errorTime
    CMP r1,r11
    BLT errorTime
    /*checking the multiplicand and multiplier to see if they're too big.*/
    
    LDR r5, =a_Sign
    LDR r6, =b_Sign
    MOV r7, 0
    MOV r8, 1
    /*setting up for sign checking- remember that r0 = a and r1 = b*/
    
    CMP r0, 0
    STRGE r7, [r5]
    STRLT r8, [r5]
    
    CMP r1, 0
    STRGE r7, [r6]
    STRLT r8, [r6]
    /*compares A and B to zero, assigning a 0 to the sign if the compare is pos
     and a 1 to the sign if the compare is negative.*/
    
    LDR r7, [r5]
    LDR r8, [r6]
    LDR r9, =prod_Is_Neg
    /*sets 7 and 8 to the sign bits so I can compare them to figure out if it's
     a negative product*/
    
    CMP r7, r8
    MOVEQ r7, 0
    MOVNE r7, 1
    /*sets r7 to match a negative product or a positive product based on signs
    but before we set it we need to check for zeroes*/
    CMP r0, 0
    MOVEQ r7, 0
    CMP r1, 0
    MOVEQ r7, 0
    /*if either A or B is zero, the product is positive, so r7 must be 0*/
    
    STR r7, [r9]
    /*finally, set if it's negative*/
    
    LDR r5, =a_Abs
    LDR r6, =b_Abs
    MOV r7, 0
    /*prep for absolute storing*/
    
    CMP r0, 0
    MOVGE r8, r0
    STRGE r0, [r5]
    NEGLT r8, r0
    STRLT r8, [r5]
    /*if r0 is 0 or more, store it into a_Abs. If not, put its negative into r9
     and store that instead.*/
    
    CMP r1, 0
    MOVGE r9, r1
    STRGE r1, [r6]
    NEGLT r9, r1
    STRLT r9, [r6]
    /*do the same thing for r1. Additionally, the absolute A and B are now r8
    and r9, respectively.*/
    
    CMP r8, 0
    BEQ zeroProduct
    CMP r9, 0
    BEQ zeroProduct
    /*i think it'll be easier to do the finalization step for a product of zero
     as it's own thing later*/
    
multiply:
    /*don't forger: mutliplicand is in r8, multiplier is in r9- we'll leave
    the product in r12*/
    
    CMP r9, 0
    BEQ finalizeProduct
    TST r8, 1
    ADDEQ r12, r8, r9
    LSL r8, r8, 1
    LSR r9, r9, 1
    b multiply
    
finalizeProduct:
    /*only r12 needs to be preserved for finalization*/
    LDR r4, =init_Product
    LDR r5, =final_Product
    LDR r6, =prod_Is_Neg
    LDR r7, [r6]
    /*set up for filling the product!*/
    
    STR r12, [r4]
    
    TST r7, 1
    NEGEQ r12, r12
    /*if prod_is_Neg is 1,we 2's complement the product, and then we set it to
     final_product whether its been flipped or not*/
    STR r12, [r5] 
    MOV r0, r12
    
    b done
    
zeroProduct:
    
    LDR r4, =init_Product
    LDR r5, =final_Product
    
    MOV r0, 0
    
    STR r0, [r4]
    STR r0, [r5]
    /*Quick and dirty, make initial and final products equal to r0, which is 0*/
    
    b done
    
errorTime:
    
    LDR r5, =rng_Error
    MOV r2, 1
    STR r2, [r5]
    MOV r0, 0
    b done
    
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




