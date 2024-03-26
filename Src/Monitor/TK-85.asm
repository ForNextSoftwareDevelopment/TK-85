;******************************
;**        NEW TK-85         **
;**         MONITOR          **
;**      '80.2.15   NEC      **
;******************************
;
;******************************
;**      MONITOR START       **
;******************************
;
        ORG     0
        MVI     A,CTRLW
        OUT     MODES           ;TRANSFER CONTROL WORD (<MODE 0: PA:IN PB:IN PC:OUT) TO 8255
        JMP     RESET           ;JUMP INITIALIZE AREA
        ORG     8
        JMP     RST1            ;JUMP RST1 PROCESSING AREA
        ORG     10H
        JMP     RST2            ;JUMP RST2 PROCESSING AREA
        ORG     18H
        JMP     RST3            ;JUMP RST3 PROCESSING AREA
        ORG     20H
        JMP     RST4            ;JUMP RST4 PROCESSING AREA
        ORG     24H
        JMP     TRAP            ;JUMP MONITOR
        ORG     28H
        JMP     RST5            ;JUMP RSTS PROCESSING AREA
        ORG     2CH
        JMP     RST55           ;JUMP RST5.5 PROCESSING AREA
        ORG     30H
        JMP     RST6            ;JUMP RST6 PROCESSING AREA
        ORG     34H
        JMP     BSBRK           ;JUMP BREAK ENTRY AREA (TK-80 BS)
        ORG     38H
        JMP     RST7            ;JUMP RST7 PROCESSING AREA
        ORG     3CH
        JMP     STEP            ;JUMP BREAK ENTRY AREA (NEW TK-85)
;
;******************************
;**       INITIALIZE         **
;******************************
;
CLEAR:  LXI     H,GOIN          ;SET TOP ADD. OF CLEAR AREA
CLEA1:  XRA     A
CLEA2:  MOV     M,A             ;CLEAR WORKING AREA
        INX     H
        DCR     B
        JNZ     CLEA2
        STA     FTRAP           ;SET TRAP FLAG TO SYSTEM (0)
        MVI     A,0C9H
        STA     PORTO+1         ;INITIALIZE OUT INSTRUCTION AREA
        STA     PORTI+1         ;INITIALIZE  IN INSTRUCTION AREA
        MVI     A,0D3H
        STA     GOOUT           ;SET OUT INSTRUCTION CODE
        MVI     A,0DBH
        STA     GOIN            ;SET  IN INSTRUCTION CODE
        RET
;
RESET:  LXI     H,USESP         ;SET TOP ADD. OF MONITORS WORKING AREA
RESE1:  MOV     A,M
        CMA
        MOV     M,A
        CMP     M
        JZ      RESE2
        HLT                     ;IF WORKING AREA ERROR THEN HALT
RESE2:  INR     L
        JNZ     RESE1
;
        LXI     SP,RST1         ;SET TOP ADD. OF MONITORS STACK
        MVI     B,DIG-GOIN      ;SET CLEAR COUNTER
        CALL    CLEAR
        LXI     H,USESP
        SHLD    SVSP            ;MOVE TOP ADD. OF USERS STACK TO (SP)SAVING AREA
;
;******************************
;**    DISTRIBUTE FUNCTION   **
;******************************
;
START:  CALL    SEGCV           ;SEMENT DATA CONVERSION
        CALL    KEYIN           ;KEY INPUT (A,B: HEXA DATA)
;
STAT1:  ANI     10H
        JZ      DIGIT           ;IF INPUT DATA IS EQUAL TO DIGIT THEN JUMP DIGIT PROCESS
;
        LDA     FMODE
        RRC
        JC      STAT2           ;IF F-MODE ON THEN SELECT INPUT DATA
;
        LDA     FREG
        RRC
        JNC     STAT3           ;IF F-REG IS ON THEN SELECT INPUT DATA
STAT2:  MOV     A,B
        CPI     16H
        JC      START           ;IF INPUT DATA IS EQUAL TO REG OR MODE THEN EXECUTE THIS ONE
;
STAT3:  MOV     A,B
        ANI     0FH
        MVI     B,0
        ADD     A
        MOV     C,A
        LXI     H,TFUNC
        DAD     B
        MOV     A,M
        INX     H
        MOV     H,M             ;SET H. ADD. OF JUMPING ROUTINE
        MOV     L,A             ;SET L. ADD. JUMPING ROUTINE
        PCHL                    ;JUMP EACH FUNCTION KEY PROCESS
;
TFUNC:  DW      RUN
        DW      CONT
        DW      ADRST
        DW      RDDEC
        DW      RDINC
        DW      WTENT
        DW      MDFKP
        DW      REG
;
;******************************
;**      DIGIT PROCESS       **
;******************************
;
DIGIT:  LDA     FREG
        RRC
        JC      REGFN           ;IF F-REG IS ON THEN DISPLAY REGISTER
;
        LDA     FMODE
        RRC
        JC      MD              ;IF F-MODE IS ON THEN SET EACH MODE FUNCTION FLAG
;
        CALL    SHIFT           ;SHIFT (DR) & (DDW)
        LDA     DATA
        ORA     B
        STA     DATA            ;INPUT DIGIT DATA (DR)
        MOV     A,B
        STA     DDW4            ;INPUT DIGIT DATA (DDW)
        JMP     START
;
;******************************
;**  FLAG (MODE&REG) PROCESS **
;******************************
;
MDFKP:  CALL    FLAGC           ;RESET EACH FLAG
        STA     FMODE           ;SET F-MODE
ALCLA:  CALL    CA              ;CLEAR (ADW) & (AR)
DTCLA:  CALL    CD              ;CLEAR (DDW) & (DR)
        JMP     START
;
REG:    CALL    FLAGC           ;RESET EACH FLAG
        STA     FREG            ;SET F—REG
        JMP     ALCLA
;
;******************************
;** MODE FUNCTION KEY PROCESS**
;******************************
;
MD:     MOV     A,B
        CPI     0AH
        JC      START           ;IF INPUT DATA NOT EQUAL TO MODE FUNCTION THEN INPUT AGAIN
;
        SUI     8
        CALL    STBIT           ;SET BIT
        STA     FMODE           ;SET EACH MODE FLAG BIT (RESET F-MODE)
        ANI     0C0H
        JZ      START           ;IF F-IN OR OUT IS ON THEN IN/OUT PROCESS
;
        RAL
        RAL
        STA     ADW1            ;GET 'O' OR 'I'
        MVI     A,1DH
        STA     ADW2            ;GET '-'
        JMP     START
;
;******************************
;**     DISPLAY REGISTER     **
;******************************
;
REGFN:  MOV     A,B
        CPI     7
        JNC     START           ;IF INPUT DATA GREATER THAN 6 THEN START
;
        CALL    STBIT           ;SET BIT
        RLC
        STA     FREG            ;SET EACH REGISTER FLAG (RESET F-REG)
;
        MOV     A,B
        MVI     B,0
        ADD     A
        MOV     C,A
        LXI     H,TRGNM
        DAD     B
        MOV     A,M
        INX     H
        MOV     H,M
        MOV     L,A
        SHLD    ADW2            ;DISPLAY REGISTER NAHE
;
        LXI     H,TRGAD
        DAD     B
        MOV     A,M
        INX     H
        MOV     H,M             ;SET H.ADD.    OF REGISTER SAVING AREA
        MOV     L,A             ;SET L.ADD.    OF REGISTER SAVING AREA
        MOV     A,M
        INX     H
        MOV     H,M             ;SET (H.ADD. OF REGISTER SAVING AREA)
        MOV     L,A             ;SET (L.ADD. OF REGISTER SAVING AREA)
        SHLD    DATA            ;SET (REGISTER SAVING AREA)
;
        LXI     H,1D1DH
        SHLD    ADW4            ;GET "--"
        CALL    DWCH            ;CONVERT (DR) INTO (DDW)
        JMP     START
;
TRGNM:  DW      0A0FH
        DW      0B0CH
        DW      0D0EH
        DW      1012H
        DW      0515H
        DW      0B15H
        DW      0B0DH
;
TRGAD:  DW      SVAF
        DW      SVBC
        DW      SVDE
        DW      SVHL
        DW      SVSP
        DW      SVBP
        DW      SVBD
;
;******************************
;**    ADDRESS SET PROCESS   **
;******************************
;
ADRST:  CALL    ARSET           ;MOVE (DR) TO (AR)
;
MEMRD:  MOV     A,M
        STA     DATA            ;READ MENORY
        CALL    AWCH            ;CONVERT (AR) INTO (ADW)
        CALL    CD12            ;CLEAR (DR)H & (DDW1,2)
        CALL    DLWCH           ;CONVERT (DR)L INTO (DDW3,4)
        CALL    FLAGC           ;RESET EACH FLAG
        JMP     START
;
ARSET:  LHLD    DATA
        SHLD    ADRES
        RET
;
;******************************
;**  READ INCREMENT PROCESS  **
;******************************
;
RDINC:  LHLD    ADRES
        INX     H               ;INCREMENT (AR)
        SHLD    ADRES
        JMP     MEMRD
;
;******************************
;**  READ DECREMENT PROCESS  **
;******************************
;
RDDEC:  LHLD    ADRES
        DCX     H               ;DECREMENT (AR)
        SHLD    ADRES
        JMP     MEMRD
;
;******************************
;**      RUN PROCESS         **
;******************************
;
RUN:    LHLD    ADRES
        SHLD    SVPC            ;MOVE (AR) TO (PC) SAVING AREA
        JMP     CONT
;
;   <<<   TK-8O MONITOR SUBROUTINE "RGDSP"   >>>
;
        ORG     01A1H
        JMP     RGDSP
;
;******************************
;**    CONTINUE PROCESS      **
;******************************
;
CONT:   LHLD    SVSP
        SPHL                    ;SET ((SP) SAVING AREA)
        LHLD    SVPC
        PUSH    H               ;SAVE ((PC) SAVING AREA)
        LHLD    SVAF
        PUSH    H               ;SAVE ((AF)SAVtNG AREA)
        LHLD    SVHL
        PUSH    H               ;SAVE ((HL) SAVING AREA)
        LHLD    SVBC
        PUSH    H               ;SAVE ((BC) SAVING AREA)
        POP     B               ;RECOVER BC
        LHLD    SVDE
        XCHG                    ;RECOVER DE
        JMP     CONT1
;
;   <<<   TK-8O MONITOR SUBROUTINE "SEGCG"   >>>
;
        ORG     01C0H
        JMP     SEGCG
;
CONT1:  POP     H               ;RECOVER HL
;
        XRA     A
        OUT     PORTC           ;RESET EXTERNAL F/F WHICH IS IN CONTACT WITH RST7.5 F/F (PC7)
        DCR     A
        STA     FTRAP           ;SET TRAP FLAG TO USER (FFH)
        MVI     A,MSKRS
        SIM                     ;RESET INTERRUPT MASK
        OUT     PORTC           ;INACTIVATE 'PRESET' OF EXTERNAL F/F (PC7)
        POP     PSW             ;RECOVER AF
        EI                      ;INTERRUPT ENABLE
        RET                     ;RECOVER PC
;
;******************************
;** TRAP INTERRUPT PROCESS   **
;******************************
;
TRAP:   PUSH    PSW             ;SAVE AF
        LDA     FTRAP
        ANA     A
        JNZ     TRAP1           ;TRAP FLAG IS SYSTEM THEN REGISTERS ARE NOT SAVED
;
        LXI     SP,RST1         ;SET TOP ADD. OF MONITORS STACK
        CALL    INIT
        JMP     START
;
TRAP1:  SHLD    SVHL            ;MOVE HL TO (HL) SAVING AREA
        LXI     H,4
        DAD     SP
        SHLD    SVSP            ;MOVE SP (BEFORE OCCURRENCE OF TRAP) TO (SP) SAVING AREA
        POP     PSW             ;RECOVER AF
        POP     H               ;RECOVER PC
        SHLD    SVPC            ;MOVE SAVED PC (CURRENT PC OF USERS) TO (PC) SAVING AREA
        LXI     SP,DATA         ;SET TOP ADD. OF CPU REGISTER SAVING AREA
        PUSH    PSW             ;MOVE AF TO (AF) SAVING AREA
        PUSH    B               ;MOVE BC TO (BC) SAVING AREA
        PUSH    D               ;MOVE DE TO (DE) SAVI*G AREA
        LXI     SP,RST1         ;SET TOP ADD. OF MONITORS STACK
        CALL    INIT
        JMP     BRET
;
INIT:   MVI     A,CTRLW
        OUT     MODES           ;TRANSFER CONTROLE WORD (<MODE 0> PA:IN PB:IN PC:OUT) TO 8255
        MVI     B,SVPC-GOIN     ;SET CLEAR COUNTER
        CALL    CLEAR
        LXI     H,DATA          ;SET TOP ADD, OF CLEAR AREA
        MVI     B,DIG-DATA      ;SET CLEAR COUNTER
        JMP     CLEA1
;
;   <<<   TK-8O MONITOR SUBROUTINE "KEYIN"   >>>
;
        ORG     0216H
        JMP     KEYIN
;
;******************************
;** RST7.5 INTERRUPT PROCESS **
;******************************
;
STEP:   XTHL                    ;EXCHANGE (HL) FOR SAVED PC
        SHLD    SVPC            ;MOVE SAVED PC (CURRENT PC OF USERS) TO (PC) SAVING AREA
        PUSH    PSW             ;SAVE F
        JMP     STEP1
;
;   <<<   TK-8O MONITOR SUBROUTINE "INPUT"   >>>
;
        ORG     0223H
        JMP     INPUT
;
STEP1:  LXI     H,4
        DAD     SP
        SHLD    SVSP            ;MOVE SP (BEFORE OCCURRENCE OF RST7.S) TO (SP) SAVING AREA
        POP     PSW             ;RECOVER AF
        POP     H               ;RECOVER HL
        LXI     SP,DATA         ;SET TOP ADD. OF CPU REGISTER SAVING AREA
        PUSH    PSW             ;MOVE AF TO (AF) SAVING AREA
        PUSH    B               ;MOVE BC TO (BC) SAVING AREA
        PUSH    D               ;MOVE DE TO (DE) SAVING AREA
        PUSH    H               ;MOVE HL TO (HL) SAVING AREA
        LXI     SP,RST1         ;SET TOP ADD. OF MONITORS STACK
;
        XRA     A
        STA     FTRAP           ;SET TRAP FLAG TO SYSTEM (0)
        CALL    BRDPT
        JZ      BRET            ;IF (BD) IS EQUAL TO O THEN DISPLAY PC,AF AND JUMP MONITOR
;
        LHLD    SVBP
        XCHG                    ;DE : BREAK POINT
        LHLD    SVPC            ;HL : PC
        CALL    COMPA           ;IF (PC) IS EQUAL TO (BP) THEN SET ZERO FLAG ELSE RESET ONE
        JNZ     CONT            ;IF (PC) IS NOT EQUAL TO (BP) THEN CONTINUE
        LHLD    SVBD
        DCX     H               ;IF (PC) IS EQUAL TO (BP) THEN DECREMENT (BD)
        SHLD    SVBD
        CALL    BRDPT
        JNZ     CONT            ;IF (BD) IS NOT EQUAL TO O THEN CONTINUE
;
BRET:   LHLD    SVPC
        SHLD    ADRES           ;MOVE (PC) TO (AR)
        LHLD    SVAF
        SHLD    DATA            ;MOVE (AF) TO (DR)
        CALL    CH              ;CONVERT (AR),(DR) INTO (ADW),(DDW)
        JMP     START
;
BRDPT:  LDA     SVBD
        ANA     A
        RNZ
        LDA     SVBD+1
        ANA     A
        RET
;
;******************************
;**  WRITE ENTER KEY PROCESS **
;******************************
;
WTENT:  LDA     FMODE
        ANA     A
        JNZ     PRMOD           ;IF MODE FLAG IS ON THEN JUMP EACH MODE FUNCTION PROCESS
;
        LDA     FREG
        ANA     A
        JNZ     PRREG           ;IF REG FLAG IS ON THEN MODIFY REGISTER AND DISPLAY NEXT ONE
;
        LHLD    ADRES
        LDA     DATA
        MOV     M,A             ;WRITE MEMORY
        CMP     M               ;READ AFTER WRITE
        JNZ     ERR             ;IF WE COULD NOT WRITE DATA TO MEMORY THEN DISPLAY E-MESSAGE
        JMP     RDINC
;
;******************************
;**     MODIFY REGISTER      **
;******************************
;
PRREG:  LXI     H,TRGAD         ;SET TOP ADD. OF SAVING REGISTER ADD.'S TABLE
        MVI     B,1             ;SET POINTER OF NEXT REGISTER
        LDA     FREG            ;GET REGISTER FLAG
        RRC
RSIFT:  RRC
        JC      DTSET           ;IF EACH REGISTER FLAG BIT IS ON THEN MODIFY ITS DATA
        INX     H
        INX     H
        INR     B
        JMP     RSIFT
;
DTSET:  MOV     A,M
        INX     H
        MOV     H,M
        MOV     L,A
        LDA     DATA
        MOV     M,A             ;NODIFY (REGISTER SAVING AREA)L
        INX     H
        LDA     DATA+1
        MOV     M,A             ;MODIFY (REGISTER SAVING AREA)H
        MOV     A,B
        XRI     7
        JNZ     REGFN
        MOV     B,A             ;IF B IS EQUAL TO 7 THEN INITIALIZE B BECAUSE OF REPEATING
        JMP     REGFN
;
;******************************
;** JUMP EACH MODE FUNCTION  **
;******************************
;
PRMOD:  RLC
        JC      FIN             ;JUMP IN PROCESS
        RLC
        JC      FOUT            ;JUMP OUT PROCESS
        RLC
        JC      FMOV            ;JUMP MOVE PROCESS
        RLC
        JC      FTM             ;JUMP TM PROCESS
        RLC
        JC      FLOAD           ;JUMP LOAD PROCESS
        JMP     FSAVE           ;JUMP SAVE PROCESS
;
;******************************
;**       IN PROCESS         **
;******************************
;
FIN:    LDA     ENTCT
        ANA     A
        JNZ     PIN             ;IF ENTCNT IS NOT EQUAL TO O THEN EXECUTE IN INSTRUCTION
        INR     A
        STA     ENTCT           ;INCREMENT ENTCNT
        LDA     DATA
        STA     PORTI           ;SET IN PORT ADD.
        CALL    WORDC
        SHLD    ADW4            ;SET IN PORT ADD.
PIN:    CALL    GOIN            ;EXECUTE IN INSTRUCTION
        STA     DATA            ;SET INPUT DATA
        CALL    WORDC
        SHLD    DDW4            ;SET INPUT DATA
OUTIN:  CALL    CD12            ;CLEAR (DDW1,2) & (DR)H
        JMP     START
;
;******************************
;**       OUT PROCESS        **
;******************************
;
FOUT:   LDA     ENTCT
        ANA     A
        JNZ     POUT            ;IF ENTCNT NOT EQUAL TO O THEN EXECUTE OUT INSTRUCTION
;
        INR     A
        STA     ENTCT           ;INCREMENT ENTCNT
        LDA     DATA
        STA     PORTO           ;SET OUT PORT ADD.
        CALL    WORDC
        SHLD    ADW4            ;SET OUT PORT ADD.
        JMP     DTCLA
;
POUT:   LDA     DATA            ;GET OUT DATA
        CALL    GOOUT           ;EXECUTE OUT INSTRUCTION
        JMP     OUTIN
;
;******************************
;**   TEST MEMORY PROCESS    **
;******************************
;
FTM:    LDA     ENTCT
        ANA     A
        JNZ     FTM1            ;IF ENTCNT IS NOT EQUAL TO O THEN FTM1
        INR     A
        STA     ENTCT           ;INCREMENT ENTCNT
        CALL    ARSET           ;MOVE (DR) TO (AR)
        SHLD    SVDAT           ;SAVE START ADD.
        CALL    AWCH            ;CONVERT (AR) INTO (ADW)
        JMP     DTCLA
;
FTM1:   XRA     A
        MOV     C,A             ;GET TEST DATA
        LHLD    DATA
        XCHG                    ;DE : END ADD.
;
FTM2:   LHLD    SVDAT           ;HL : START ADD.
        CALL    ERRMS           ;IF START ADD. IS GREATER THAN END ADD. THEN ERROR
        MOV     B,C
        DCX     H
FTM3:   INX     H
        MOV     M,B             ;WRITE TEST DATA
        INR     B
        CALL    COMPA
        JNZ     FTM3
;
        MOV     B,C             ;INITIALIZE TEST DATA
        LHLD    SVDAT           ;INITIALIZE START ADD.
        DCX     H
FTM4:   INX     H
        MOV     A,B
        CMP     M               ;COHPARE EXPECTED VALUE WITH READ DATA
        JNZ     ERROR           ;IF EXPECTED VALUE IS DIFFERENT FROM READ DATA THEN ERROR
FTM5:   INR     B
        CALL    COMPA
        JNZ     FTM4
        INR     C               ;SET NEXT TEST DATA
        JNZ     FTM2            ;IF END OF TEST MEMORY THEN CONTINUE
;
        CALL    CA              ;CLEAR (ADW) & (AR)
        LXI     H,914H
        SHLD    DDW2            ;GET "GO"
        LXI     H, 140DH
        SHLD    DDW4            ;GET DD"
        CALL    FLAGC           ;RESET EACH FLAG
        JMP     START
;
ERROR:  SHLD    ADRES           ;SET ERROR ADD.
        MOV     H,B             ;SET EXPECTED VALUE
        MOV     L,M             ;SET READ DATA
        SHLD    DATA
        PUSH    B
        PUSH    D
        PUSH    H
        CALL    CH
        CALL    SEGCV
        CALL    KEYIN
        POP     H
        POP     D
        POP     B
        CPI     15H
        LHLD    ADRES
        JZ      FTM5            ;IF INPUT DATA IS EQUAL TO ENTER THEN REPEAT
        MOV     B,A
        CALL    FLAGC           ;RESET EACH FLAG
        MOV     A,B
        JMP     STAT1
;
;******************************
;**     MOVE PROCESS         **
;******************************
;
FMOV:   LDA     ENTCT
        ANA     A
        JNZ     FMOV1           ;IF ENTCNT IS GREATER THAN O THEN FOV1
;
        INR     A
        STA     ENTCT           ;INCREMENT ENTCNT
        CALL    ARSET           ;MOVE (DR) TO (AR)
        CALL    AWCH            ;CONVERT (AR) INTO (ADW)
        JMP     DTCLA
;
FMOV1:  RRC
        JNC     FMOV2           ;IF ENTCNT IS GREAIER THAN 1 THEN FMOV2
        MVI     A,2
        STA     ENTCT           ;INCREMENT ENTCNT
        LHLD    DATA
        SHLD    SVDAT           ;SAVE END ADD. OF SOURCE DATA
        XCHG                    ;DE : END ADD. OF SOURCE DATA
        LHLD    ADRES           ;HL : START ADD. OF SOURCE DATA
        SHLD    SVDAT+2         ;SAVE START ADD. OF SOURCE DATA
        CALL    ERRMS           ;IF START ADD. IS GREATER THAN END ADD. THEN ERROR
        JMP     ALCLA
;
FMOV2:  CALL    ARSET           ;MOVE (DR) TO (AR)
        PUSH    H
        CALL    AWCH            ;SET START ADD. OF DESTINATION DATA
        CALL    CD              ;CLEAR (DDW) & (DR)
        CALL    SEGCV           ;SEGMENT DATA CONVERSION
        LHLD    SVDAT
        PUSH    H
        POP     B               ;BC : END ADD. OF SOURCE DATA
        POP     D               ;DE : START ADD. OF DESTINATION DATA
        LHLD    SVDAT+2         ;HL : START ADD. OF SOURCE DATA
;
        CALL    COMPA
        JNC     BTMUP           ;IF HL IS LESS THAN OR EQUAL TO DE THEN EXECUTE BOTTOM OP
                                ;IF HL IS GREATER THAN DE THEN EXECUTE TOP DOWN
        DCX     H
        DCX     D
TPDWN:  INX     H
        INX     D
        MOV     A,M
        STAX    D               ;MOVE DATA
        CALL    CHLBC           ;IF START ADD. IS NOT EQUAL TO END ADD. THEN MOVE AGAIN
        JNZ     TPDWN
;
DSPDE:  XCHG
        SHLD    DATA            ;SET END ADD. OF DESTINATION DATA
        CALL    DWCH            ;CONVERT (DR) INTO (DDW)
        CALL    FLAGC           ;RESET EACH FLAG
        JMP     START
;
BTMUP:  PUSH    B               ;SAVE HL (BC)
        PUSH    B
        PUSH    H
        POP     B
        POP     H               ;EXCHANGE HL FOR BC
        DAD     D
        MOV     A,L
        SUB     C
        MOV     E,A
        MOV     A,H
        SBB     B
        MOV     D,A             ;CALUCULATE (HL+DE-BC) AND SET ITS SOLUTION
        POP     H
        PUSH    D               ;SAVE END ADD. OF DESTINATION BATA
        INX     H
        INX     D
BTUP1:  DCX     H
        DCX     D
        MOV     A,M
        STAX    D               ;MOVE DATA
        CALL    CHLBC           ;IF START ADD. IS NOT EQUAL TO END ADD. THEN MOVE AGAIN
        JNZ     BTUP1
BTUP2:  POP     D               ;RECOVER END ADD. OF DESTINATION DATA
        JMP     DSPDE
;
;******************************
;**      SAVE PROCESS        **
;******************************
;
FSAVE:  LDA     ENTCT
        ANA     A
        JNZ     FSAV1           ;IF ENTCNT IS GREATER THAN O THEN FSAV1
        INR     A
        STA     ENTCT           ;INCREMENT ENTCNT
        LDA     DATA
        STA     SVDAT           ;SAVE FILE NO.
        JMP     ALCLA
;
FSAV1:  RRC
        JNC     FSAV2           ;IF ENTCNT IS GREATER THAN 1 THEN FSAV2
        MVI     A,2
        STA     ENTCT           ;INCREMENT ENTCNT
        CALL    ARSET           ;SET START ADD.
        CALL    AWCH            ;CONVERT (AR) INTO (ADW)
        JMP     DTCLA
;
FSAV2:  LHLD    DATA
        XCHG                    ;DE : END  ADD.
        LHLD    ADRES           ;HL : START ADD.
        CALL    ERRMS           ;IF START ADD. IS GREATER THAN END ADD. THEN ERROR
        PUSH    D               ;SAVE END ADD.
        PUSH    H               ;SAVE START ADD.
        LXI     H,051DH
        SHLD    ADW2            ;GET "S-"
        LDA     SVDAT
        CALL    WORDC
        SHLD    ADW4            ;SET FILE NO.
        CALL    CD              ;CLEAR (DDW) & (DR)
        CALL    SEGCV           ;SEGMENT DATA CONVERSION
;
        MVI     C,0             ;CLEAR CHECK SUM
        CALL    REDER           ;OUTPUT READER TO CMT
        CMP     M               ;7 STATES DUMMY
        MVI     A,KEYWD
        MVI     B,PS4           ;SET PS4 BECAUSE IT TAKES 39 STATES IN THIS INTERVAL
        CALL    SRIOT           ;OUTPUT KEYWORD (END OF FILE'S HEAD)
        INX     H               ;6 STATES DUMMY
        DCX     H               ;6 STATES DUMMY
        CMP     M               ;7 STATES DUMMY
;
        LDA     SVDAT
        MVI     B,PS3           ;SET PS3 BECAUSE IT TAKES 110 STATES IN THIS INTERVAL
        CALL    CKSMO           ;OUTPUT FILE NO.
        NOP                     ;4 STATES DUMMY
        NOP                     ;4 STATES DUMMY
        POP     H               ;RECOVER START ADD.
        POP     D               ;RECOVER END ADD.
        MOV     A,H
        MVI     B,PS3           ;SET PS3 BECAUSE IT TAKES 110 STATES IN THIS INTERVAL
        CALL    CKSMO           ;OUTPUT START ADD.H
        MOV     A,L
        MVI     B,PS4           ;SET PS3 BECAUSE IT TAKES 82 STATES IN THIS INTERVAL
        CALL    CKSMO           ;OUTPUT START ADD.L
        MOV     A,D
        MVI     B,PS4           ;SET PS3 BECAUSE IT TAKES 82 STATES IN THIS INTERVAL
        CALL    CKSMO           ;OUTPUT START ADD.H
        MOV     A,E
        MVI     B,PS4           ;SET PS3 BECAUSE IT TAKES 82 STATES IN THIS INTERVAL
        CALL    CKSMO           ;OUTPUT START ADD.L
        INR     M               ;10 STATES DUMMY
        DCR     M               ;10 STATES DUMMY
        MOV     A,C
        CMA
        INR     A               ;2'S COMPLEMENT
        MVI     B,PS3           ;SET PS3 BECAUSE IT TAKES 110 STATES IN THIS INTERVAL
        CALL    CKSMO           ;OUTPUT ADDRESS CHECKSSUM
;
        LDA     DATA            ;13 STATES DUMMY
        MVI     B,PS3           ;SET PS3 BECAUSE IT TAKES 110 STATES IN THIS INTERVAL
        DCX     H
FSAV3:  INX     H
        MOV     A,M
        CALL    CKSMO           ;OUTPUT DATA
        IN      PORTA           ;10 STATES DUMMY
        MVI     B,PS1           ;SET PS1 BECAUSE IT TAKES 166 STATES IN THIS INTERVAL
        CALL    COMPA
        JNZ     FSAV3
        NOP                     ;4 STATES DUMMY
        CMP     M               ;7 STATES DUMMY
        MOV     A,C
        CMA
        INR     A               ;2'S COMPLEMENT
        MVI     B,PS2           ;SET PS2 BECAUSE IT TAKES 180 STATES IN THIS INTERVAL
        CALL    CKSMO           ;OUTPUT DATA CHECK SUM
;
        CALL    CD              ;CLEAR (DDW) & (DR)
        CALL    FLAGC           ;RESET EACH FLAG
        JMP     START
;
CKSMO:  PUSH    PSW
        ADD     C
        MOV     C,A
        POP     PSW
        STA     DIG+7           ;DISPLAY OUTPUT DATA
        JMP     SRIOT           ;OUTPUT 1 BYTE TO CMT
;
;******************************
;**      LOAD PROCESS        **
;******************************
;
FLOAD:  LDA     DATA
        PUSH    PSW
        CALL    WORDC
        SHLD    ADW4            ;SET FILE NO.
        LXI     H,051DH
        SHLD    ADW2            ;GET "S-"
        CALL    CD              ;CLEAR (DDW) & (DR)
;
FILE:   CALL    SEGCV           ;SEGMENT DATA CONVERSION
        MVI     C,0             ;CLEAR CHECK SUM
        CALL    RDSCH           ;SEARCH HEAD OF FILE
        CALL    SRIIN
        CPI     KEYWD
        JNZ     FILE            ;IF HEAD  OF FILE WAS FOUND THEN READ FILE NO.
;
        CALL    CKSMI           ;INPUT & DISPLAY FILE NO.
        MOV     D,A
        POP     PSW
        CMP     D
        JZ      FOUND           ;IF FILE NO. IS DIFFERENT FROM SEARCHING ONE THEN IGNORE
;
        PUSH    PSW
        MOV     A,D
        CALL    WORDC
        SHLD    DDW4            ;DISPLAY SKIPPING FILE NO.

        JMP     FILE
;
FOUND:  XRA    A
        STA    DIG+6
        MVI    A,71H
        STA    DIG              ;DISPLAY FILE FOUND MESSAGE
        CALL   CKSMI
        MOV    H,A
        CALL   CKSMI
        MOV    L,A
        CALL   CKSMI
        MOV    D,A
        CALL   CKSMI
        MOV    E,A
        CALL   CKSMI
        JNZ    EREAD            ;IF ADDRESS READ ERROR THEN EREAD
;
        PUSH    H               ;SAVE START ADD.
        DCX     H
LOAD1:  INX     H
        CALL    CKSMI           ;INPUT DATA
        MOV     M,A             ;SET DATA TO MEMORY
        CALL    COMPA
        JNZ     LOAD1
        CALL    CKSMI
        POP     H               ;RECOVER START ADD.
        JNZ     EREAD           ;IF DATA READ ERROR THEN EREAD
;
        SHLD    ADRES           ;SET START ADD.
        XCHG
        SHLD    DATA            ;SET END ADD.
        CALL    CH              ;CONVERT (AR),(DR) INTO (ADW) , (DDW)
        CALL    FLAGC           ;RESET EACH FLAG
        JMP     START
;
EREAD:  MVI     A,0EH
        STA     ADW1            ;SET "E"
        CALL    FLAGC           ;RESET EACH FLAG
        JMP     DTCLA
;
CKSMI:  CALL    SRIIN
        STA     DIG+7           ;DISPLAY INPUT DATA
        MOV     B,A
        ADD     C
        MOV     C,A
        MOV     A,B
        RET
;
;******************************
;**  SEGMENT DATA CONVERSION **
;******************************
;
SEGCV:  LXI     H,ADW1          ;SET ADD. & DATA DISPLAY REGISTER ADD.
        LXI     D,DIG           ;SET SEG BUFF ADD.
        LXI     B,SEGDA         ;SET SEG DATA ADD.
        LDA     FMODE           ;GET MODE FLAG
        ANI     3CH             ;SET MASK OF MODE FLAG
        RLC
        RLC
        PUSH    PSW
SEGRP:  MOV     A,M
        PUSH    H
        MVI     H,0
        MOV     L,A
        DAD     B
        MOV     A,M             ;GET SEG DATA
        STAX    D               ;MOVE SEG DATA TO SEG BUFF
        POP     H
        POP     PSW
        RLC
        PUSH    PSW
        CC      PRIOD           ;IF EACH MODE FLAG IS ON THEN DISPLAY 1 DOT ON (DIG--DIG+3)
        DCX     H
        INR     E
        JNZ     SEGRP
        POP     PSW             ;DUMMY
        LDA     FMODE           ;GET MOOE FLAG
        RRC
        JNC     REGPI           ;IF F-MODE IS ON THEN DISPLAY 4 DOTS ON (DIG--DIG+3)
        MVI     B,4
        LXI     D,DIG
SEGMD:  CALL    PRIOD
        INX     D
        DCR     B
        JNZ     SEGMD
;
REGPI:  LDA     FREG            ;GET REGISTER FLAG
        RRC
        RNC
        LXI     D,DIG+4         ;IF REGISTER FLAG IS ON THEN DISPLAY 1 DOT ON (DIG+4)
PRIOD:  LDAX    D
        ORI     80H
        STAX    D
        RET
SEGDA:  DB      3FH,06H,5BH,4FH,66H,6DH,7DH,27H
        DB      7FH,6FH,77H,7CH,39H,5EH,79H,71H
        DB      76H,1EH,38H,54H,5CH,73H,67H,50H
        DB      3EH,1CH,6EH,74H,00H,40H,80H
;
;******************************
;**  SHIFT (DR),(DDW)        **
;******************************
;
SHIFT:  LHLD    DDW3
        SHLD    DDW2
        LDA     DDW4
        STA     DDW3
        LHLD    DATA
        DAD     H
        DAD     H
        DAD     H
        DAD     H
        SHLD    DATA
        RET
;
;******************************
;**    RESET EACH FLAG       **
;******************************
;
FLAGC:  LXI     H,0
        SHLD    ENTCT          ;CLEAR ENTER COUNTER & RESET TRAP FLAG
        SHLD    FREG           ;RESET REGISTER & NODE FLAG
        MVI     A,1
        RET
;
;******************************
;**        SET BIT           **
;******************************
;
STBIT:  INR     A
        MOV     C,A             ;SET COUNTER
        MVI     A,80H
LSIFT:  RLC                     ;SHIFT LEFT 1 BIT
        DCR     C
        JNZ     LSIFT
        RET
;
;******************************
;**   COMPARE (HL:DE,HL:BC)  **
;******************************
;
COMPA:  MOV     A,D
        CMP     H
        JNZ     NTEQU
        NOP                     ;4 STATES DUMMY
        MOV     A,E
        CMP     L
        RET
NTEQU:  CZ      0               ;9 STATES DUMMY
        RET                     ;IF HL IS EQUAL TO DE THEN SET ZERO FLAG
                                ;IF HL IS NOT EQUAL TO DE THEN RESET ZERO FLAG
                                ;IF HL IS GREATER THAN DE THEN SET CARRY FLAG
                                ;IF HL IS LESS THAN OR EQUAL TO OE THEN RESET CARRY FLAG
                                ;IT TAKES 37 STATES IN THIS SUBROUTINE
CHLBC:  MOV     A,B
        CMP     H
        RNZ
        MOV     A,C
        CMP     L
        RET                     ;IF HL IS EQUAL TO BC THEN SET ZERO FLAG
                                ;IF HL IS NOT EQUAL TO BC THEN RESET ZERO FLAG
;
ERRMS:  CALL    COMPA
        RNC
        POP     H
ERR:    LXI     H,1C0EH
        SHLD    ADW2            ;GET ' E'
        LXI     H,1717H
        SHLD    ADW4            ;GET 'RR'
        CALL    FLAGC           ;RESET EACH FLAG
        JMP     DTCLA
                                ;IF HL IS GREATER THAN THEN DE THEN DISPLAY ERROR MESSAGE
                                ;         ELSE RETURN AND CONTINUE
;
;******************************
;**     CLEAR DISP REG       **
;******************************
;
CA:     LXI     H,1C1CH
        SHLD    ADW2
        SHLD    ADW4            ;PUT OUT ADD.DISPLAY
        LXI     H,0
        SHLD    ADRES           ;SET 0 IN (AR)
        RET
;
CD:     LXI     H,1C1CH
        SHLD    DDW4            ;PUT OUT L. DATA DISPLAY
        XRA     A
        STA     DATA            ;SET 0 IN (DR)L
CD12:   LXI     H,1C1CH
        SHLD    DDW2            ;PUT OUT H.DATA DISPLAY
        XRA     A
        STA     DATA+1          ;SET 0 IN (DR)H
        RET
;
;******************************
;** (ADW),(DDW)<--(AR),(DR)  **
;******************************
;
CH:     CALL    DWCH
                                ;CONVERT (AR),(DR) INTO  (ADW),(DDW)
AWCH:   LDA     ADRES+1
        CALL    WORDC
        SHLD    ADW2            ;CONVERT (AR)H INTO (ADW1,2)
        LDA     ADRES
        CALL    WORDC
        SHLD    ADW4            ;CONVERT (AR)L INTO (ADW3,4)
        RET
;
DWCH:   LDA     DATA+1
        CALL    WORDC
        SHLD    DDW2            ;CONVERT (DR)H INTO (DDW1,2)
DLWCH:  LDA     DATA
        CALL    WORDC
        SHLD    DDW4            ;CONVERT (DR)L INTO (DDW3,4)
        RET
;
WORDC:  MOV     B,A
        ANI     0FH
        MOV     L,A
        MOV     A,B
        RRC
        RRC
        RRC
        RRC
        ANI     0FH
        MOV     H,A
        RET                     ;CONVERT A INTO HL
;
;******************************
;**         KEY IN           **
;******************************
;
KEYIN:  CALL    INPUT
        LDA     FKEY            ;GET KEY FLAG
        ANA     A
        JZ      KEYIN           ;IF THERE IS NOT KEY INPUT THEN KEYIN
        MOV     A,B
        RET
;
;******************************
;**        KEY INPUT         **
;******************************
;
INPUT:  CALL    KEY
        INR     A
        JZ      NOKEY           ;IF THERE IS NOT KEY INPUT THEN NOKEY
INPRP:  MVI     D,MSEC9         ;SET DELAY TIMER
        MVI     E,0
        CALL    DELEN           ;WAIT CHATTERRING TIME
        DCR     D
        JNZ     INPRP+2
        CALL    KEY
        MOV     B,A
        INR     A
        JZ      NOKEY           ;IF THERE IS NOT KEY INPUT THEN NOKEY
        LDA     FKEY            ;GET KEY FLAG
        ANA     A
        JNZ     INPRP           ;IF KEY FLAG IS EQUAL TO FF THEN INPRP
        DCR     A               ;SET FF
SETKF:  STA     FKEY            ;SET KEY FLAG
        MOV     A,B             ;SET INPUT DATA
        RET
NOKEY:  MVI     B,0FFH
        JMP     SETKF
;
;******************************
;**        KEY SCAN          **
;******************************
;
KEY:    XRA     A               ;CLEAR A
        MOV     D,A             ;CLEAR D
        MOV     B,A             ;CLEAR B
        MVI     A,PC4
        CALL    SCAN
        MVI     B,8
        MVI     A,PC5
        CALL    SCAN
        MVI     B,10H
        MVI     A,PC6
        CALL    SCAN
        DCR     A               ;SET FF
        RET
SCAN:   OUT     PORTC           ;SCAN EACH BIT OF PORT C
        IN      PORTA           ;INPUT DATA FROM PORT A
        CMA
        ANA     A
        RZ
        POP     H               ;DUMMY
KEY1:   RRC
        JC      KEY2
        INR     D
        JMP     KEY1
KEY2:   MOV     A,D
        ORA     B
        RET
;
;******************************
;**  OUTPUT READER FOR 5SEC  **
;******************************
;
REDER:  PUSH    B               ;SAVE BC
        PUSH    H               ;SAVE HL
        LXI     H,SEC5          ;SET LOOP COUNTER
;
REDR1:  CALL    ONEOT           ;OUTPUT '1'
        MOV     B,M             ;7 STATES DUMMY
        MVI     B,PRA           ;SET DELAY COUNTER
        DCR     L
        JNZ     REDR1
;
        IN      PORTA           ;10 STATES DUMMY
        MVI     B,PRB           ;SET DELAY COUNTER
        DCR     H
        JNZ     REDR1
;
        POP     H               ;RECOVER HL
        POP     B               ;RECOVER BC
        RET
;
;******************************
;**     OUTPUT ONE BYTE      **
;******************************
;
SRIOT:  PUSH    B               ;SAVE BC
        PUSH    D               ;SAVE DE
        PUSH    H               ;SAVE HL
;
        MOV     C,A             ;SAVE 1 BYTE DATA
        CALL    ZEROT           ;WRITE START BIT (0)
        LXI     D,P10           ;SET DELAY COUNTER
        MOV     A,M             ;7 STATES DUMMY
        MVI     L,8             ;SET LOOP COUNTER
;
SROT1:  MOV     A,C             ;RECOVER 1 BYTE DATA
        RAR
        MOV     C,A             ;SAVE 1 BYTE DATA
        JC      SROT2           ;IF DATA IS EQUAL TO '1' THEN JUMP
        MOV     B,E             ;SET DELAY COUNTER
        IN      PORTA           ;10 STATES DUMMY
        MOV     A,M             ;7 STATES  DUMMY
        CALL    ZEROT           ;WRITE 1 BIT (0)
        JMP     SROT3
;
SROT2:  MOV     B,D             ;SET DELAY COUNTER
        IN      PORTA           ;10 STATES DUMMY
        IN      PORTA           ;10 STATES DUMMY
        CALL    ONEOT           ;WRITE 1 BIT (1)
        IN      PORTA           ;10 STATES DUMMY
;
SROT3:  DCR     L
        JNZ     SROT1           ;IF END OF 8 BITS THEN CONTINUE
;
        MVI     B,POA           ;SET DELAY COUNTER
        CALL    ONEOT           ;WRITE END BIT (1)
        MOV     A,M             ;7 STATES DUMMY
        MVI     B,POB           ;SET DELAY COUNTER
        CALL    ONEOT           ;WRITE END BIT (1)
;
        POP     H               ;RECOVER HL
        POP     D               ;RECOVER DE
        POP     B               ;RECOVER BC
        RET
;
;******************************
;**     OUTPUT ONE BIT       **
;******************************
;
ONEOT:  MVI     A,HIGH          ;SET WAVE TO HIGH
        CALL    WVCG1           ;CHANGE WAVE FROM HIGH TO LOW
        CALL    WVCHG           ;CHANGE WAVE FROM LOW TO HIGH
        CALL    WVCHG           ;CHANGE WAVE FROM HIGH TO LOW
        CALL    WVCHG           ;CHANGE WAVE FROM LOW TO HIGH
        RET
;
ZEROT:  MVI     A,HIGH          ;SET WAVE TO HIGH
        CALL    WVCG1           ;CHANGE WAVE FROM HIGH TO LOW
        NOP                     ;4 STATES DUMMY
        NOP                     ;4 STATES DUMMY
        MVI     B,PO0           ;SET DELAY COUNTER
        CALL    WVCG1           ;CHANGE WAVE FROM LOW TO HIGH
        RET
;
WVCHG:  MVI     B,PO1           ;SET DELAY COUNTER
WVCG1:  DCR     B
        JNZ     WVCG1           ;DELAY HALF CYCLE
        INX     B               ;6 STATES DUMMY
        DCX     B               ;6 STATES DUMMY
        NOP                     ;4 STATES DUMMY
        RAL
        CMC                     ;CHANGE WAVE DATA
        RAR
        SIM                     ;OUTPUT SERIAL DATA
        RET
;
;******************************
;**      READER SEARCH       **
;******************************
;
RDSCH:  PUSH    B               ;SAVE BC
        PUSH    D               ;SAVE DE
;
        RIM                     ;SERIAL INPUT
        MOV     B,A             ;SAVE INPUT DATA
RDSC1:  MVI     D,0             ;CLEAR 256 COUNTER
RDSC2:  MVI     E,0             ;CLEAR DELAY COUNTER
        CALL    SERCH           ;SEARCH WAVE CHANGE
        MVI     A,BIMAX         ;SET DELAY COUNTER TO MAX. THRESHOLD OF DATA '1'
        CMP     E
        JC      RDSC1           ;IF NOT READER THEN SEARCH READER AGAIN
        MVI     A,BIMIN         ;SET DELAY COUNTER TO MIN. THRESHOLD OF DATA '1'
        CMP     E
        JNC     RDSC1           ;IF NOT READER THEN SEARCH READER AGAIN
        INR     D
        JNZ     RDSC2           ;IF FREQUENCY OF 256 WAVES IS EQUAL TO 2400HZ THEN CONTINUE
;
        POP    D                ;RECOVER DE
        POP    B                ;RECOVER BC
        RET
;
;******************************
;**    INPUT ONE BYTE        **
;******************************
;
SRIIN:  PUSH    B               ;SAVE BC
        PUSH    D               ;SAVE DE
        PUSH    H               ;SAVE HL
;
        RIM                     ;SERIAL INPUT
        MOV     B,A             ;SAVE INPUT DATA
SRII1:  MVI     E,0             ;CLEAR DELAY COUNTER
        CALL    SERCH           ;SEARCH WAVE CHANGE
        MVI     A,BOFWD         ;SET DELAY COUNTER TO THRESHOLD OF DATA '0'
        CMP     E
        JNC     SRII1           ;IF DATA IS EQUAL TO 1 THEN SEARCH START BIT AGAIN
;
        MVI     A,BOBCK         ;SET DELAY COUNTER
        CALL    DELE1           ;DELAY
        MVI     L,8             ;SET 8BITS LOOP COUNTER
SRII2:  CALL    ONEIN           ;INPUT ONE BIT DATA
        MOV     A,H             ;LOAD ONE BYTE DATA
        RAR
        MOV     H,A             ;STORE ONE BYTE DATA
        CALL    DELEN           ;DELAY
        DCR     L
        JNZ     SRII2           ;IF END OF B BITS TYEN CONTINUE
        MOV     A,H             ;SET ONE BYTE DATA TO A
;
        POP     H               ;RECOVER HL
        POP     D               ;RECOVER DE
        POP     B               ;RECOVER BC
        RET
;
;******************************
;**     INPUT ONE BIT        **
;******************************
;
ONEIN:  CALL    SERCH           ;SEARCH WAVE CHANGE
ONEI1:  MVI     A,C58TH         ;SET DELAY COUNTER
        MVI     E,0             ;CLEAR DELAY COUNTER
        CALL    DELE1           ;DELAY FOR 5/8 CYCLE
        CALL    SERCH           ;SEARCH WAVE CHANGE
        MVI     A,C58TH+2       ;LOAD DATA THRESHOLD
        CMP     E
        RET                     ;IF ONE BIT DATA IS EQUAL TO '1' THEN SET CARRY
                                ;IF ONE BIT DATA IS EQUAL TO '0' THEN RESET CARRY
;
;******************************
;**      DELAY TIMER         **
;******************************
;
DELEN:  MVI     A,DELAY         ;SET DELAY COUNTER
DELE1:  INR     E
        NOP                     ;4 STATES DUMMY
        CMP     E
        JNC     DELE1
        RET
;
;******************************
;**   SEARCH WAVE CHANGE     **
;******************************
;
SERCH:  INR     E
        RIM                     ;SERIAL INPUT
        XRA     B
        JZ      SERCH           ;WAVE NOT CHANGE THEN SEARCH AGAIN
        XRA     B
        MOV     B,A             ;SAVE INPUT DATA
        RET
;
;******************************
;**   DISPLAY (AR),(DR)      **
;******************************
;
RGDSP:  LXI     H,ADRES+1
        LXI     D,DISP
        MVI     B,4
RGDS1:  MOV     A,M
        STAX    D
        DCX     H
        INX     D
        DCR     B
        JNZ     RGDS1
;
;******************************
;** SEGMENT DATA CONVERSION  **
;******************************
;
SEGCG:  MVI     B,4
        LXI     H,DISP
        LXI     D,ADW1
SEGC1:  MOV     A,M
        CALL    SEGC2
        MOV     A,M
        CALL    SEGC3
        INX     H
        DCR     B
        JNZ     SEGC1
        JMP     SEGCV
SEGC2:  RRC
        RRC
        RRC
        RRC
SEGC3:  ANI     0FH
        STAX    D
        DCX     D
        RET
;
;******************************
;**     WORKING AREA         **
;******************************
;
        ORG     8391H
USESP:  DS      20H
RST1:   DS      3
RST2:   DS      3
RST3:   DS      3
RST4:   DS      3
RST5:   DS      3
RST55:  DS      3
RST6:   DS      3
RST7:   DS      3
GOIN:   DS      1
PORTI:  DS      2
GOOUT:  DS      1
PORTO:  DS      2
DDW4:   DS      1
DDW3:   DS      1
DDW2:   DS      1
DDW1:   DS      1
ADW4:   DS      1
ADW3:   DS      1
ADW2:   DS      1
ADW1:   DS      1
SVDAT:  DS      4
ENTCT:  DS      1
FTRAP:  DS      1
FKEY:   DS      1
FREG:   DS      1
FMODE:  DS      1
SVPC:   DS      2
SVSP:   DS      2
SVHL:   DS      2
SVDE:   DS      2
SVBC:   DS      2
SVAF:   DS      2
DATA:   DS      2
ADRES:  DS      2
SVBP:   DS      2
SVBD:   DS      2
DISP:   DS      4
DIG:    DS      8
;
;******************************
;**        EQU TABLE         **
;******************************
;
CTRLW   EQU     92H
MSKRS   EQU     98H
KEYWD   EQU     55H
MODES   EQU     0FBH
PORTC   EQU     0FAH
PORTA   EQU     0F8H
PC4     EQU     0EFH
PC5     EQU     0DFH
PC6     EQU     0BFH
MSEC9   EQU     14
SEC5    EQU     1770H
PS1     EQU     49
PS2     EQU     48
PS3     EQU     53
PS4     EQU     55
PRA     EQU     28
PRB     EQU     26
P10     EQU     193EH
POA     EQU     28
POB     EQU     29
PO0     EQU     68
PO1     EQU     32
HIGH    EQU     0D8H
BIMAX   EQU     31
BIMIN   EQU     8
BOFWD   EQU     32
BOBCK   EQU     74
C58TH   EQU     53
DELAY   EQU     71
BSBRK   EQU     0F125H
END