buffered_uart
===============

UART (RS232C) IP with FIFO buffers for Intel FPGAs

Features
--------

|Feature|Status|
|:--|:--|
|Data bits|Selectable (5-bit ~ 9-bit)|
|Parity bit|Not supported|
|Stop bits|Supports 1-bit only|
|Flow control|Selectable<br>- No flow control<br>- Hardware flow control (RTS/CTS)|
|RX buffer size|Selectable (4 bytes ~ 131,072 bytes)|
|TX buffer size|Selectable (4 bytes ~ 131,072 bytes)|
|Baudrate|Maximum (Clock / 4) bps|

Driver support
--------

|Type|APIs supported|APIs _not_ supported|
|:--|:--|:--|
|Standard HAL|open(), close(), read(), write()|ioctl()|
|Lightweight HAL<br>(ALT\_USE\_DIRECT\_DRIVERS)|ALT\_DRIVER\_READ()<br>ALT\_DRIVER\_WRITE()|ALT\_DRIVER\_IOCTL()|

License
--------
MIT
