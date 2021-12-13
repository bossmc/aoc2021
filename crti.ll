declare i32 @main()
declare void ()** @__llvm_getGlobalCtors()

@llvm.global_ctors = appending global [ 0 x { i32, void ()*, i8* } ] zeroinitializer

@__CTOR_START = hidden unnamed_addr global [ 0 x void()* ] zeroinitializer, section ".ctors"
@__CTOR_END = external unnamed_addr global void()*, section ".ctors"
@__init_array_start = external unnamed_addr global void()*, section ".init_array"
@__init_array_end = external unnamed_addr global void()*, section ".init_array"

define void @_start() noreturn {
  %__ctor_start = getelementptr [ 0 x void()* ], [ 0 x void()* ]* @__CTOR_START, i64 0, i64 0
  br label %runctors
runctors:
  %ptr_ctor = phi void()** [ %__ctor_start, %0 ], [ %__ctor_start.0, %runctors.0 ]
  %is_end_ctor = icmp eq void()** %ptr_ctor, @__CTOR_END
  br i1 %is_end_ctor, label %runinitarray, label %runctors.0
runctors.0:
  %__ctor_start.0 = getelementptr void()*, void()** %ptr_ctor, i64 1
  %ctor = load void()*, void()** %ptr_ctor
  call void %ctor()
  br label %runctors
runinitarray:
  %ptr_ia = phi void()** [ @__init_array_start, %runctors ], [ %ptr_ia.0, %runinitarray.0 ]
  %is_end_ia = icmp eq void()** %ptr_ia, @__init_array_end
  br i1 %is_end_ia, label %runmain, label %runinitarray.0
runinitarray.0:
  %ptr_ia.0 = getelementptr void()*, void()** %ptr_ia, i64 1
  %ia = load void()*, void()** %ptr_ia
  call void %ia()
  br label %runinitarray
runmain:
  %ret = call i32 @main()

  call void asm "syscall", "{rax},{rbx},~{rcx},~{r11}"(i32 u0x3C, i32 %ret) noreturn nounwind
  unreachable
}
