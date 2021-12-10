.PHONY : all
all : day1.exe day2.exe

.SECONDARY :

%.o : %.ll
	llc-13 $< -o $@ -filetype=obj -relocation-model=pic -use-ctors

%.opt.ll : %.ll
	opt-13 -O3 -S $^ -o $@

libll.a : utils.o alloc.o
	ar rc $@ $^

day%.exe : crti.o day%.o data%.o libll.a crtn.o
	ld.lld -static -o $@ $^

.PHONY : clean
clean :
	-rm *.o *.opt.ll day*.exe malloc.exe
