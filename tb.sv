`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Er. Arpit Paul
// 
// Create Date: 11.05.2024 15:31:58
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


class transaction;
randc bit [15:0] loadin;
bit [15:0] dout;
endclass



interface cnt_16_intf();
logic wr,clk, rst, up;
logic [15:0] loadin;
logic [15:0] dout;
endinterface


class generator;
transaction t;
mailbox mbx;
event done;
integer i;


function new(mailbox mbx);
this.mbx=mbx;
endfunction


task run();
t=new();
for(i=0; i<15; i++)
begin
t.randomize();
mbx.put(t);
@(done);
end
endtask
endclass





class driver;
virtual cnt_16_intf vif;
mailbox mbx;
transaction t;
event done;


function new(mailbox mbx);
this.mbx=mbx;
endfunction



task run();
t=new();

forever begin
mbx.get(t);
vif.loadin = t.loadin;
-> done;
@(posedge vif.clk);
end
endtask
endclass


class monitor;
transaction t;
mailbox mbx;
virtual cnt_16_intf vif;

function new(mailbox mbx);
this.mbx=mbx;
endfunction


task run();
t=new();
forever begin
t.loadin = vif.loadin;
t.dout = vif.dout;
mbx.put(t);
$display("[MON] : Data send to scoreboard");
@(posedge vif.clk);
end
endtask
endclass



class scoreboard;
mailbox mbx;
transaction t;

function new(mailbox mbx);
this.mbx=mbx;
endfunction


task run();
t=new();

forever begin
mbx.get(t);
$display("[SCO] : Data received from monitor");
end
endtask
endclass




class environment;
generator gen;
driver drv;
virtual cnt_16_intf vif;
monitor mon;
scoreboard sco;

event gddone;
mailbox gdmbx, msmbx;



function new(mailbox gdmbx, mailbox msmbx);
this.gdmbx=gdmbx;
this. msmbx= msmbx;


gen = new(gdmbx);
drv = new(gdmbx);
mon= new(msmbx);
sco = new(msmbx);
endfunction



task run();
gen.done = gddone;
drv.done = gddone;

drv.vif = vif;
mon.vif= vif;

fork
gen.run();
drv.run();
mon.run();
sco.run();
join_any
endtask
endclass




module tb;

environment env;
cnt_16_intf vif();
mailbox gdmbx;
mailbox msmbx;


cnt_16 dut(vif.wr,vif.clk, vif.rst, vif.up, vif.loadin, vif.dout);


always #10 vif.clk = ~vif.clk;

initial begin
vif.clk=1'b0;
vif.wr=1'b0;
vif.rst=1'b0;
vif.up=1'b0;

#50;
vif.rst =1'b1;
#100;
vif.rst=1'b0;
vif.wr =1'b1;
#100
vif.wr = 1'b0;
vif.up =1'b1;
#200;
vif.up=1'b0;
end


initial begin
gdmbx= new();
msmbx=new();

env=new(gdmbx,msmbx);
env.vif=vif;


env.run();
#550;
$finish;
end
endmodule
