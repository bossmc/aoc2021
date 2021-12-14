@data3 = external unnamed_addr constant [ 12999 x i8 ]

declare i8* @alloc(i64)
declare void @strcpy(i8*, i8*)
declare i8* @tokenize(i8*, i8, i8**)
declare void @itoa(i64, i8* nocapture nonnull, i64)
declare i32 @puts(i8*)

define void @part_a() {
  %data_p = call i8* @alloc(i64 12999)
  call void @strcpy(i8* getelementptr inbounds ([ 12999 x i8 ], [ 12999 x i8 ]* @data3, i64 0, i64 0), i8* %data_p)
  %counts = alloca <16 x i8>, align 32 ; Why does 16 not work?
  store <16 x i8> zeroinitializer, <16 x i8>* %counts
  %state = alloca i8*
  %firsttoken = call i8* @tokenize(i8* %data_p, i8 10, i8** %state) ; split on newlines
  br label %outerloop
outerloop:
  %token = phi i8* [ %firsttoken, %0 ], [ %token.0, %innerloop ]
  %token.0 = call i8* @tokenize(i8* null, i8 10, i8** %state)
  %is_nul = icmp eq i8* null, %token
  br i1 %is_nul, label %done, label %innerloop
innerloop:
  %idx = phi i32 [ 0, %outerloop ], [ %idx.0, %innerloop.0 ]
  %count_p = getelementptr inbounds <16 x i8>, <16 x i8>* %counts, i32 0, i32 %idx
  %idx.0 = add i32 %idx, 1
  %chr_p = getelementptr inbounds i8, i8* %token, i32 %idx
  %chr = load i8, i8* %chr_p
  %is_inner_nul = icmp eq i8 %chr, 0
  br i1 %is_inner_nul, label %outerloop, label %innerloop.0
innerloop.0:
  %bit = sub i8 %chr, 48    ;  0 or 1
  %bit.0 = mul i8 %bit, 2   ;  0 or 2
  %bit.1 = sub i8 %bit.0, 1 ; -1 or 1
  %count = load i8, i8* %count_p
  %count.0 = add i8 %count, %bit.1
  store i8 %count.0, i8* %count_p
  br label %innerloop
done:
  %counts.0 = load <16 x i8>, <16 x i8>* %counts
  %counts.1 = shufflevector <16 x i8> %counts.0, <16 x i8> undef, <16 x i32> <i32 15, i32 14, i32 13, i32 12, i32 11, i32 10, i32 9, i32 8, i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 0> ; Reverse the vector since reading out out of <N x i1> returns bits in the "reverse" order
  %bits = icmp sgt <16 x i8> %counts.1, zeroinitializer ; Sexy sexy AVX!
  %gamma = bitcast <16 x i1> %bits to i16
  %epsilon = xor i16 %gamma, -1 ; Clearly the gamma is the bitwise negation of the epsilon
  %gamma.0 = lshr i16 %gamma, 4 ; Skip the 4 bits we added for TypeLegalization (a.k.a making up 128bits)
  %gamma.1 = zext i16 %gamma.0 to i64
  %epsilon.0 = lshr i16 %epsilon, 4 ; Ditto
  %epsilon.1 = zext i16 %epsilon.0 to i64
  %power = mul i64 %gamma.1, %epsilon.1
  call void @itoa(i64 %power, i8* %data_p, i64 10)
  call i32 @puts(i8* %data_p)
  ret void
}

define i32 @main() {
  call void @part_a()
  ret i32 1
}
