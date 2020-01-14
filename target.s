section .data 
extern temp1
extern Rstate
extern MAX_INT
extern Rstate32bit
extern floatNum
extern range
extern rangeFloat
extern numco
extern constRange
extern constRangeFloat
extern maxAlpha
extern constPi
extern temp1
extern temp2
extern currentDroneToRun
extern numStepsToPrint
extern currentStepNum
extern numDestroyToWin
extern betaTemp
extern beta
extern gamma
extern maxDistance
extern NumOfDrones
extern droneIdCounter

section .bss
extern Drones
extern currDrone
extern RestCors
extern CURR
extern SPT
extern SPMAIN
extern schedulerStruct
extern printerStruct
extern targetStruct

section	.rodata	
    extern formatTarget
    extern formatDrone
    extern formatCheckArgs
    extern formatCheckRandom
    extern winner_format
    extern formatMyId
    extern argBuffer
   
    STKSIZE equ 16*1024
    CODEP equ 0
    SPP equ 4
    droneId equ 32
    Xposition equ 8
    Yposition equ 16
    alphaPosition equ 24
    numOfTargetsDestroyedPos equ 36
    DroneSize equ  40 ; func , stack pointer ,  x , y , alpha ,id, num of targets destroyed.
    TargetSize equ 24 ; func , stack pointer, x , y
    RANDOM_MASK equ 0x2D



section .text
global targetFunc
extern generateRandom
extern scaleRandom
extern endCo
extern resume
extern printf





targetFunc:
    call createTarget
    mov ebx,[schedulerStruct]
    push targetFunc ;push the function for next time
    jmp resume
createTarget:
    push ebp
    mov ebp,esp
    call generateRandom ;random for X
    push dword 100
    call scaleRandom ; scale for [0,100] range
    add esp,4
    finit
    fld qword [floatNum]
    mov eax,[targetStruct]
    fstp qword [eax+Xposition] ;put X in its position in the struct 
    finit
    call generateRandom ;;random for Y
    push dword 100 
    call scaleRandom ;; scale for [0,100] range
    add esp,4
    finit
    fld qword [floatNum]
    mov eax,[targetStruct]
    fstp qword [eax+Yposition] ; ;put Y in its position in the struct 
    mov esp,ebp
    pop ebp
    ret   