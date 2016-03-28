obj/fuckaduck:
	@mkdir -p obj
	cp *.lua obj
	
obj/%.so:
	cp *.so obj
obj/%.txt:
	cp help.xml obj
obj:
	mkdir $@
install:
	@mkdir -p /usr/local/lib/ugent
	cp obj/* /usr/local/lib/ugent
