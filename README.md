# MultiConfig

Multiconfig is a framework to extend inifiles.
It consists of reading or writing a section / value from a stack of sources.
Sources can be files, comand lines parameters, registry entries ou even environment variables.

It takes the first source in the list, reads it section/value pair and if the value is found, returns it, if not, continues this logic until it finds it, or returns DEFAULT value if it is not found.

