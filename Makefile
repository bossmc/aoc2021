.DEFAULT_GOAL := day1.exe

%.o : %.dbg.ll
	llc-13 $< -o $@ -filetype=obj -relocation-model=pic

%.dbg.ll : %.ll
	opt-13 -O0 -S --debugify $^ -o $@

%.opt.ll : %.ll
	opt-13 -O3 -S $^ -o $@

day%.exe : crti.o day%.o utils.o
	ld.lld -static -o $@ $^

.PHONY : clean
clean :
	-rm *.opt.ll *.exe *.dbg.ll *.opt.ll *.o
