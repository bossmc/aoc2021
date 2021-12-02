define void @itoa(i32 %n, i8* nocapture nonnull %buf) nounwind {
  %neg = icmp slt i32 %n, 0
  br i1 %neg, label %invert, label %loophead
invert:
  %n_neg = mul i32 %n, -1
  br label %loophead
loophead:
  %n_abs = phi i32 [ %n, %0 ], [ %n_neg, %invert ]
  br label %loopstart
loopstart:
  %idx = phi i32 [ 0, %loophead ], [ %idx.1, %loopstart ]
  %num = phi i32 [ %n_abs, %loophead ], [ %num.1, %loopstart ]
  %chr_p = getelementptr inbounds i8, i8* %buf, i32 %idx
  %digit32 = urem i32 %num, 10
  %digit = trunc i32 %digit32 to i8
  %chr = add i8 48, %digit ; ASCII value of '0' is 48
  store i8 %chr, i8* %chr_p
  %num.1 = udiv i32 %num, 10
  %is_zero = icmp eq i32 %num.1, 0
  %idx.1 = add i32 %idx, 1
  br i1 %is_zero, label %exit, label %loopstart
exit:
  %nul_p = getelementptr inbounds i8, i8* %buf, i32 %idx.1
  store i8 0, i8* %nul_p
  call void @reverse(i8* %buf)
  ret void
}

define i32 @strlen(i8* nocapture nonnull readonly %str) {
  br label %loopstart
loopstart:
  %idx = phi i32 [ 0, %0 ], [ %idx.1, %loopstart ]
  %count = phi i32 [ 0, %0 ], [ %count.1, %loopstart ]
  %chr_p = getelementptr inbounds i8, i8* %str, i32 %idx
  %chr = load i8, i8* %chr_p
  %idx.1 = add i32 %idx, 1
  %count.1 = add i32 %count, 1
  %is_nul = icmp eq i8 %chr, 0
  br i1 %is_nul, label %exit, label %loopstart
exit:
  ret i32 %count
}

define i1 @strcmp(i8* nocapture nonnull readonly %a, i8* nocapture nonnull readonly %b) {
  br label %loopstart
loopstart:
  %idx = phi i32 [ 0, %0 ], [ %idx.1, %looptail ]
  %a_p = getelementptr inbounds i8, i8* %a, i32 %idx
  %b_p = getelementptr inbounds i8, i8* %b, i32 %idx
  %a_chr = load i8, i8* %a_p
  %b_chr = load i8, i8* %b_p
  %eq = icmp eq i8 %a_chr, %b_chr
  br i1 %eq, label %looptail, label %exitfail
looptail:
  %idx.1 = add i32 %idx, 1
  %nul = icmp eq i8 %a_chr, 0
  br i1 %nul, label %exitpass, label %loopstart
exitpass:
  ret i1 1
exitfail:
  ret i1 0
}

define private void @reverse(i8* nocapture nonnull %str) nounwind {
  %len = call i32 @strlen(i8* %str)
  %len.0 = sub i32 %len, 1
  br label %loopstart
loopstart:
  %low = phi i32 [ 0, %0 ], [ %low.1, %looptail ]
  %high = phi i32 [ %len.0, %0 ], [ %high.1, %looptail ]
  %finished = icmp ugt i32 %low, %high
  br i1 %finished, label %exit, label %looptail
looptail:
  %low_p = getelementptr inbounds i8, i8* %str, i32 %low
  %high_p = getelementptr inbounds i8, i8* %str, i32 %high
  %temp.low = load i8, i8* %low_p
  %temp.high = load i8, i8* %high_p
  store i8 %temp.low, i8* %high_p
  store i8 %temp.high, i8* %low_p
  %low.1 = add i32 %low, 1
  %high.1 = sub i32 %high, 1
  br label %loopstart
exit:
  ret void
}

define i32 @puts(i8* nocapture nonnull readonly %buf) nounwind {
  %nul_p = alloca i8
  store i8 10, i8* %nul_p
  %len = call i32 @strlen(i8* %buf)
  %ret = call i32 @sys_write(i32 1, i8* %buf, i32 %len)
  call i32 @sys_write(i32 1, i8* %nul_p, i32 1) ; Hope this doesn't fail!
  ret i32 %ret
}

define private i32 @sys_write(i32 %fd, i8* nocapture nonnull readonly %buf, i32 %len) nounwind {
  %ret = call i32 asm "syscall", "={rax},{rax},{rdi},{rsi},{rdx},~{rcx},~{r11}"(i32 1, i32 %fd, i8* %buf, i32 %len)
  ret i32 %ret
}
