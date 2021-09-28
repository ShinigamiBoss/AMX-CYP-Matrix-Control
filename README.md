# AMX-CYP-Matrix-Control

This AMX module allow control of the CYP AV Matrix

## Module instruction

The use of this module is intended for network control via the CYP telnet port.
The module assumes that the following channel number are assigned to the GUI buttons:
1 - 16 for input button
101 - 116 : for output buttons
The module supports up to 16 inputs and 16 outputs.
How setup the module:

1. define the network device and port for network communication (example: CYP_Matrix = 0:4:1)
2. define a virtual device for send and receive commands from the module (example: vdvMatrix = 33001:1:0)
3. create and define a UI device (example: an AMX touch screen, dvTP = 10001:1:0)
4. define the module and pass the mentioned ariguments

## Command list

The module supports the following commands, the commands must be sent to the virtual device:

1. 'IP_ADDRESS-XXX.XXX.XXX.XXX' : set the IP Address and connect to the device, the parameter XXX.XXX.XXX.XXX is the IP Address of the machine
2. 'ROUTE-IN,OUT' : the the input to the output, IN: an integer between 1 and 16, OUT: an integer between 1 and 16
3. 'SET_IN_NAME-INDEX,VALUE' : set the input names for routing purposes, INDEX: integer between 1 and 16, VALUE: the name to assign
4. 'SET_OUT_NAME-INDEX,VALUE' : set the output names for routing purposes, INDEX: integer between 1 and 16, VALUE: the name to assign

----------------------------------------------------------------------------------------------------------------
Please consider donating for more work and projects: [PayPal](<https://paypal.me/shinigamiboss?locale.x=en_US>
