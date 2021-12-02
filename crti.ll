declare i32 @main()

define void @_start() noreturn {
  %ret = call i32 @main()

  call void asm "syscall", "{rax},{rbx},~{rcx},~{r11}"(i32 u0x3C, i32 %ret) noreturn nounwind
  unreachable
}
