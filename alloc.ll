declare void @puts(i8*)
declare void @itoa(i64, i8*, i64)
declare void @llvm.lifetime.start(i64, i8* nocapture)

%Allocator = type {
  i8*,   ; mmapped root
  i8*,   ; bumping ptr (points between root and capacity)
  i32    ; capacity
}
@alloc_p = private global %Allocator { i8* null, i8* null, i32 undef }

@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @Allocator_init, i8* bitcast (%Allocator* @alloc_p to i8*) }]

define private void @Allocator_init() {
  %alloc = call %Allocator @Allocator_new(i32 mul (i32 4096, i32 4096))
  store %Allocator %alloc, %Allocator* @alloc_p
  ret void
}

define private %Allocator @Allocator_new(i32 %size) {
  %root = call i8* @sys_mmap(i32 %size)
  %val.0 = insertvalue %Allocator undef, i8* %root, 0
  %val.1 = insertvalue %Allocator %val.0, i8* %root, 1
  %val.2 = insertvalue %Allocator %val.1, i32 %size, 2
  ret %Allocator %val.2
}

define i8* @alloc(i64 %size) {
  %ptr_p = getelementptr inbounds %Allocator, %Allocator* @alloc_p, i64 0, i32 1
  %ptr = load i8*, i8** %ptr_p
  %ptr.i64 = ptrtoint i8* %ptr to i64
  %align_err = urem i64 %ptr.i64, 8
  %is_aligned = icmp eq i64 %align_err, 0
  br i1 %is_aligned, label %finish, label %fix_align
fix_align:
  %align_off = sub i64 8, %align_err
  %aligned_start = getelementptr i8, i8* %ptr, i64 %align_off
  br label %finish
finish:
  %start = phi i8* [ %ptr, %0 ], [ %aligned_start, %fix_align ]
  %end = getelementptr i8, i8* %start, i64 %size
  store i8* %end, i8** %ptr_p
  call void @llvm.lifetime.start(i64 -1, i8* %start)
  ret i8* %start
}

define private i8* @sys_mmap(i32 %len) {
  %ret = call i8* asm "syscall", "={rax},{rax},{rdi},{rsi},{rdx},{r10},{r8},{r9},~{rcx},~{r11}"(
    i32 9,     ; SYS_MMAP
    i8* null,  ; Start address (not used)
    i32 %len,  ; Size of map
    i32 u0x3,  ; PROT_READ | PROT_WRITE
    i32 u0x22, ; MAP_PRIVATE | MAP_ANONYMOUS
    i32 -1,    ; FD (not used)
    i32 0      ; Offset
  )
  ret i8* %ret
}
