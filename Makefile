all: diem nsdate

bin:
	mkdir -p bin

calendar: bin
	${CC} -framework EventKit -framework Foundation calendar.m -o bin/calendar 

diem: bin
	${CC} -framework Foundation diem.m -o bin/diem 

nsdate: bin
	${CC} -framework Foundation nsdate.m -o bin/nsdate 

install: diem nsdate
	mkdir -p ${HOME}/local/bin
	cp bin/* ${HOME}/local/bin/