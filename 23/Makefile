run: main.apl
	dyalogscript $<

animation: animate.apl clean
	mkdir frames
	dyalogscript $<
	convert frames/*.pnm animation.gif

clean:
	rm -rf frames

install:
	brew install dyalog
