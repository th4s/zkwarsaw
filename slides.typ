#import "@preview/touying:0.6.1": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

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


== Oblivious Transfer
#align(center)[
  #box[$P_R$ #v(4em)]
  #box[$x_i$ #line(length: 2cm) #v(3em) $y_i$ #line(length: 2cm) #v(1em)]
  #box[#square(size: 8em)[#v(3em) $"OT"_i$]]
  #box[$k_i = (b_i, a+b_i)$ #line(length: 2.5cm) #v(3em) $b_i$ #line(length: 2.5cm) #v(1em)]
  #box[$P_S$ #v(4em)]
]
- different variants: COT, ROT, k/n OT...

== CO15
#align(center)[
  #box[$P_R$ #v(4em)]
  #box[$x_i$ #line(length: 2cm) #v(3em) $y_i$ #line(length: 2cm) #v(1em)]
  #box[#square(size: 8em)[#v(3em) $"OT"_i$]]
  #box[$k_i = (b_i, a+b_i)$ #line(length: 2.5cm) #v(3em) $b_i$ #line(length: 2.5cm) #v(1em)]
  #box[$P_S$ #v(4em)]
]


== Garbled Circuits

== (V)OLE


// in preprocesing talk about OT pipeline and GC preprocessing
// en-/decryption: AES, GHASH, DEAP
// proving: quicksilver
// commitments: transformation of commitments to prg
