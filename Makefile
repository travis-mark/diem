all: diem nsdate

bin:
	mkdir -p bin

cal_txt: bin
	${CC} -framework EventKit -framework Foundation cal_txt.m -o bin/cal_txt

diem: bin
	${CC} -framework Foundation diem.m -o bin/diem 

nsdate: bin
	${CC} -framework Foundation nsdate.m -o bin/nsdate 

install: cal_txt diem nsdate
	chmod +x bin/*
	mkdir -p ${HOME}/local/bin
	cp bin/* ${HOME}/local/bin/