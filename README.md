# HxDump
An x86-32 Assembly Project to HexDump a file using UNIX IO Redirection
Currently this Application is only available on Linux.

Building Requirements:
- Nasm ( Netwide Assembler )
- ld ( GNU Linker )

# Building & Installing
Everything is baked into the `Makefile`, For building the project you need to use:
```
make
```
To Install it you can use:
```
sudo make install
```

For cleaning build folder:
```
sudo make clean
```

# Usage
You can pass a file to hexdump like:
```
hxdump < FILEPATH
```
or you can pipe a result into hxdump:
```
echo "Hello World" | hxdump
```
otherwise you can run hxdump and type input to get hexdump result

# Uninstall
I Will be happy if you report any issue that the program has, before you uninstall it.<br/>
anyways if you want to remove the program from your sytstem, you can use
```
sudo make uninstall
```
command in the build folder to get rid of this application :).

# Collaborators
- iHapiW
