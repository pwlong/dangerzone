  `timescale 1ns/1ps

module ipv6Testing #() ();

  import IPv6_header::*;
  //string str; 
  ipv6FixedHeader_s hdr1, hdr2; 
  
  initial begin

    hdr1 = '{version:           4'd6,
            trafficClass:       8'hF,
            flowLabel:          20'h200,
            payloadLength:      16'hAA,
            nextHeader:         16'hBB,
            hopLimit:           16'hCC,
            sourceAddress:      128'hBA5EBA11_DEADBEEF_BE5077ED_B01DFACE,
            destinationAddress: 128'hBEDABB13_B0A710AD_CA11AB13_DEADBEA7};
    
    // call the required package functions to
    // demonstrate their use/functionality
    prettyHeader(hdr1);
    $display ("%h\n", bitStreamHeader(hdr1));
    
    // extra special bonus functions
    genRandomHeader(hdr2);                    
    prettyHeader(hdr2);
    $display ("%s\n\n", dumpHeader(hdr2));
    
      
    $finish;

  end
endmodule