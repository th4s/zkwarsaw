#import "@preview/touying:0.6.1": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

// Import slides from older presentation
#let tum-slide(slide_num) = {
	let image = image("tum-presi/" + str(slide_num)  + ".svg")
	let fitted = utils.fit-to-height(100%, image)
	empty-slide(config: config-page(margin: (x: 0em, y: 0em)))[#fitted]
}

#for k in range(1, 12) {
	tum-slide(k)
}

== Oblivious Transfer


#slide[
	+ First column.
	- $sum_(i=2)^3 i^2$
][
	Second column.
]
