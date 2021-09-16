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
CHAR InNameSetCmd[] = 'SET_IN_NAME-'
CHAR OutNameSetCmd[] = 'SET_OUT_NAME-'
CHAR GuiInNameSetCmd[] = 'SET_GUI_IN_NAME-'
CHAR GuiOutNameSetCmd[] = 'SET_GUI_OUT_NAME-'
CHAR SetGUIStateCmd[] = 'GUI_STATES-'
CHAR RefreshGUI[] = 'REFRESH_GUI'

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

PERSISTENT INTEGER GUIState = 1

//Route output names
PERSISTENT CHAR OutNames[16][256] = {
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

//Route input names
PERSISTENT CHAR InNames[16][256] = {
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

//Name sent to the User interface
PERSISTENT CHAR GuiOutNames[16][256] = {
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

//Name sent to the User interface
PERSISTENT CHAR GuiInNames[16][256] = {
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

//Used for loopa
INTEGER x=0
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

DEFINE_FUNCTION UpdateGUINames()
{
    FOR (x = 1; x <= 16; x++)
    {
        SEND_COMMAND vdvTP,"'^TXT-',ITOA(x),',',ITOA(GUIState),',',GuiInNames[x]"
	
	SEND_COMMAND vdvTP,"'^TXT-',ITOA(x + 100),',',ITOA(GUIState),',',GuiOutNames[x]" 
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
        UpdateGUINames()   
    }
    OFFLINE: 
    {
        
    }
    COMMAND: 
    {
        LOCAL_VAR CommandText[256]
        CommandText = DATA.TEXT

        //IP Address setup and connection
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

        //Route command
        if(FIND_STRING(CommandText,RouteCmd,1))
        {
            LOCAL_VAR INTEGER in
            LOCAL_VAR INTEGER out
            LOCAL_VAR CHAR substr[256]

            REMOVE_STRING(CommandText, RouteCmd, 1)

            substr = REMOVE_STRING(CommandText, ',',1)

            in = ATOI(substr)
            out = ATOI(CommandText)
            if (in > 0 and in <= 16)
            {
                if(out > 0 and out <= 16)
                {
                    RouteSignal(in,out)
                }
            }
        }
        
        //Set input name, please note that it will affect the routing!!!
        if(FIND_STRING(CommandText, InNameSetCmd,1))
        {
            LOCAL_VAR  INTEGER Index
            REMOVE_STRING(CommandText,InNameSetCmd,1)

            index = AtOI(REMOVE_STRING(CommandText,',',1))
            if(index > 0 and index <= 16)
            {
                InNames[index] = CommandText
            }
        }

        //Set output name, please note that it will affect the routing!!!
        if(FIND_STRING(CommandText, OutNameSetCmd,1))
        {
            LOCAL_VAR  INTEGER Index
            REMOVE_STRING(CommandText,OutNameSetCmd,1)

            index = AtOI(REMOVE_STRING(CommandText,',',1))
            if(index > 0 and index <= 16)
            {
                OutNames[index] = CommandText
            }
        }

        //Set the GUI Input Names
        if(FIND_STRING(CommandText,GuiInNameSetCmd,1))
        {
            LOCAL_VAR INTEGER index
            REMOVE_STRING(CommandText,GuiInNameSetCmd,1)

            index = AtOI(REMOVE_STRING(CommandText,',',1))
            if (index > 0 and index <=16)
            {
                GuiInNames[index] = CommandText
            }
            UpdateGUINames()
        }

        //Set the GUI Output Names
        if(FIND_STRING(CommandText,GuiOutNameSetCmd,1))
        {
            LOCAL_VAR INTEGER index
            REMOVE_STRING(CommandText,GuiOutNameSetCmd,1)
            index = AtOI(REMOVE_STRING(CommandText,',',1))
            if (index > 0 and index <=16)
            {
                GuiOutNames[index] = CommandText
            }
            UpdateGUINames()
        }

        //Set the panel button state for GUI names:
        //0: All States
        //1: Off state
        //2: On state
        //1-256 for multi state button
        if(FIND_STRING(CommandText,SetGUIStateCmd,1))
        {
            LOCAL_VAR INTEGER State
            FIND_STRING(CommandText,SetGUIStateCmd,1)
            State = ATOI(CommandText) 
            if(state <= 256)
            {
                GUIState = State
            }
        }

        if(FIND_STRING(CommandText,RefreshGUI,1))
        {
            UpdateGUINames()
        }
        

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