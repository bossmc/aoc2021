declare i32 @main()
declare void ()** @__llvm_getGlobalCtors()

@llvm.global_ctors = appending global [ 0 x { i32, void ()*, i8* } ] zeroinitializer

@__CTOR_START = hidden global [ 0 x void()* ] zeroinitializer, section ".ctors"
@__CTOR_END = external global void()*, section ".ctors"

define void @_start() noreturn {
  %ctor_start = getelementptr [ 0 x void()* ], [ 0 x void()* ]* @__CTOR_START, i64 0, i64 0
  br label %runctors
runctors:
  %ptr = phi void()** [ %ctor_start, %0 ], [ %ctor_start.0, %runctors.0 ]
  %ctor = load void()*, void()** %ptr
  %is_end = icmp eq void()** %ptr, @__CTOR_END
  %ctor_start.0 = getelementptr void()*, void()** %ptr, i64 1
  br i1 %is_end, label %runmain, label %runctors.0
runctors.0:
  call void %ctor()
  br label %runctors
runmain:
  %ret = call i32 @main()

  call void asm "syscall", "{rax},{rbx},~{rcx},~{r11}"(i32 u0x3C, i32 %ret) noreturn nounwind
  unreachable
}
