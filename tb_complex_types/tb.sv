`timescale 1ns/1ps

module tb;

  timeunit 1ns;
  timeprecision 1ps;

  //--------------------------------------------------------------------------
  // Clock / control
  //--------------------------------------------------------------------------

  logic clk = 0;

  always #5 clk = ~clk;

  //--------------------------------------------------------------------------
  // Simple scalar / vector types
  //--------------------------------------------------------------------------

  bit         b1;
  logic       l1;
  reg         r1;
  byte        by1;
  shortint    si1;
  int         i1;
  longint     li1;
  integer     integer1;
  time        time1;

  logic [7:0]          u8;
  logic signed [7:0]   s8;
  bit   [15:0]         bits16;
  logic [31:0]         word32;
  logic signed [31:0]  sword32;

  real      real1;
  shortreal sreal1;

  string    str1;

  //--------------------------------------------------------------------------
  // Enum
  //--------------------------------------------------------------------------

  typedef enum logic [1:0] {
    ST_IDLE = 2'd0,
    ST_RUN  = 2'd1,
    ST_WAIT = 2'd2,
    ST_ERR  = 2'd3
  } state_e;

  state_e state1;

  //--------------------------------------------------------------------------
  // Packed struct
  //--------------------------------------------------------------------------

  typedef struct packed {
    logic [3:0] a;
    logic [7:0] b;
    logic       c;
  } packed_s_t;

  packed_s_t packed_s1;

  //--------------------------------------------------------------------------
  // Unpacked struct
  //--------------------------------------------------------------------------

  typedef struct {
    byte        x;
    logic [3:0] y;
    state_e     z;
  } unpacked_s_t;

  unpacked_s_t unpacked_s1;

  //--------------------------------------------------------------------------
  // Packed union
  //--------------------------------------------------------------------------

  typedef union packed {
    logic [15:0] raw;
    struct packed {
      logic [7:0] lo;
      logic [7:0] hi;
    } bytes;
  } packed_u_t;

  packed_u_t packed_u1;

  //--------------------------------------------------------------------------
  // Struct containing union
  //--------------------------------------------------------------------------

  typedef struct packed {
    logic [3:0] tag;
    packed_u_t  payload;
  } tagged_u_s_t;

  tagged_u_s_t tagged1;

  //--------------------------------------------------------------------------
  // Nested structs
  //--------------------------------------------------------------------------

  typedef struct packed {
    logic [3:0] nibble;
    logic [7:0] byte_v;
  } inner_packed_s_t;

  typedef struct packed {
    logic [1:0]       kind;
    inner_packed_s_t  inner;
    logic [15:0]      data;
  } outer_packed_s_t;

  outer_packed_s_t nested_packed_s1;

  typedef struct {
    byte        id;
    logic [7:0] value;
  } inner_unpacked_s_t;

  typedef struct {
    state_e             state;
    inner_unpacked_s_t  inner;
    int                 count;
  } outer_unpacked_s_t;

  outer_unpacked_s_t nested_unpacked_s1;

  //--------------------------------------------------------------------------
  // Packed arrays
  //--------------------------------------------------------------------------

  logic [3:0][7:0] packed_arr1;       // 4 packed elements of 8 bits
  logic [1:0][2:0][3:0] packed_3d1;   // packed multidimensional

  //--------------------------------------------------------------------------
  // Unpacked arrays
  //--------------------------------------------------------------------------

  logic [7:0] unpacked_arr1 [0:3];
  int         unpacked_2d1  [0:1][0:2];

  //--------------------------------------------------------------------------
  // Array of structs
  //--------------------------------------------------------------------------

  packed_s_t packed_s_arr1 [0:2];

  //--------------------------------------------------------------------------
  // Struct with unpacked array field
  //--------------------------------------------------------------------------

  typedef struct {
    logic [7:0] data [0:1];
    int         id;
  } struct_with_unpacked_arr_t;

  struct_with_unpacked_arr_t swa1;

  //--------------------------------------------------------------------------
  // More edge-case / usually problematic types for dumping
  //--------------------------------------------------------------------------

  int dyn_arr1[];
  int queue1[$];
  int assoc1[string];

  class packet_c;
    int         id;
    logic [7:0] data;
    function new(int id = 0, logic [7:0] data = '0);
      this.id   = id;
      this.data = data;
    endfunction
  endclass

  packet_c pkt1;

  event ev1;

  //--------------------------------------------------------------------------
  // Dump setup
  //--------------------------------------------------------------------------

`ifdef WAVES_VPD
  initial begin
    $vcdplusfile("waves.vpd");
    $vcdpluson(0, tb_complex_types);
  end
`elsif WAVES_VCD
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb_complex_types);
  end
`elsif WAVES_FST
  initial begin
    $dumpfile("waves.fst");
    $dumpvars(0, tb_complex_types);
  end
`elsif WAVES_FSDB
  initial begin
    $fsdbDumpfile("waves.fsdb");
    $fsdbDumpvars(0, tb_complex_types);
  end
`else
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb_complex_types);
  end
`endif

  //--------------------------------------------------------------------------
  // Helpers
  //--------------------------------------------------------------------------

  task automatic assign_step(int step);
    begin
      // Simple scalars
      b1       = step[0];
      l1       = ~step[0];
      r1       = step[1];
      by1      = byte'(8'h10 + step);
      si1      = shortint'(100 - step * 7);
      i1       = 1000 + step * 11;
      li1      = 64'h1000_0000 + step * 64'd101;
      integer1 = -50 + step * 3;
      time1    = $time;

      u8       = 8'hA0 + step;
      s8       = $signed(-8'sd10 + step);
      bits16   = 16'h1001 ^ (16'(step * 16'h0111));
      word32   = 32'h1234_0000 + step;
      sword32  = $signed(-32'sd1000 + step * 25);

      real1    = 1.25 + step * 0.5;
      sreal1   = 2.5 + step * 0.25;
      str1     = $sformatf("step_%0d", step);

      // Enum
      case (step)
        0: state1 = ST_IDLE;
        1: state1 = ST_RUN;
        2: state1 = ST_WAIT;
        3: state1 = ST_ERR;
        default: state1 = ST_RUN;
      endcase

      // Packed struct
      packed_s1.a = 4'h1 + step;
      packed_s1.b = 8'h20 + step * 3;
      packed_s1.c = step[0];

      // Unpacked struct
      unpacked_s1.x = byte'(8'h80 + step);
      unpacked_s1.y = 4'hF - step[3:0];
      unpacked_s1.z = state1;

      // Packed union
      case (step)
        0: packed_u1.raw      = 16'h1122;
        1: packed_u1.bytes.lo = 8'h33;
        2: packed_u1.bytes.hi = 8'h44;
        3: packed_u1.raw      = 16'hA5A5;
        4: begin
             packed_u1.bytes.lo = 8'h5A;
             packed_u1.bytes.hi = 8'hC3;
           end
      endcase

      // Struct containing union
      tagged1.tag     = step[3:0];
      tagged1.payload = packed_u1;

      // Nested packed struct
      nested_packed_s1.kind         = step[1:0];
      nested_packed_s1.inner.nibble = 4'h8 + step;
      nested_packed_s1.inner.byte_v = 8'h50 + step * 2;
      nested_packed_s1.data         = 16'h9000 + step * 16'h0111;

      // Nested unpacked struct
      nested_unpacked_s1.state       = state1;
      nested_unpacked_s1.inner.id    = byte'(step + 8'h10);
      nested_unpacked_s1.inner.value = 8'h60 + step;
      nested_unpacked_s1.count       = 200 + step * 5;

      // Packed arrays
      packed_arr1[0] = 8'h10 + step;
      packed_arr1[1] = 8'h20 + step;
      packed_arr1[2] = 8'h30 + step;
      packed_arr1[3] = 8'h40 + step;

      packed_3d1[0][0] = 4'h1 + step;
      packed_3d1[0][1] = 4'h2 + step;
      packed_3d1[0][2] = 4'h3 + step;
      packed_3d1[1][0] = 4'h4 + step;
      packed_3d1[1][1] = 4'h5 + step;
      packed_3d1[1][2] = 4'h6 + step;

      // Unpacked arrays
      unpacked_arr1[0] = 8'hA0 + step;
      unpacked_arr1[1] = 8'hB0 + step;
      unpacked_arr1[2] = 8'hC0 + step;
      unpacked_arr1[3] = 8'hD0 + step;

      unpacked_2d1[0][0] = 10 + step;
      unpacked_2d1[0][1] = 20 + step;
      unpacked_2d1[0][2] = 30 + step;
      unpacked_2d1[1][0] = 40 + step;
      unpacked_2d1[1][1] = 50 + step;
      unpacked_2d1[1][2] = 60 + step;

      // Array of structs
      packed_s_arr1[0].a = step + 0;
      packed_s_arr1[0].b = 8'h11 + step;
      packed_s_arr1[0].c = step[0];

      packed_s_arr1[1].a = step + 1;
      packed_s_arr1[1].b = 8'h22 + step;
      packed_s_arr1[1].c = ~step[0];

      packed_s_arr1[2].a = step + 2;
      packed_s_arr1[2].b = 8'h33 + step;
      packed_s_arr1[2].c = step[1];

      // Struct with unpacked array field
      swa1.data[0] = 8'hE0 + step;
      swa1.data[1] = 8'hF0 + step;
      swa1.id      = 100 + step;

      // Dynamic array
      dyn_arr1 = new[step + 1];
      foreach (dyn_arr1[idx]) begin
        dyn_arr1[idx] = step * 100 + idx;
      end

      // Queue
      queue1.push_back(step);
      if (queue1.size() > 4) begin
        void'(queue1.pop_front());
      end

      // Associative array
      assoc1[$sformatf("k%0d", step)] = step * 7;

      // Class handle / class fields
      pkt1 = new(step, 8'h55 + step);

      // Event
      -> ev1;
    end
  endtask

  //--------------------------------------------------------------------------
  // Stimulus
  //--------------------------------------------------------------------------

  initial begin
    // Init
    b1 = 0;
    l1 = 0;
    r1 = 0;
    by1 = '0;
    si1 = '0;
    i1 = '0;
    li1 = '0;
    integer1 = '0;
    time1 = '0;
    u8 = '0;
    s8 = '0;
    bits16 = '0;
    word32 = '0;
    sword32 = '0;
    real1 = 0.0;
    sreal1 = 0.0;
    str1 = "";
    state1 = ST_IDLE;
    packed_s1 = '0;
    unpacked_s1 = '{default:'0};
    packed_u1 = '{default:'0};
    tagged1 = '0;
    nested_packed_s1 = '0;
    nested_unpacked_s1 = '{default:'0};
    packed_arr1 = '0;
    packed_3d1 = '0;

    foreach (unpacked_arr1[i]) unpacked_arr1[i] = '0;
    foreach (unpacked_2d1[i,j]) unpacked_2d1[i][j] = '0;
    foreach (packed_s_arr1[i]) packed_s_arr1[i] = '0;

    swa1 = '{default:'0};

    dyn_arr1 = new[0];
    queue1 = {};
    assoc1.delete();
    pkt1 = null;

    repeat (2) @(posedge clk);

    for (int step = 0; step < 5; step++) begin
      @(posedge clk);
      assign_step(step);
    end

    repeat (3) @(posedge clk);
    $finish;
  end

endmodule
