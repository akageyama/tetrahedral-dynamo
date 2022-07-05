default_target: runme
	./runme


runme: \
		constants.o \
		main.o \
		ut.o
	gfortran -o runme constants.o main.o ut.o

constants.f90: con.ef
	./efpp.py con.ef > constants.f90

ut.f90: ut.ef
	./efpp.py ut.ef > ut.f90
ut.o: ut.f90
	gfortran -c ut.f90	

main.f90: mai.ef
	./efpp.py mai.ef > main.f90

constants.o: constants.f90
	gfortran -c constants.f90
main.o: constants.o
main.o: main.f90
	gfortran -c main.f90

clean:
	rm *.f90 *.o *.mod	
