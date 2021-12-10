@data1 = external unnamed_addr constant [2000 x i32]

declare i8* @alloc(i64)
declare void @itoa(i64, i8* nocapture noalias nofree, i64)
declare i32 @puts(i8* nocapture) nounwind

define private void @print(i32 %num) {
  %str = call i8* @alloc(i64 32)
  %num64 = zext i32 %num to i64
  call void @itoa(i64 %num64, i8* %str, i64 10)
  call i32 @puts(i8* %str)
  ret void
}

define private void @part_a() {
  ; Current array index (start at 1 since first elem is special)
  %idx_p = alloca i32
  store i32 1, i32* %idx_p
  ; Value of last array element seen
  %prev_p = alloca i32
  ; Count of depth drops
  %count_p = alloca i32
  store i32 0, i32* %count_p

  ; Start by reading element 0 and storing into %prev_p
  %first_p = getelementptr inbounds [2000 x i32], [2000 x i32]* @data1, i64 0, i32 0
  %first = load i32, i32* %first_p
  store i32 %first, i32* %prev_p

  ; Start the main processing loop
  br label %loopstart

loopstart:
  ; Check if we've reached the end of the array
  %idx = load i32, i32* %idx_p
  %not_done = icmp ult i32 %idx, 2000
  br i1 %not_done, label %loopbody, label %exit

loopbody:
  ; Load the current element (at index %idx)
  %elem_p = getelementptr inbounds [2000 x i32], [2000 x i32]* @data1, i64 0, i32 %idx
  %elem = load i32, i32* %elem_p

  ; Also retrieve the previous element
  %prev = load i32, i32* %prev_p

  ; If the current element is deeper (greater) than the previous, increment the count
  %is_deeper = icmp ugt i32 %elem, %prev
  br i1 %is_deeper, label %loophit, label %looptail

loophit:
  ; Increment the count
  %count = load i32, i32* %count_p
  %count.1 = add i32 %count, 1
  store i32 %count.1, i32* %count_p
  br label %looptail

looptail:
  ; Save the current element as the previous element
  store i32 %elem, i32* %prev_p

  ; Move to next element in the list
  %idx.1 = add i32 %idx, 1
  store i32 %idx.1, i32* %idx_p
  br label %loopstart

exit:
  %ret = load i32, i32* %count_p
  call void @print(i32 %ret)
  ret void
}

define private void @part_b() {
  ; Current array index (start at 3 since first three elems are special)
  %idx_p = alloca i32
  store i32 3, i32* %idx_p
  ; Value of last window sum seen
  %prev_p = alloca i32
  ; Count of depth drops
  %count_p = alloca i32
  store i32 0, i32* %count_p

  ; Start by reading elements 0, 1, and 2 and storing into %prev_1_p, %prev_2_p and %prev
  %elem.0_p.init = getelementptr inbounds [2000 x i32], [2000 x i32]* @data1, i64 0, i32 0
  %elem.1_p.init = getelementptr inbounds [2000 x i32], [2000 x i32]* @data1, i64 0, i32 1
  %elem.2_p.init = getelementptr inbounds [2000 x i32], [2000 x i32]* @data1, i64 0, i32 2
  %elem.0.init = load i32, i32* %elem.0_p.init
  %elem.1.init = load i32, i32* %elem.1_p.init
  %elem.2.init = load i32, i32* %elem.2_p.init
  %sum.0.init = add i32 %elem.0.init, %elem.1.init
  %sum.1.init = add i32 %sum.0.init, %elem.2.init
  store i32 %sum.1.init, i32* %prev_p

  ; Start the main processing loop
  br label %loopstart

loopstart:
  ; Check if we've reached the end of the array
  %idx = load i32, i32* %idx_p
  %not_done = icmp ult i32 %idx, 2000
  br i1 %not_done, label %loopbody, label %exit

loopbody:
  ; Load the current window (at indexes %idx-2, %idx-1 and  %idx)
  %elem.0_p = getelementptr inbounds [2000 x i32], [2000 x i32]* @data1, i64 0, i32 %idx
  %idx.1 = sub i32 %idx, 1
  %elem.1_p = getelementptr inbounds [2000 x i32], [2000 x i32]* @data1, i64 0, i32 %idx.1
  %idx.2 = sub i32 %idx, 2
  %elem.2_p = getelementptr inbounds [2000 x i32], [2000 x i32]* @data1, i64 0, i32 %idx.2
  %elem.0 = load i32, i32* %elem.0_p
  %elem.1 = load i32, i32* %elem.1_p
  %elem.2 = load i32, i32* %elem.2_p

  ; Calculate the sum for this window
  %sum.0 = add i32 %elem.0, %elem.1
  %sum.1 = add i32 %sum.0, %elem.2

  ; Also retrieve the previous window value
  %prev = load i32, i32* %prev_p

  ; If the current window is deeper (greater) than the previous, increment the count
  %is_deeper = icmp ugt i32 %sum.1, %prev
  br i1 %is_deeper, label %loophit, label %looptail

loophit:
  ; Increment the count
  %count = load i32, i32* %count_p
  %count.1 = add i32 %count, 1
  store i32 %count.1, i32* %count_p
  br label %looptail

looptail:
  ; Save the current sum as the new "previous sum"
  store i32 %sum.1, i32* %prev_p

  ; Move to next element in the list
  %idx.next = add i32 %idx, 1
  store i32 %idx.next, i32* %idx_p
  br label %loopstart

exit:
  %ret = load i32, i32* %count_p
  call void @print(i32 %ret)
  ret void
}

define i32 @main() {
  call void @part_a()
  call void @part_b()
  ret i32 0
}
