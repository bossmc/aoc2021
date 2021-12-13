@data2 = external unnamed_addr constant [ 7776 x i8 ]

@forward_s = unnamed_addr constant [ 8 x i8 ] c"forward\00"
@down_s = unnamed_addr constant [ 5 x i8 ] c"down\00"
@up_s = unnamed_addr constant [ 3 x i8 ] c"up\00"

declare i8* @alloc(i64)
declare i64 @atoi(i8*)
declare void @itoa(i64, i8*, i64)
declare void @strcpy(i8*, i8*)
declare i1 @strcmp(i8*, i8*)
declare i32 @puts(i8* nocapture nonnull readonly %buf) nounwind
declare i8* @tokenize(i8* nonnull readonly %buf, i8 %token, i8** nonnull %state_p)

define void @part_a() {
  %data_p = call i8* @alloc(i64 7776)
  call void @strcpy(i8* getelementptr inbounds ([ 7776 x i8 ], [ 7776 x i8 ]* @data2, i64 0, i64 0), i8* %data_p)
  %state = alloca i8*
  %firsttoken = call i8* @tokenize(i8* %data_p, i8 10, i8** %state) ; split on newline
  br label %loopstart
loopstart:
  %token = phi i8* [ %firsttoken, %0 ], [ %token.0, %looptail ]
  %depth = phi i64 [ 0, %0 ], [ %depth.1, %looptail ]
  %horizontal = phi i64 [ 0, %0 ], [ %horizontal.0, %looptail ]
  %is_nul = icmp eq i8* null, %token
  br i1 %is_nul, label %done, label %looptail
looptail:
  %token.0 = call i8* @tokenize(i8* null, i8 10, i8** %state)
  %inner_state = alloca i8*
  store i8* null, i8** %inner_state
  %word = call i8* @tokenize(i8* %token, i8 32, i8** %inner_state)
  %delta_str = load i8*, i8** %inner_state
  %delta = call i64 @atoi(i8* %delta_str)
  %is_forward = call i1 @strcmp(i8* %word, i8* getelementptr inbounds ([ 8 x i8 ], [ 8 x i8 ]* @forward_s, i64 0, i64 0))
  %is_forward.64 = zext i1 %is_forward to i64
  %amount_forward = mul i64 %is_forward.64, %delta
  %horizontal.0 = add i64 %horizontal, %amount_forward
  %is_down = call i1 @strcmp(i8* %word, i8* getelementptr inbounds ([ 5 x i8 ], [ 5 x i8 ]* @down_s, i64 0, i64 0))
  %is_down.64 = zext i1 %is_down to i64
  %amount_down = mul i64 %is_down.64, %delta
  %depth.0 = add i64 %depth, %amount_down
  %is_up = call i1 @strcmp(i8* %word, i8* getelementptr inbounds ([ 3 x i8 ], [ 3 x i8 ]* @up_s, i64 0, i64 0))
  %is_up.64 = zext i1 %is_up to i64
  %amount_up = mul i64 %is_up.64, %delta
  %depth.1 = sub i64 %depth.0, %amount_up
  br label %loopstart
done:
  %buf = call i8* @alloc(i64 32)
  %ret = mul i64 %depth, %horizontal
  call void @itoa(i64 %ret, i8* %buf, i64 10)
  call i32 @puts(i8* %buf)
  ret void
}

define void @part_b() {
  %data_p = call i8* @alloc(i64 7776)
  call void @strcpy(i8* getelementptr inbounds ([ 7776 x i8 ], [ 7776 x i8 ]* @data2, i64 0, i64 0), i8* %data_p)
  %state = alloca i8*
  %firsttoken = call i8* @tokenize(i8* %data_p, i8 10, i8** %state) ; split on newline
  br label %loopstart
loopstart:
  %token = phi i8* [ %firsttoken, %0 ], [ %token.0, %looptail ]
  %vertical = phi i64 [ 0, %0 ], [ %vertical.0, %looptail ]
  %horizontal = phi i64 [ 0, %0 ], [ %horizontal.0, %looptail ]
  %aim = phi i64 [ 0, %0 ], [ %aim.1, %looptail ]
  %is_nul = icmp eq i8* null, %token
  br i1 %is_nul, label %done, label %looptail
looptail:
  %token.0 = call i8* @tokenize(i8* null, i8 10, i8** %state)
  %inner_state = alloca i8*
  store i8* null, i8** %inner_state
  %word = call i8* @tokenize(i8* %token, i8 32, i8** %inner_state)
  %delta_str = load i8*, i8** %inner_state
  %delta = call i64 @atoi(i8* %delta_str)
  %is_forward = call i1 @strcmp(i8* %word, i8* getelementptr inbounds ([ 8 x i8 ], [ 8 x i8 ]* @forward_s, i64 0, i64 0))
  %is_forward.64 = zext i1 %is_forward to i64
  %amount_horizontal = mul i64 %is_forward.64, %delta
  %amount_vertical = mul i64 %amount_horizontal, %aim
  %horizontal.0 = add i64 %horizontal, %amount_horizontal
  %vertical.0 = add i64 %vertical, %amount_vertical
  %is_down = call i1 @strcmp(i8* %word, i8* getelementptr inbounds ([ 5 x i8 ], [ 5 x i8 ]* @down_s, i64 0, i64 0))
  %is_down.64 = zext i1 %is_down to i64
  %amount_down = mul i64 %is_down.64, %delta
  %aim.0 = add i64 %aim, %amount_down
  %is_up = call i1 @strcmp(i8* %word, i8* getelementptr inbounds ([ 3 x i8 ], [ 3 x i8 ]* @up_s, i64 0, i64 0))
  %is_up.64 = zext i1 %is_up to i64
  %amount_up = mul i64 %is_up.64, %delta
  %aim.1 = sub i64 %aim.0, %amount_up
  br label %loopstart
done:
  %buf = call i8* @alloc(i64 32)
  %ret = mul i64 %vertical, %horizontal
  call void @itoa(i64 %ret, i8* %buf, i64 10)
  call i32 @puts(i8* %buf)
  ret void
}

define i32 @main() {
  call void @part_a()
  call void @part_b()
  ret i32 0
}
