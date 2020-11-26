#!/usr/bin/perl -w

print <<EOF
`default_nettype none

/*
 *-------------------------------------------------------------
 *
 * user_proj_ls130tw1  (LibreSilicon Testwafer #1)
 *
 */

module user_proj_example #(
    parameter BITS = 32
)(
    inout vdda1,        // User area 1 3.3V supply
    inout vdda2,        // User area 2 3.3V supply
    inout vssa1,        // User area 1 analog ground
    inout vssa2,        // User area 2 analog ground
    inout vccd1,        // User area 1 1.8V supply
    inout vccd2,        // User area 2 1.8v supply
    inout vssd1,        // User area 1 digital ground
    inout vssd2,        // User area 2 digital ground

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oen,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb
);

EOF
;


our $nextla=0;
our $nextio=0;

foreach my $mag(</home/philipp/libresilicon/StdCellLib/Catalog/*.mag>)
{
  next if((-s $mag)<=50);
  #print `ls -la $mag`;
  my $cell=$mag; $cell=~s/\.mag$/.cell/;
  my $name=""; $name=$1 if($mag=~m/([\w\-\.]+)\.mag$/);
  open CELL,"<$cell";
  print "$name $name(\n";
  print "  \.vdd(vccd1),\n"; # ??? Should we do 3.3V or 1.8V ?
  print "  \.gnd(vssd1),\n";


  while(<CELL>)
  {
    if(m/^\.inputs (.*)/)
    {
      foreach my $inp(split " ",$1)
      {
        my $io=$nextio++;
	print "  \.$inp(io_in[$io]),\n";
      }
    }
    if(m/^\.outputs (.*)/)
    {
      foreach my $outp(split " ",$1)
      {
        my $io=$nextio++;
	print "  \.$outp(io_out[$io]),\n";
      }
    }

  }
  print ");\n";
}
print "endmodule\n";