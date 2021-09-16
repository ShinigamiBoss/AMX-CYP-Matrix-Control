MODULE_NAME='AMX CYP Module' (DEV vdvMatrix, DEV dvMatrix, DEV vdvTP)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/04/2006  AT: 11:33:16        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)    
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

//Commands variables
CHAR IpSetCmd[] = 'IP_ADDRESS-'
CHAR RouteCmd[] = 'ROUTE-'

//Telnet Commands
CHAR RouteZoneTel[] = 'ZoneAvPair '
CHAR LoadTel[] = 'Load'

//Constants
INTEGER TelnetPort = 23
CHAR Terminator = $0D


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

//Store IP Address
CHAR MatrixIP[16] = '192.168.1.1'
//Store input to switch
INTEGER InputSwitch = 0
//Store output to switch
INTEGER  OutputSwitch = 0

CHAR OutNames[16][256] = {
    {'HDBT_Out A'},
    {'HDBT_Out B'},
    {'HDBT_Out C'},
    {'HDBT_Out D'},
    {'HDBT_Out E'},
    {'HDBT_Out F'},
    {'HDBT_Out G'},
    {'HDBT_Out H'},
    {'HDBT_Out I'},
    {'HDBT_Out L'},
    {'HDBT_Out M'},
    {'HDBT_Out N'},
    {'HDBT_Out O'},
    {'HDBT_Out P'},
    {'HDBT_Out Q'},
    {'HDBT_Out R'}
}

CHAR InNames[16][256] = {
    {'Slot 1'},
    {'Slot 2'},
    {'Slot 3'},
    {'Slot 4'},
    {'Slot 5'},
    {'Slot 6'},
    {'Slot 7'},
    {'Slot 8'},
    {'Slot 9'},
    {'Slot 10'},
    {'Slot 11'},
    {'Slot 12'},
    {'Slot 13'},
    {'Slot 14'},
    {'Slot 15'},
    {'Slot 16'}

}

//Keep track of the network connection
INTEGER ConnectionStatus = 0

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

DEFINE_FUNCTION RouteSignal (INTEGER in, INTEGER Out)
{
    if (ConnectionStatus == 0)
    {
        IP_CLIENT_OPEN(dvMatrix.PORT, MatrixIP, TelnetPort, IP_TCP)
    }
    
    WAIT 5
    {
        SEND_STRING dvMatrix,"RouteZoneTel, OutNames[Out],' ', InNames[In], ' ', LoadTel, Terminator "
    }
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[vdvMatrix]
{
    ONLINE:
    {
        
    }
    OFFLINE: 
    {
        
    }
    COMMAND: 
    {
        LOCAL_VAR CommandText[256]
        CommandText = DATA.TEXT

        if(FIND_STRING(CommandText,IpSetCmd,1))
        {
            REMOVE_STRING(CommandText,IpSetCmd,1)
            MatrixIP = CommandText
            
            if(ConnectionStatus == 1)
            {
                IP_CLIENT_CLOSE(dvMatrix.PORT)
            }

            IP_CLIENT_OPEN(dvMatrix.PORT,MatrixIP,TelnetPort,IP_TCP)
            
            
        }

        if(FIND_STRING(CommandText,RouteCmd,1))
        {
            LOCAL_VAR INTEGER in
            LOCAL_VAR INTEGER out
            LOCAL_VAR CHAR substr[256]

            REMOVE_STRING(CommandText, RouteCmd, 1)

            substr = REMOVE_STRING(CommandText, ',',1)

            in = ATOI(substr)
            out = ATOI(CommandText)
            RouteSignal(in,out)
        }
        

    }
    STRING:
    {
        LOCAL_VAR CHAR Response[256]

        Response = DATA.TEXT
    }
}

DATA_EVENT[dvMatrix]
{
    ONLINE:
    {
        ConnectionStatus = 1
    }
    OFFLINE: 
    { 
        ConnectionStatus = 0
    }
    
    ONERROR:
    {
        ConnectionStatus = 0
    }
}

(*****************************************************************)
(*                                                               *)
(*                      !!!! WARNING !!!!                        *)
(*                                                               *)
(* Due to differences in the underlying architecture of the      *)
(* X-Series masters, changing variables in the DEFINE_PROGRAM    *)
(* section of code can negatively impact program performance.    *)
(*                                                               *)
(* See â€œDifferences in DEFINE_PROGRAM Program Executionâ€ section *)
(* of the NX-Series Controllers WebConsole & Programming Guide   *)
(* for additional and alternate coding methodologies.            *)
(*****************************************************************)

DEFINE_PROGRAM

(*****************************************************************)
(*                       END OF PROGRAM                          *)
(*                                                               *)
(*         !!!  DO NOT PUT ANY CODE BELOW THIS COMMENT  !!!      *)
(*                                                               *)
(*****************************************************************)