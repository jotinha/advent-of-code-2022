all: main.pl
	perl $< 

image: image.txt
	@cat image.txt

image.txt: main.pl
	@$(MAKE) all	
