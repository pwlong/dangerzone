package IPv6_header;
  
  localparam VERSION = "0.1";

  //TODO: check the "endianness" of the fields to make sure they are coming out in the right manner
  typedef struct packed{
          bit [  3:0] version;
          bit [  7:0] trafficClass;
          bit [ 19:0] flowLabel;
          bit [ 15:0] payloadLength;
          bit [ 15:0] nextHeader;
          bit [ 15:0] hopLimit;
          bit [127:0] sourceAddress;
          bit [127:0] destinationAddress;    
  } ipv6FixedHeader_s;
  
  function automatic void prettyHeader (
    input ipv6FixedHeader_s hdr);
    // display the header in a pretty format
    $display("\n\n\t IPv6 PACKET FIXED HEADER CONTENTS (in hex)");
    $display("\t/------------------------------------------\\");
    $display("\t| VERSION  | TRAFFIC CLASS |  FLOW LABEL   |");   
    $display("\t|    %H     |      %H       |    %H      |",
                 hdr.version, hdr.trafficClass, hdr.flowLabel);
    $display("\t|------------------------------------------|");
    $display("\t| PAYLOAD LENGTH | NEXT HEADER | HOP LIMIT |");
    $display("\t|      %H      |     %H    |   %H    |",
                 hdr.payloadLength, hdr.nextHeader, hdr.hopLimit);
    $display("\t|------------------------------------------|");
    $display("\t|            SOURCE ADDRESS                |");
    $display("\t|  %H:%H:%H:%H:%H:%H:%H:%H |",
                 hdr.sourceAddress[0 +:16], hdr.sourceAddress[ 16 +:16],
                 hdr.sourceAddress[32 +:16], hdr.sourceAddress[ 48 +:16],
                 hdr.sourceAddress[64 +:16], hdr.sourceAddress[ 80 +:16],
                 hdr.sourceAddress[96 +:16], hdr.sourceAddress[112 +:16]);
    $display("\t|------------------------------------------|");
    $display("\t|         DESTINATION ADDRESS              |");
    $display("\t|  %H:%H:%H:%H:%H:%H:%H:%H |",
                 hdr.destinationAddress[ 0 +:16], hdr.destinationAddress[ 16 +:16],
                 hdr.destinationAddress[32 +:16], hdr.destinationAddress[ 48 +:16],
                 hdr.destinationAddress[64 +:16], hdr.destinationAddress[ 80 +:16],
                 hdr.destinationAddress[96 +:16], hdr.destinationAddress[112 +:16]);
    $display("\t\\------------------------------------------/\n\n");
  endfunction
  
  function automatic [$bits(ipv6FixedHeader_s)-1 :0] bitStreamHeader (
    input ipv6FixedHeader_s hdr);
    // it's a packed struct, stream it out, baby!
    return hdr;
  endfunction
  
  // extra functions (just for kicks)
  function automatic string dumpHeader (
    input ipv6FixedHeader_s hdr);
    // return the header in a format suitable for loading into a ipv6Header_s
    // struct or dumping to a stimulus file or whatever
    return $psprintf("%p",hdr);
  endfunction
  
  function automatic void genRandomHeader (
    ref ipv6FixedHeader_s hdr);
    hdr = '{version:           4'd6,
           trafficClass:       $urandom_range(8'hFF,0),
           flowLabel:          $urandom_range(20'h2FF,0),
           payloadLength:      $urandom_range(16'hFFFF,0),
           nextHeader:         $urandom_range(16'hFFFF,0),
           hopLimit:           $urandom_range(16'hFFFF,0),
           sourceAddress:     {$urandom(), $urandom(), $urandom(), $urandom()},
           destinationAddress:{$urandom(), $urandom(), $urandom(), $urandom()}};
  endfunction
  
endpackage