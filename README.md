# I2C_State_Machine
This repo contains an I2C transaction state machine modelled in Verilog targeted for the Zynq Zedboard

**_I2C working principles:_**
![image](https://github.com/user-attachments/assets/a8a9f684-e550-4a2a-a5a2-f1288986eeee)

- The I2C transaction between a master and a slave device follows the above timing sequence.
- Whenever a transaction has to be initiated, a START bit is executed which is essentially toggling the SDA line low when the SCL line is high. This indicates that the master wants to initiate an I2C transaction.
- Once the I2C transaction has started, the master will then follow up with 7-bit address of the slave it wants to transact with. The address bits will need to be toggled accordingly and will be sampled at every SCL clock level high.
- The eighth bit is a READ / WRITE bit. In our experiment it shall be ‘1’ to indicate a read transaction meaning the master wants to read 8-bit data from the slave. This will be followed by an ACK bit controlled by the slave device indicating the responsible slave has recognized the I2C transaction and will prepare to send the data.
- The slave then takes control of the SDA line completely and will toggle the line as per the DATA bits which shall once again be sampled at every high level of SCL. The master will then send out an ACK bit stating that the master has successfully registered the data on the SDA lines.
- The I2C transaction will then end over a STOP bit, essentially SDA going low after the SCL has gone low. This indicates the master wants to terminate the I2C transaction for the period.

**_Behavioral simulation:_**

![image](https://github.com/user-attachments/assets/0f414e46-c8b7-4e9b-a460-3dd8aba24668)

The design and testbench also handle NACK scenarios as described below:

**_Scenario 1 – No ACK from the slave:_**

When the master writes a wrong address, and the slave does not respond hence the master keeps trying with that address. In the below scenario the master tries sending an address 0x77 and no ACK is received from the slave so the master retries sending the address over and over again till an ACK can be received by the slave. But this will never happen as the slave (testbench) is designed to respond to address 0x78:

 ![image](https://github.com/user-attachments/assets/fe955b31-758b-4705-abca-0cdd794a2ddb)

As can be seen in the above waveform, the master reverts to state 2 (SEND_ADDR) until state 3 is samples to be a high bit on the SDA line. Since the master monitors the SDA line in state 3 (ACK) and never receives an ACK from the slave, the master keeps on retrying by sending address (0x77) again.

**_Scenario 2 – No ACK from the master:_**

When the master sends the right address and reads the ACK from the slave and the slave further controls the SDA line to send the data, but the master is unable to sample the data and never provides an ACK. In this scenario, the slave (testbench) is designed to retransmit data until a successful ACK can be received from the master:

![image](https://github.com/user-attachments/assets/0d1eb35a-7b36-4a9d-bddb-f62f11e2e86b)
 
As can be seen in the above waveform, the slave keeps on resending the data (0xAA) on the SDA line and monitors the SDA line to go high, but the master never raises an ACK making the slave to retransmit the data over and over again.
