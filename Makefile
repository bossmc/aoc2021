.PHONY : all
all : day1.exe day2.exe day3.exe

.SECONDARY :

%.o : %.ll
	llc-13 $< -o $@ -filetype=obj

%.opt.ll : %.ll
	opt-13 -O3 -S $^ -o $@

libll.a : utils.opt.o alloc.opt.o
	ar rc $@ $^

day%.exe : crti.opt.o day%.o data%.o libll.a crtn.opt.o
	ld.lld -static -o $@ $^

.PHONY : clean
clean :
	-rm *.o *.opt.ll day*.exe libll.a
