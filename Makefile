hxdump: hxdump.o
	ld -melf_i386 -o hxdump hxdump.o

hxdump.o: hxdump.asm
	nasm -felf -o hxdump.o hxdump.asm

ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif

install: hxdump
	cp ./hxdump $(PREFIX)/bin/hxdump

clean: 
	rm ./hxdump ./hxdump.o

uninstall:
	rm $(PREFIX)/bin/hxdump
