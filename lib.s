ORG  E00      ///////////////////  DATA ///////////////////

DEC  0        ///Constants
null,         HEX 0     /Null
negone,       DEC -1    /Negative one, useful for decrementing
maxdec,       HEX 0A    /Maximum single place decimal value
ascdig,       HEX 30    /Offset of ASCII digits
asclet,       HEX 37    /Offset of ASCII letters - 10
chrnln,       HEX 0A    /ASCII code for new line
chrdsh,       HEX 2D    /ASCII code for dash (minus sign)
chrspc,       HEX 20    /ASCII code for space
mask1,        HEX 000F  /Mask all but lowest byte
four,         HEX 4     /Nibbles in word, bits in nibble
twelve,       HEX C     /Need to shift that much to get last nibble
debug,        HEX F00D  /Easily identifiable marker for debugging

DEC  0        ///Reserved memory
stkdef,       HEX  A00    /Default stack start address
stkptr,       HEX  A00    /Current stack pointer
stktmp,       HEX  0      /Temporary space for stack functions

clltmp,       HEX  0      /Temporary space for calling functions

bintmp,       HEX  0      /Temporary space for binary functions
bintm2,       HEX  0      /Temporary space for binary functions
bintm3,       HEX  0      /Temporary space for binary functions

sftcnt,       HEX  0      /Counter for shift functions
sfttmp,       HEX  0      /Temporary space for shift functions

lgctmp,       HEX  0      /Temporary space for logic functions

mthcnt,       HEX  0      /Counter for math functions
mthtmp,       HEX  0      /Temporary space for math functions
mthtm2,       HEX  0      /Temporary space for math functions

divdnd,       HEX  0      /Temporary dividend for division function
divsor,       HEX  0      /Temporary divisor for division function

outtmp,       HEX  0      /Temporary space for output functions
outtm2,       HEX  0      /Temporary space for output functions
outtm3,       HEX  0      /Temporary space for output functions

temp1,        HEX  0      /Temporary space for use by compiler
temp2,        HEX  0      /Temporary space for use by compiler
temp3,        HEX  0      /Temporary space for use by compiler
temp4,        HEX  0      /Temporary space for use by compiler
temp5,        HEX  0      /Temporary space for use by compiler

DEC  0        /////////////////// STACK ///////////////////

clear,        HEX 0   /Clear stack
              LDA stkdef
              STA stkptr
              BUN clear I

push,         HEX 0   /Push AC onto stack
              STA stkptr I
              ISZ stkptr   /Never zero, so just a memory INC
              BUN push I

pop,          HEX 0   /Pop from stack to AC
              LDA stkptr
              ADD negone
              STA stkptr
              LDA stkptr I
              BUN pop I


DEC  0        ////////////////// CALLING //////////////////

call,         HEX 0   /Call function whose address is on TOS
              BSA pop
              STA clltmp
              LDA call
              BSA push
              BUN clltmp I


DEC  0        /////////////////// BINARY ///////////////////

nor,          HEX 0   /AC <- !(AC | stack.pop())
              CMA
              STA bintmp
              BSA pop
              CMA
              AND bintmp
              BUN nor I

or,           HEX 0   /AC <- AC | stack.pop()
              BSA nor
              CMA
              BUN or I

xor,          HEX 0   /AC <- AC ^ stack.pop()
              STA bintmp
              BSA pop
              STA bintm2
              CMA
              AND bintmp
              STA bintm3
              LDA bintmp
              CMA
              AND bintm2
              BSA push
              LDA bintm3
              BSA or
              BUN xor I

xnor,         HEX 0   /AC <- AC ^ stack.pop()
              BSA xor
              CMA
              BUN xnor I

nand,         HEX 0   /AC <- !(AC & stack.pop())
              STA bintmp
              BSA pop
              AND bintmp
              BUN nand I


DEC  0        /////////////////// SHIFT ///////////////////

shftr,        HEX 0   /AC <- (AC >> stack.pop())
              STA sfttmp
              BSA pop
              BSA neg
              SNA
              BUN shftr I /Return if -AC >= 0
              STA sftcnt
              LDA sfttmp
   sft_l1,    CLE
              CIR
              ISZ sftcnt
              BUN sft_l1
              BUN shftr I

cshftr,       HEX 0   /AC <- (AC >> stack.pop()), circulated
              STA sfttmp
              BSA pop
              BSA neg     /Should always produce positive: E<-1
              CME
              SNA
              BUN cshftr I /Return if -AC >= 0
              STA sftcnt
              LDA sfttmp
   sft_l2,    CIR
              ISZ sftcnt
              BUN sft_l2
              BUN cshftr I

shftl,        HEX 0   /AC <- (AC << stack.pop())
              STA sfttmp
              BSA pop
              BSA neg     /Should always produce positive: E<-1
              CME
              SNA
              BUN shftl I /Return if -AC >= 0
              STA sftcnt
              LDA sfttmp
   sft_l3,    CLE
              CIL
              ISZ sftcnt
              BUN sft_l3
              BUN shftl I

cshftl,       HEX 0   /AC <- (AC << stack.pop()), circulated
              STA sfttmp
              BSA pop
              BSA neg
              SNA
              BUN cshftl I /Return if -AC >= 0
              STA sftcnt
              LDA sfttmp
   sft_l4,    CIL
              ISZ sftcnt
              BUN sft_l4
              BUN cshftl I


DEC  0        /////////////////// MATH ///////////////////

dec,          HEX 0   /Decrement AC
              ADD negone
              BUN dec I

neg,          HEX 0   /AC <- -AC
              CMA
              INC
              BUN neg I

abs,          HEX 0   /AC <- |AC|
              SNA
              BUN abs I
              CMA
              INC
              BUN abs I

sub,          HEX 0   /AC <- AC - stack.pop()
              STA mthtmp
              BSA pop
              BSA neg
              ADD mthtmp
              BUN sub I

mul,          HEX 0   /AC <- AC * stack.pop()
              SZA
              BUN mul_c1
              BSA pop
              CLA
              BUN mul I /Return if AC = 0
   mul_c1,    STA mthtmp
              BSA pop
              SZA
              BUN mul_c2
              BUN mul I /Return if stack.pop() = 0
   mul_c2,    SNA
              BUN mul_ps
   mul_ng,    STA mthcnt
              CLA
   mul_nl,    ADD mthtmp
              ISZ mthcnt
              BUN mul_nl
              BSA neg
              BUN mul I
   mul_ps,    BSA neg
              STA mthcnt
              CLA
   mul_pl,    ADD mthtmp
              ISZ mthcnt
              BUN mul_pl
              BUN mul I

mod,          HEX 0   /AC <- AC % stack.pop()
              SPA
              BSA neg
              STA mthtmp
              BSA pop
              SZA
              BUN mod_ct
              BUN mod I  /Return 0 if stack.pop() = 0, should raise an error
   mod_ct,    SNA
              BSA neg
              STA mthtm2
              LDA mthtmp
   mod_lp,    ADD mthtm2
              SPA
              BUN mod_ex
              STA mthtmp
              BUN mod_lp
   mod_ex,    LDA mthtmp
              BUN mod I

div,          HEX 0   /AC <- AC / stack.pop()
              SZA
              BUN div_c1
              BSA pop
              CLA
              BUN div I /Return if AC = 0
   div_c1,    STA divdnd
              SPA
              BSA neg
              STA mthtmp
              CLA       /Set counter
              STA mthcnt
              BSA pop
              SZA
              BUN div_c2
              BUN div I /Return if stack.pop() = 0, should raise an error
   div_c2,    STA divsor
              SNA
              BSA neg
              STA mthtm2
              LDA mthtmp
   div_lp,    SPA
              BUN div_dn
              INC
              ADD mthtm2
              ISZ mthcnt    /Should never be zero -> works like memory INC
              BSA dec
              BUN div_lp
   div_dn,    LDA divdnd
              SPA
              BUN div_n
              BUN div_p
   div_n,     LDA divsor
              SNA
              BUN div_fx
              BUN div_ex
   div_p,     LDA divsor
              SPA
              BUN div_fx
              BUN div_ex
   div_fx,    LDA mthcnt
              BSA dec
              BSA neg
              BUN div I
   div_ex,    LDA mthcnt
              BSA dec
              BUN div I


DEC  0        /////////////////// LOGIC ///////////////////

equal,        HEX 0   /E <- (AC == stack.pop())
              STA lgctmp
              BSA sub
              CLE
              SZA
              BUN lgc_x1
              CME
   lgc_x1,    LDA lgctmp
              BUN equal I

nequal,       HEX 0   /E <- (AC != stack.pop())
              BSA equal
              CME
              BUN nequal I

less,         HEX 0   /E <- (AC < stack.pop())
              STA lgctmp
              BSA sub
              CLE
              SNA
              BUN lgc_x2
              CME
   lgc_x2,    LDA lgctmp
              BUN less I

lesseq,       HEX 0   /E <- (AC <= stack.pop())
              STA lgctmp
              BSA sub
              BSA dec
              CLE
              SNA
              BUN lgc_x3
              CME
   lgc_x3,    LDA lgctmp
              BUN lesseq I

more,         HEX 0   /E <- (AC > stack.pop())
              STA lgctmp
              BSA sub
              BSA dec
              CLE
              SPA
              BUN lgc_x4
              CME
   lgc_x4,    LDA lgctmp
              BUN more I

moreeq,       HEX 0   /E <- (AC >= stack.pop())
              STA lgctmp
              BSA sub
              CLE
              SPA
              BUN lgc_x5
              CME
   lgc_x5,    LDA lgctmp
              BUN moreeq I


DEC  0        /////////////////// OUTPUT ///////////////////

outchr,       HEX 0   /Send AC[0..7] to output
   out_bz,    SKO
              BUN out_bz
              OUT AC
              BUN outchr I

outnln,       HEX 0   /Print a newline character
              STA outtmp
              LDA chrnln
              BSA outchr
              LDA outtmp
              BUN outnln I

outsgn,       HEX 0   /Print minus sign if AC is negative
              SNA
              BUN outsgn I
              STA outtmp
              LDA chrdsh
              BSA outchr
              LDA outtmp
              BUN outsgn I

outcdc,       HEX 0   /Print AC % 10 as a decimal digit, AC must >= 0
              STA outtmp
              LDA maxdec
              BSA push
              LDA outtmp
              BSA mod
              ADD ascdig
              BSA outchr
              LDA outtmp
              BUN outcdc I

outchx,       HEX 0   /Print AC % 16 as a hex digit
              STA outtmp
              AND mask1
              STA outtm2
              LDA maxdec
              BSA push
              LDA outtm2
              BSA moreeq
              SZE
              BUN out_s1
              ADD ascdig
              BUN out_s2
   out_s1,    ADD asclet
   out_s2,    BSA outchr
              LDA outtmp
              BUN outchx I

outstk,       HEX 0   /Print stack from top until null (0) encountered.
              STA outtmp
   out_l1,    BSA pop
              SZA
              BUN out_l2
              BUN out_x1
   out_l2,    BSA outchr
              BUN out_l1
   out_x1,    LDA outtmp
              BUN outstk I

outstr,       HEX 0   /Print string from address on stack until null.
              STA outtmp
              BSA pop
              STA outtm2
   out_l3,    LDA outtm2 I
              ISZ outtm2    /Should never be zero -> works like memory INC
              SZA
              BUN out_l4
              BUN out_x2
   out_l4,    BSA outchr
              BUN out_l3
   out_x2,    LDA outtmp
              BUN outstr I

outhex,       HEX 0   /Print AC as hex number
              STA outtm3
              STA outtm2

              LDA outtm3
              BSA push     /Push first

              LDA four
              BSA push
              LDA outtm2
              BSA shftr
              STA outtm2
              BSA push     /Push second

              LDA four
              BSA push
              LDA outtm2
              BSA shftr
              STA outtm2
              BSA push     /Push third

              LDA four
              BSA push
              LDA outtm2
              BSA shftr


              BSA outchx   /Print Fourth
              BSA pop
              BSA outchx   /Print Third
              BSA pop
              BSA outchx   /Print Second
              BSA pop
              BSA outchx   /Print First
              LDA outtm3
              BUN outhex I

outdec,       HEX 0   /Print AC as decimal number
              BSA outsgn
              STA outtm2
              STA outtmp
              BSA push     /Push first
              LDA maxdec
              BSA push
              LDA outtmp
              BSA div
              STA outtmp
              BSA push     /Push second
              LDA maxdec
              BSA push
              LDA outtmp
              BSA div
              STA outtmp
              BSA push     /Push third
              LDA maxdec
              BSA push
              LDA outtmp
              BSA div
              STA outtmp
              BSA push     /Push fourth
              LDA maxdec
              BSA push
              LDA outtmp
              BSA div
              SZA
              BSA outcdc   /Print Fifth
              BSA pop
              SZA
              BSA outcdc   /Print Fourth
              BSA pop
              SZA
              BSA outcdc   /Print Third
              BSA pop
              SZA
              BSA outcdc   /Print Second
              BSA pop
              BSA outcdc   /Print First
              LDA outtm2
              BUN outdec I
