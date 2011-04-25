; RUN: llc < %s -regalloc=greedy -mcpu=cortex-a8 -relocation-model=pic -disable-fp-elim | FileCheck %s
;
; ARM tests that crash or fail with the greedy register allocator.

target triple = "thumbv7-apple-darwin"

declare double @exp(double)

; CHECK: remat_subreg
define void @remat_subreg(float* nocapture %x, i32* %y, i32 %n, i32 %z, float %c, float %lambda, float* nocapture %ret_f, float* nocapture %ret_df) nounwind {
entry:
  %conv16 = fpext float %lambda to double
  %mul17 = fmul double %conv16, -1.000000e+00
  br i1 undef, label %cond.end.us, label %cond.end

cond.end.us:                                      ; preds = %entry
  unreachable

cond.end:                                         ; preds = %cond.end, %entry
  %mul = fmul double undef, 0.000000e+00
  %add = fadd double undef, %mul
  %add46 = fadd double undef, undef
  %add75 = fadd double 0.000000e+00, undef
  br i1 undef, label %for.end, label %cond.end

for.end:                                          ; preds = %cond.end
  %conv78 = sitofp i32 %z to double
  %conv83 = fpext float %c to double
  %mul84 = fmul double %mul17, %conv83
  %call85 = tail call double @exp(double %mul84) nounwind
  %mul86 = fmul double %conv78, %call85
  %add88 = fadd double 0.000000e+00, %mul86
; CHECK: blx _exp
  %call100 = tail call double @exp(double %mul84) nounwind
  %mul101 = fmul double undef, %call100
  %add103 = fadd double %add46, %mul101
  %mul111 = fmul double undef, %conv83
  %mul119 = fmul double %mul111, undef
  %add121 = fadd double undef, %mul119
  %div = fdiv double 1.000000e+00, %conv16
  %div126 = fdiv double %add, %add75
  %sub = fsub double %div, %div126
  %div129 = fdiv double %add103, %add88
  %add130 = fadd double %sub, %div129
  %conv131 = fptrunc double %add130 to float
  store float %conv131, float* %ret_f, align 4
  %mul139 = fmul double %div129, %div129
  %div142 = fdiv double %add121, %add88
  %sub143 = fsub double %mul139, %div142
; %lambda is passed on the stack, and the stack slot load is rematerialized.
; The rematted load of a float constrains the D register used for the mul.
; CHECK: vldr
  %mul146 = fmul float %lambda, %lambda
  %conv147 = fpext float %mul146 to double
  %div148 = fdiv double 1.000000e+00, %conv147
  %sub149 = fsub double %sub143, %div148
  %conv150 = fptrunc double %sub149 to float
  store float %conv150, float* %ret_df, align 4
  ret void
}

