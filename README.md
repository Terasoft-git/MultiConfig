# MultiConfig

:construction:

Multiconfig is a framework to extend inifiles.
It consists of reading or writing a section / value from a stack of sources.
Sources can be files, comand lines parameters, registry entries ou even environment variables.

It supports Cryptografy, at key/value pair or file level.

To ensure integrity in multiuser environment, it uses a file lock mechanism, to garantee data consistency among other users/Applications.

It takes the first source in the list, reads it section/value pair and if the value is found, returns it, if not, continues this logic until it finds it, or returns DEFAULT value if it is not found.

Spring4D Framework (git clone https://bitbucket.org/sglienke/spring4d.git) is used as Framework for Cryptografy and Lists handling.

It is also compiled a DLL version of the code, to use in Delphi 7 and up, or any other aplication.
DLL generated is compacted using UPX Exe packer - https://upx.github.io/


Tested in Delphi XE3 and Delphi XE5, 32 and 64 bits
D7 does not support it directly, but we can use with the DLL generated from DXE5.
D7 was tested this way.



