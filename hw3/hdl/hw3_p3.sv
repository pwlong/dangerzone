// HW3 Part 3
// Paul Long <paul@thelongs.ws>


module hw3_p3 #() ();
  
  ///////////////// data structures ////////////////////////
  //  this is the real secret sauce for this problem      //
  //  with these data structures we almost don't need     //
  //  functions specified in the assignment               //
  //////////////////////////////////////////////////////////
  typedef enum integer {
    HWORD=0,
    WORD,
    DWORD,
    QWORD
  } opcode_e;
    
  typedef union packed {
    bit [7:0][ 7:0] hWord;
    bit [3:0][15:0] word;
    bit [1:0][31:0] dWord;
    bit      [63:0] qWord;
    } operand_u;
    
  typedef struct packed {
    operand_u a_in;
    operand_u b_in;
  } addends_s;

  ///////////////////////////////////////////////////////////

  
  
  // This function packs up a struct with two random 64 bit numbers.
  // It relies on the caller to use the numbers with the union member
  // as appropriate for it's needs. See the $display section below for
  // an example. For this example it is assumed the function will have 
  // the above-declared data structures available to it.
  function automatic addends_s getOperands();
    addends_s        addends;
    bit       [63:0] rndNumber;

    assert(std::randomize(rndNumber));
    addends.a_in = rndNumber;
     
    assert(std::randomize(rndNumber));
    addends.b_in = rndNumber;
    
    return addends;
    
  endfunction
 
  
  // This function takes in a 64bit number (the results from an adder, perhaps)
  // and stuff it into a union that can be looked at as any of the following:
  // an array of 8 bytes, an array of 4 words, an array of 2 double words, or as
  // a single quad word. It relies on the caller to use the union members
  // as appropriate for its application. For this example it is assumed the
  // function will have the above-declared data structures available to it.
  function automatic operand_u parseResult( input bit [64:0] sum);
    operand_u   result;
    result = sum;
    return result;
  endfunction

  
  initial begin
    addends_s addends;
    operand_u pResult;
    bit [63:0] sum;
    
    //
    // demonstrate the  getOperand function
    //
    $display("\n\n\nInputs Generated by getOperand.");
    $display("The function is called four times to demonstrate that randomization");
    $display("works across calls. Any operand width can be used on any call.");
    addends = getOperands();
    $display("\nBytes");
    foreach (addends.a_in.hWord[i])
      $display("\tx[%0d] = %h\t y[%0d] = %h",
                i ,addends.a_in.hWord[i], i, addends.b_in.hWord[i]);
    
    addends = getOperands();
    $display("\nWords");
    foreach (addends.a_in.word[i])
      $display("\tx[%0d] = %h\t y[%0d] = %h",
                i, addends.a_in.word[i], i, addends.b_in.word[i]);
                
    addends = getOperands();
    $display("\nDouble Words");
    foreach (addends.a_in.dWord[i])
      $display("\tx[%0d] = %h\t y[%0d] = %h",
                i, addends.a_in.dWord[i], i, addends.b_in.dWord[i]);
                
    addends = getOperands();
    $display("\nQuad Words");
    $display("\tx = %h\ty = %h\n\n\n", addends.a_in.qWord, addends.b_in.qWord);
    
   
    
    //
    // demonstrate the  parseResult function
    //
    
    $display("\n\n\nResults Generated by parseResults.");
    $display("This demo uses for calls to the function: however,");
    $display("any operand width can be used on any call.");
    
    pResult = parseResult(64'hDEAD_BEEF_BA53_BA11);
    $display("\nByte Results");
    foreach (pResult.hWord[i])
      $display("z[%0d] = %h", i, pResult.hWord[i]);
    
    assert(std::randomize(sum)); 
    pResult = parseResult(sum);
    $display("\nWord Results");
    foreach (pResult.word[i])
      $display("z[%0d] = %h", i, pResult.word[i]);
      
    assert(std::randomize(sum)); 
    pResult = parseResult(sum);
    $display("\nDouble Word Results");
    foreach (pResult.dWord[i])
      $display("z[%0d] = %h", i, pResult.dWord[i]);
      
    assert(std::randomize(sum)); 
    pResult = parseResult(sum);
    $display("\nQuad Word Results");
    $display("z = %h\n\n\n", pResult.qWord);
    
    $finish;
  
  end

  
endmodule    