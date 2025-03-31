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
#for k in range(4, 9) {
	tum-slide(k)
}
#for k in range(11, 13) {
	tum-slide(k)
}

== TLSNotary Protocol

#slide[
	=== Techniques
	- Oblivious Transfer
	- Garbled Circuits
	- (V)OLE, M2A, A2M
	- Interactive ZK
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



== CO15 Protocol #h(8em) #text(blue, size: 20pt)[https://eprint.iacr.org/2015/267]
#align(center + horizon,
	box(
		scale(85%, reflow: true,
			diagram(spacing: 1em,
				node((0, 0), $P_S " Input": (m_0, m_1)$),
				node((3, 0), $P_R " Output:" m_c$),
				node((0, 1), $a arrow.l ZZ_p$),
				node((3, 1), $b arrow.l ZZ_p$),
				edge((0.5, 2), (2.5, 2), $A = g^a$, "-|>"),
				pause,

				node((3, 3), $"if" c = 0: B = g^b$),
				node((3, 3.5), $"  if" c = 0: B = A g^b$),
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
	- the garbled circuit: ${Gamma_(i j)^k| i,j,k in C}$
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
Optimizations: Row reduction, Free XOR, Half gates

== (V)OLE


// in preprocesing talk about OT pipeline and GC preprocessing
// en-/decryption: AES, GHASH, DEAP
// proving: quicksilver
// commitments: transformation of commitments to prg
