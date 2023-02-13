all: diem

bin:
	mkdir -p bin

diem: bin
	${CC} -framework Foundation diem.m -o bin/diem 

install: diem
	mkdir -p ${HOME}/local/bin
	cp bin/* ${HOME}/local/bin/