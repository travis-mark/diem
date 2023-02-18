all: diem nsdate

bin:
	mkdir -p bin

diem: bin
	${CC} -framework Foundation diem.m -o bin/diem 

nsdate: 
	${CC} -framework Foundation nsdate.m -o bin/nsdate 

install: diem nsdate
	mkdir -p ${HOME}/local/bin
	cp bin/* ${HOME}/local/bin/