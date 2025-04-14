#import "@preview/touying:0.6.1": *
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")
#let diagram = touying-reducer.with(
	reduce: fletcher.diagram, cover: fletcher.hide
)

#set text(size: 23pt)

// Import slides from older presentation
#let tum-slide(slide_num) = {
	let image = image("tum-presi/" + str(slide_num)  + ".svg")
	let fitted = utils.fit-to-height(100%, image)
	empty-slide(config: config-page(margin: (x: 0em, y: 0em)))[#fitted]
}

#tum-slide(1)
#tum-slide(2)
#for k in range(4, 8) {
	tum-slide(k)
}

#tum-slide(11)
#tum-slide(12)


== TLSNotary Protocol

#slide[
	=== Techniques
	- Oblivious Transfer
	- Garbled Circuits
	- (V)OLE
	- (Interactive ZK)
][
	=== Phases
	+ Preprocessing
	+ Key Exchange
	+ TLS PRF
	+ En-/Decryption 
	+ Proving
	+ Commitments
]

== (1-out-of-2) Oblivious Transfer
#align(center + horizon, 
	diagram(
		node((0, 1), [$P_S$]),

		edge((0.75, 1), (2, 1), label: $(m_0, m_1)$, "-|>"),

		node((2, 1), "OT", stroke: 1pt, inset: 3em),

		edge((2, 0.75), (3, 0.75), $c$, "<|-"),
		edge((2, 1.25), (3, 1.25), $m_c$, "-|>"),

		node((3.5, 1), [$P_R$])
	)
)
+ Sender messages: $(m_0, m_1)$
+ Receiver bit: $c in {0, 1}$
+ $P_A$ learns nothing and $P_B$ only learns $m_c$
- Many variants: Random OT, Correlated OT, k-out-of-n OT, ...



== Garbled Circuits #h(8em) #text(blue, size: 20pt)[https://eprint.iacr.org/2014/756]
#slide(composer: 2)[#grid.cell(colspan: 2)[
	Two parties, garbler $G$, evaluator $E$ want to compute $f(x_G, y_E) =
	z$, \ Garbler *garbles* the circuit:
]][
1. From gate with clear values *$c_i$*
	#scale(75%, reflow: true)[
		#diagram(
			edge((0, 0.25), (1, 0.25), $c_i$, "-|>"),
			edge((0, 0.75), (1, 0.75), $c_j$, "-|>"),

			node((1, 0.5), $G_T (c_i, c_j)$,
				shape: fletcher.shapes.rect, stroke: black, inset: 1em),

			edge((1, 0.5), (2, 0.5), $c_k$, "-|>"),
		)
	]

#pause
2. To gate with wire labels *$w_i$*
	#scale(75%, reflow: true)[
		#diagram(
			edge((0, 0.25), (1, 0.25), $w_i$, "-|>"),
			edge((0, 0.75), (1, 0.75), $w_j$, "-|>"),

			node((1, 0.5), $G_(i j)^k (w_i, w_j)$,
				shape: fletcher.shapes.rect, stroke: black, inset: 1em),

			edge((1, 0.5), (2, 0.5), $w_k$, "-|>"),
		)]
][
#pause
3. Now encrypt gates: *$Gamma_(i j)^k$*
	#scale(75%, reflow: true)[
	$	Gamma_(i j)^k = {&"Enc"_(w_i^0, w_j^0) (w_k^(G_(i j)^k (w_i^0,w_j^0))),\
				&"Enc"_(w_i^0, w_j^1) (w_k^(G_(i j)^k (w_i^0,w_j^1))),\
				&"Enc"_(w_i^1, w_j^0) (w_k^(G_(i j)^k (w_i^1,w_j^0))),\
				&"Enc"_(w_i^1, w_j^1) (w_k^(G_(i j)^k (w_i^1,w_j^1)))}
	$]
]


== Garbled Circuits #h(8em) #text(blue, size: 20pt)[https://eprint.iacr.org/2014/756]
4. Garbler sends to the evaluator
	- the *garbled circuit*: ${Gamma_(i j)^k| i,j,k in C}$
	- his *active input labels*: $w_i, i in II_G$
	- the evaluator's *input labels*: $O T(w_i^0, w_i^1), i in II_E$
#pause
+ Evaluator evaluates the circuit until he gets the\ *active output labels*:
   $w_i, i in OO$
#pause
+ Output decoding:
	- (either) garbler sends *decoding information* $f: w_i arrow.r
	  c_i, i in OO$
	- (or) evaluator sends *active output labels* $w_i, i in OO$
Optimizations: Row reduction, Free XOR, Half gates, Fixed key AES

== Oblivious Linear Evaluation (OLE)#h(1em) #text(blue, size: 20pt)[https://eprint.iacr.org/2017/617]
#align(center + horizon, 
	diagram(
		node((0, 1), [$P_A$]),

		edge((0.75, 0.75), (2, 0.75), label: $a$, "-|>"),
		edge((0.75, 1.25), (2, 1.25), $x$, "-|>"),
		edge((0.75, 1.3), (2, 1.3), "<|-"),

		node((2, 1), "OLE", stroke: 1pt, inset: 3em),

		edge((2, 0.75), (3, 0.75), $b$, "<|-"),
		edge((2, 1.25), (3, 1.25), $y$, "-|>"),

		node((3.5, 1), [$P_B$]),
		node((4, 1.5), [$a,b,x,y in FF$])
	)
)
such that $y(b) = a dot b + x <=> y - x = a dot b$ 

- sometimes also called M2A
- building block for A2M and IZK
- *VOLE*: $y_k = a_k dot b  + x_k$

== Preprocessing
1. Specify *expected traffic* upfront: `max_sent`, `max_recv`, `max_recv_online`
#pause
2. OT Setup:
	- Base OTs: *CO15* (#text(blue, size: 21pt)[https://eprint.iacr.org/2014/756])
	- OT Extension: *KOS15* (#text(blue, size: 21pt)[https://eprint.iacr.org/2015/546])\
        	for GC, Key Exchange, PRF, GHASH, En-/Decryption
	- OT Extension: *Ferret* (#text(blue, size: 21pt)[https://eprint.iacr.org/2020/924])\
		for interactive ZK 
#pause
3. Prover *garbles circuits* and sends them to notary
	- En-/Decryption circuits
	- Key Exchange and PRF circuit
#pause
4. Setup *interactive ZK*

#tum-slide(15)

== Pseudorandom Function (PRF)
*Expansion of PMS* by PRF, here with TLS 1.2 AES-GCM PRF:
$ P_"hash" &:= bar.v.double_(i=1)^2 P_i, #h(1em) P_i := "HMAC"_"SHA256" (k, A_i || A_0) \
 k &- "key, either PMS or MS" \
pause
 A_i := &"HMAC"_"SHA256" (k, A_(i - 1)), A_0 := L || S \
 L &- "label, fixed string e.g. \"master secret\"" \
 S &- "seed, e.g. client_random || server_random" \
pause
 "HMAC"_"SHA256" (k, m) &= H((k plus.circle "opad") || H ((k plus.circle "ipad")
 || m))
$
- Compute $P_"hash"$ with GC to obtain *session keys*, (client/server finished vd)

== En-/Decryption AES-GCM
#slide(composer: 2)[
	Request Encryption
#align(left + top,
	box(
		scale(75%, reflow: true,
			diagram(spacing: 2em,
			node((1, 0), [Prover], stroke: 2pt, shape: circle, inset: 0.5em),

			node((1, 1), [CWK, \ plaintext], stroke: 1pt),
			edge((1, 1), (2, 1), "-|>"),

			edge((0, 2), (1, 2), "<|-"),
			node((1, 2), [ciphertext], stroke: 1pt),
			edge((1, 2), (2, 2)),

			node(enclose: ((2, 1), (2,2)), [AES\ CTR], stroke: 1pt, inset:
			1em, shape: rect),

			node((3, 0), [Verifier], stroke: 2pt, shape: circle, inset: 0.5em),

			node((3, 1), [CWK], stroke: 1pt, shape: rect),
			edge((3, 1), (2, 1), "-|>"),

			edge((4, 2), (3, 2), "<|-"),
			node((3, 2), [ciphertext], stroke: 1pt),
			edge((3, 2), (2, 2)),
			)
		)
	)
)
	- Prover inputs the *plaintext*
	- *Both parties* learn the *ciphertext*
][
	#pause
	Response Decryption
#align(right + top,
	box(
		scale(75%, reflow: true,
			diagram(spacing: 2em,
			node((1, 0), [Prover], stroke: 2pt, shape: circle, inset: 0.5em),

			node((1, 1), [SWK, \ ciphertext], stroke: 1pt),
			edge((1, 1), (2, 1), "-|>"),

			edge((0, 2), (1, 2), "<|-"),
			node((1, 2), [plaintext], stroke: 1pt),
			edge((1, 2), (2, 2)),

			node(enclose: ((2, 1), (2,2)), [AES\ CTR], stroke: 1pt, inset:
			1em, shape: rect),

			node((3, 0), [Verifier], stroke: 2pt, shape: circle, inset: 0.5em),

			node((3, 1), [SWK, \ ciphertext], stroke: 1pt, shape: rect),
			edge((3, 1), (2, 1), "-|>"),
			)
		)
	)
)
	- *Both parties* input the *ciphertext*
	- *Only prover* learns the *plaintext*
	- Optimization: *Defer decryption*
]

== GHASH
*MAC* for authenticity of encrypted messages per TLS record in AES-GCM
$ "MAC"_"GHASH" = J_0 &plus.circle sum_(k=1)^l H^(l - k) B_k, "with" J_0, H, B in FF_(2^128) \
pause
J_0 &= "AES"_"CTR" (k, "IV", "ctr" = 1, 0^128) \
H &= "AES"_"ECB" (k, 0^128) \
B &- "encrypted AES request/response block"
$ 

#pause
+ Compute shares of $J_0 = J_(0, 1) plus.circle J_(0, 2)$
+ Compute  shares of $sum_(k = 1)^l H^(l - k) B_k = sum_(k = 1)^l H_1^(l -k) B_k
  plus.circle sum_(k = 1)^l H_2^(l -k) B_k$

== Proving
- *After closing the TLS connection* verifier has no secrets anymore!
#pause
- Use an efficient IZK protocol (Quicksilver: #text(blue, size:
  21pt)[https://eprint.iacr.org/2021/076]) \
	- Use subfield VOLE to *create MACs* and check their transformation under
	  the circuit: $ #text(fill: green)[$m_i$] = #text(fill: blue)[$k_i$]
	  + #text(fill: blue)[$Delta$] dot #text(fill: green)[$u_i$],
	  "with" m_i, k_i in FF_(2^128)^l, u_i in F_2^l, Delta in F_(2^128) $
#pause
- Verifier and prover *decode* the verifier's secret inputs and prover *proves*
	+ *all GC computations* of the entire protocol
	+ that he knows the *cleartext of the server responses*
Optimizations: Decode server-write-key for verifier 

== Creating Commitments
#slide(composer: 2)[
=== Prover
#uncover("2-")[
#v(2em)
2. Prover adapts $m_i$  and creates *blinded commitments* $H_i (b_i, m_k..m_(k + l))$ and sends *merkle
  root* of $R(H_i| i=1..)$ to notary
#v(1em)
]
#uncover("4-")[
4. Prover can now create a *presentation* for verifiers
]
][
=== Notary
#uncover("1-")[
1. Notary *adapts his keys*:\ $k_i
  arrow.r "Prg"(s, i)$ and *sends* \ $delta_i := "Prg"(s, i) plus.circle k_i$ to prover
#v(2em)
]
#uncover("3-")[
3. Notary sends to Prover  a *signed attestation* $A = {s, Delta, R(H_i), ...}$
#v(1em)
]
#uncover("4-")[
Other commitments: SHA256, AES, ...
]
]

== Thank you!
#slide(composer: 2)[
#let thanks = image("tum-presi/26.svg")
#utils.fit-to-height(80%, thanks)
][
#align(horizon)[
	- `https://tlsnotary.org`
	- `https://explorer.tlsnotary.org`
	- `https://docs.tlsnotary.org`
	#v(1em)
	- `https://github.com/tlsnotary/tlsn`
	- `https://github.com/tlsnotary/tlsn-js`
	- `https://github.com/tlsnotary/tlsn-extension`
]
]

= BACKUP

== CO15 Protocol #h(8em) #text(blue, size: 20pt)[https://eprint.iacr.org/2015/267]
#align(center + horizon,
	box(
		scale(85%, reflow: true,
			diagram(spacing: 1em,
				node((0, 0), $P_S " Input": (m_0, m_1)$),
				node((3, 0), $P_R "Input: c Output:" m_c$),
				node((0, 1), $a arrow.l ZZ_p$),
				node((3, 1), $b arrow.l ZZ_p$),
				edge((0.5, 2), (2.5, 2), $A = g^a$, "-|>"),
				pause,

				node((3, 3), $"if" c = 0: B = g^b$),
				node((3, 3.5), $"  if" c = 1: B = A g^b$),
				edge((0.5, 4.5), (2.5, 4.5), $B$, "<|-"),
				pause,

				node((0, 5), $k_0 = H(B^a)$),
				node((0, 5.75), $k_1 = H((frac(B, A))^a)$),
				pause,

				edge((0.5, 8.5), (2.5, 8.5), $(e_0 , e_1) = (E_(k_0)(m_0), E_(k_1)(m_1))$, "-|>"),
				node((3, 5), $k_R = H(A^b)$),
				node((3, 9), $m_c = D_(k_R)(e_c)$),
			)
		)
	)
)

== VOLE (MASCOT COPEe) #h(5em) #text(blue, size: 20pt)[https://eprint.iacr.org/2016/505]
#align(center + horizon,
	box(
		scale(85%, reflow: true,
			diagram(spacing: 1em,
			edge((-0.5, 1), (0.5, 1), label: $(t_0^i, t_1^i)$, "<|-"),
			node((0.5, 1), $"ROT"_"i"$, stroke: 1pt, inset: 3em),
			edge((0.5, 0.75), (2, 0.75), $b_i$, "<|-"),
			edge((0.5, 1.25), (2, 1.25), $t_(b_i)^i$, "-|>"),
			node((3, 0), $P_B " Input:" b in FF$),


			node((-0.5, -1), [*Setup:*]),
			node((0, 2), $s_(i, 0)^k := "PRF" (t_0^i, k),
				s_(i, 1)^k := "PRF" (t_1^i, k)$, ),
			node((0, 0), $P_A$),

			node((0.5, 0), $t_0^i, t_1^i in FF$),
			)
		)
	)
)

== VOLE (MASCOT COPEe) #h(5em) #text(blue, size: 20pt)[https://eprint.iacr.org/2016/505]
#align(center + horizon,
	box(
		scale(85%, reflow: true,
			diagram(spacing: 1em,
			node((0, 0), [*Extend:*]),
			node((0, 1), $P_A " Input:" a_k in FF$),
			node((4, 1), $P_B " Input:" b in FF$),
			edge((0, 4), (4, 4), $u_i^k := s_(i, 0)^k - s_(i, 1)^k +
			a_k$,"-|>"),


			node((0, 6), $x_i^k := s_(i, 0)^k$),

			node((4, 6), $y_i^k &= b_i dot u_i^k +
			s_(i, b_i)^k \
			&= b_i (s_(i, 0)^k - s_(i, 1)^k + a_k) + s_(i, b_i)^k \
			&= b_i dot a_k + s_(i, 0)^k
			$),
			

			node((0, 7), $" Output:" x_k = sum 2^i x_i^k $),
			node((4, 7), $" Output:" y_k = sum 2^i y_i^k$),
			)
		)
	)
)

== Key Exchange
#slide(composer: (33%, 33%, 33%))[
#align(left)[
	$ "Prover:"\ P := (x_p, y_p) = p_p dot S $

	]
][
#align(center)[
	#v(1.5em)
	$ (x_r, #text(fill: gray, $y_r$)) &:= P plus.circle V $

	]

][
#align(right)[
	$ "Verifier:"\ V := (x_v, y_v) = p_v dot S $
	]
][#grid.cell(colspan: 3)[
#align(center)[
	#scale(80%, reflow: true)[
		#pause
		$ "Then: " x_r &= ((y_p - y_v)/(x_p - x_v))^2 - x_p - x_v \
		#pause
			2 dot "A2M" arrow.r x_r &= (A_p / B_p)^2 dot (A_v / B_v)^2 - x_p - x_v \
		#pause
			&= C_p dot C_v - x_p - x_v \
		#pause
			"M2A" arrow.r x_r &= (D_p -x_p) + (D_v - x_v) =: "PMS"_p +
			"PMS"_v
		$
	]
	#pause
	#text(size: 20pt)[Rerun with *roles swapped* in A2M, M2A and then check for
	  equality with GC]
	]
]]

== PRF Optimization
Roundtrip/bandwidth tradeoff with *local hash* computation: \
#v(0.25em)
Trick: $H(m_1 || m_2) = f_H (f_H ("IV", m_1), m_2)$, \
#h(1em) with SHA2 compression func: $f_H ("state", m)$
#pause
#v(0.25em)
Then: computation in #text(fill: red)[GC], #text(fill: blue)[cached GC], #text(fill: green)[local]
$ "HMAC"_"SHA256" &= #text(fill: red, $f_H ($) s_1, s_2
				#text(fill: red, $)$) \
			s_1 &= #text(fill: blue, $f_H ("IV", k plus.circle "opad")$) \
			s_2 &=#text(fill: green, $f_H ($)
				#text(fill: blue, $f_H ("IV", k plus.circle "ipad")$)
				#text(fill: green, $, m)$)
$ 
#pause
$arrow.double$ \~50% reduction of upload size, but more roundtrips

== GHASH 
+ $J_0$ computation:
	- #text(fill: green)[Prover]: $J_(0, 1) =  #text(fill: green)[$m_1$] $
	- #text(fill: blue)[Verifier]: $J_(0, 2) = #text(fill: red)[GC(]"AES"_"CTR"
		(k, "IV", "ctr" = 1, 0^128) plus.circle #text(fill: green)[$m_1$]
		plus.circle #text(fill: blue)[$m_2$] #text(fill: red)[)] plus.circle
		#text(fill: blue)[$m_2$] )$
#pause
+ $H^k$ computation ($k=1026$):
	+ Compute $H_1$ and $H_2$ *like $J_0$* but with $"AES"_"ECB" (k, 0^128)$ instead
	+ With *A2M* convert $H = H_1 plus.circle H_2 arrow.r H = H_1^* dot H_2^* $
	+ Prover and verifier *each locally compute* $(H_1^*)^k$ and  $(H_2^*)^k$
	+ With *M2A* convert each power back to additive shares $H_1^k$ and $H_2^k$
#pause
$"MAC"_"GHASH" = M_1 plus.circle M_2 = J_(0, 1) plus.circle sum_(k = 1)^l
H_1^(l-k) B_k plus.circle J_(0, 2) plus.circle sum_(k = 1)^l H_2^(l-k) B_k
$

Optimizations: Free squaring, Batch verify

