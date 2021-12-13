define void @itoa(i64 %n, i8* nocapture nonnull %buf, i64 %base) nounwind {
  br label %loopstart
loopstart:
  %idx = phi i32 [ 0, %0 ], [ %idx.1, %loopend ]
  %num = phi i64 [ %n, %0 ], [ %num.1, %loopend ]
  %chr_p = getelementptr inbounds i8, i8* %buf, i32 %idx
  %digit32 = urem i64 %num, %base
  %digit = trunc i64 %digit32 to i8
  %is_under_ten = icmp ult i8 %digit, 10
  br i1 %is_under_ten, label %numdigit, label %alphadigit
numdigit:
  %chr_num = add i8 48, %digit ; ASCII value of '0' is 48
  br label %loopend
alphadigit:
  %chr_alpha = add i8 55, %digit ; ASCII value of 'A' is 65
  br label %loopend
loopend:
  %chr = phi i8 [ %chr_num, %numdigit ], [ %chr_alpha, %alphadigit ]
  store i8 %chr, i8* %chr_p
  %num.1 = udiv i64 %num, %base
  %is_zero = icmp eq i64 %num.1, 0
  %idx.1 = add i32 %idx, 1
  br i1 %is_zero, label %exit, label %loopstart
exit:
  %nul_p = getelementptr inbounds i8, i8* %buf, i32 %idx.1
  store i8 0, i8* %nul_p
  call void @reverse(i8* %buf)
  ret void
}

define i32 @atoi(i8* nocapture nonnull readonly %str) {
  br label %loop
loop:
  %idx = phi i32 [ 0, %0 ], [ %idx.1, %looptail ]
  %val = phi i32 [ 0, %0 ], [ %val.1, %looptail ]
  %chr_p = getelementptr inbounds i8, i8* %str, i32 %idx
  %chr = load i8, i8* %chr_p
  %is_nul = icmp eq i8 %chr, 0
  br i1 %is_nul, label %done, label %looptail
looptail:
  %ord = sub i8 %chr, 48
  %ord.0 = zext i8 %ord to i32
  %val.0 = mul i32 %val, 10
  %val.1 = add i32 %val.0, %ord.0
  %idx.1 = add i32 %idx, 1
  br label %loop
done:
  ret i32 %val
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

define void @strcpy(i8* nocapture nonnull readonly %src, i8* nocapture nonnull %dst) {
  br label %loopstart
loopstart:
  %idx = phi i32 [ 0, %0 ], [ %idx.0, %loopstart ]
  %src_p = getelementptr inbounds i8, i8* %src, i32 %idx
  %dst_p = getelementptr inbounds i8, i8* %dst, i32 %idx
  %chr = load i8, i8* %src_p
  store i8 %chr, i8* %dst_p
  %idx.0 = add i32 %idx, 1
  %is_nul = icmp eq i8 %chr, 0
  br i1 %is_nul, label %exit, label %loopstart
exit:
  ret void
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

define i8* @tokenize(i8* nonnull readonly %buf, i8 %token, i8** nonnull %state_p) {
  %state = load i8*, i8** %state_p
  %initial_state = icmp eq i8* %state, null
  br i1 %initial_state, label %setup_state, label %preloop
setup_state:
  store i8* %buf, i8** %state_p
  br label %preloop
preloop:
  %start_p = phi i8* [ %state, %0 ], [ %buf, %setup_state ]
  %start = load i8, i8* %start_p
  %is_buf_done = icmp eq i8 %start, 0
  br i1 %is_buf_done, label %bufdone, label %loophead
loophead:
  %curr_p = phi i8* [ %start_p, %preloop ], [ %curr_p.0, %looptail ]
  %curr = load i8, i8* %curr_p
  %is_nul = icmp eq i8 %curr, 0
  %is_token = icmp eq i8 %curr, %token
  %found = or i1 %is_nul, %is_token
  br i1 %found, label %match_token, label %looptail
looptail:
  %curr_p.0 = getelementptr inbounds i8, i8* %curr_p, i64 1
  br label %loophead
match_token:
  %offset = zext i1 %is_token to i64
  %state_p.0 = getelementptr inbounds i8, i8* %curr_p, i64 %offset
  store i8* %state_p.0, i8** %state_p
  store i8 0, i8* %curr_p
  ret i8* %start_p
bufdone:
  ret i8* null
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
