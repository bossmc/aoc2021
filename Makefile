.DEFAULT_GOAL := day1.exe

day%.o : day%.ll
	llc-13 $< -o $@ -filetype=obj -relocation-model=pic

day%.opt.ll : day%.ll
	opt-13 -O3 -S $^ -o $@

day%.exe : day%.o itoa.o
	clang -fuse-ld=lld -static-pie -o $@ $^

itoa.o : itoa.c
	clang -c $^ -o $@ -fPIC

