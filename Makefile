#
# Makefile for tetra-dynamo
#
#   Akira Kageyama (kage@port.kobe-u.ac.jp)
#     2022.07.08: Copied from yyz-relax code.
#

.SUFFIXES:

eflist := $(shell ls *.ef)   # e.g., example.ef
filebase := $(basename $(notdir $(eflist))) # => example
f90list := $(addsuffix .F90, $(filebase)) # => example.F90
modlist := $(addsuffix .mod, $(filebase)) # => example.mod
objlist := $(addsuffix .o, $(filebase)) # => example.o

# ES3_HOME = /S/home00/G4013/y0394

.SECONDARY: $(f90list)  # to avoid deleting F90 files.
       # .SECONDARY: obj/%.F90 does not work (GNU Make 3.81).


.PHONY: clean line list


%.F90: %.ef
	$(EFPP) $< > $@

%.o: %.F90
	$(FC) $(FFLAGS) -o $@ -c $<

EFPP = ../bin/efpp.py

# FC = mpifort
FC = 
FFLAGS :=
# FFLAGS += -fopenmp
# FFLAGS += -fcheck=all
# FFLAGS += -Wall
# FFLAGS += -fbounds-check
# FFLAGS += -fcheck-array-temporaries
# FFLAGS += -O0
# FFLAGS += -Wuninitialized
# FFLAGS += -ffpe-trap=invalid,zero,overflow
# FFLAGS += -g
# FFLAGS += -fbacktrace

# # # # # # # # # # # # # # # # # # # # # # # # # # # 
#  this_host := $(shell hostname | cut -c1-3)
#  
#  ifeq ($(this_host),alf)  # Alfven
#          EFPP = ../bin/efpp.py2
#          FC = mpinfort
#          FFLAGS = 
#  endif
#  ifeq ($(this_host),pi)  # Kobe
#         FC = mpifrtpx
#         FFLAGS = -X03 -Free -Kopenmp -NRtrap
# endif
# ifeq ($(this_host),mac)  # Mac
#         EFPP = ../bin/efpp.py
#         FC = mpifort
#         FFLAGS = 
# endif
# ifeq ($(this_host),ofp)  # Oakforest PACS
#         EFPP = ../bin/efpp.py
#         FC = mpiifort
#         FFLAGS := -O3
#         FFLAGS += -qopenmp
#         FFLAGS += -axMIC-AVX512
#         FFLAGS += -fpe0
#         FFLAGS += -ftrapuv
#         FFLAGS += -align array64byte
#         FFLAGS += -qopt-threads-per-core=1
#         #FFLAGS += -CB  # check bounds
#         #FFLAGS += -check all
#         #FFLAGS += -warn all
#         #FFLAGS += -traceback
# endif
# ifeq ($(this_host),fes)  # NIFS
#         EFPP = ../bin/efpp.py2
#         FC = mpifrtpx
#         FFLAGS := -Kopenmp
#         # FFLAGS += -X03 -Free -NRtrap -Qt -Koptmsg=2
#         # FFLAGS += -Haefosux
#         # FFLAGS += -g
#         # FFLAGS += -Nquickdbg=argchk
#         # FFLAGS += -Nquickdbg=subchk
# endif
# ifeq ($(HOME),$(ES3_HOME)) # JAMSTEC
#         EFPP = ../../../bin/efpp.py2
#         #EFPP = ../bin/efpp.py2
#         FC = sxmpif03 # at cg-mhd, must sxmpif03, not sxmpif90
#         #FC = sxmpif90 # at yyz-relax, must sxmpif90, not sxmpif03
#         FFLAGS := -P openmp
#         FFLAGS += -ftrace
#         FFLAGS += -R transform fmtlist
#         FFLAGS += -pvctl fullmsg
#          #FFLAGS += -R2
#          #FFLAGS += -Wf"-pvctl fullmsg"
#          #FFLAGS += -eR
# endif
# # # # # # # # # # # # # # # # # # # # # # # # # # # 


# default target

yyz_relax: $(objlist)
	$(FC) $(FFLAGS) -o yyz_relax $(objlist)


-include depend_list.mk


depend_list.mk: *.ef
	../bin/gendep.sh > $@ 




#
# For the print-out list of the source code.
#   Note: Utility libraries "mpiut.e03" and "ut.e03" are skipped
#         Since they are too long
#
print_files := Makefile
print_files += efpp_alias.list
print_files += $(shell ls ../bin/*.sh)
print_files += job/mkjob.sh src/sample.namelist
print_files += $(shell ls *.e03  \
			| sed '/turtle.e03/d' \
			| sed '/turtle_epslib.e03/d' \
			| sed '/kutimer.e03/d' \
			| sed '/ut.e03/d' \
			| sed '/mpiut.e03/d' )

#
# list of the source code.
#
list:
	../bin/print-source-files-to-pdf.sh $(print_files)


line:
	@echo "="{1..100} | sed 's/[ 0-9]//g' # bash one-liner for a line



clean:
	rm -rf list.ps list.pdf
	rm -rf depend_list.mk
	rm -rf *.o *.lst *.F90 *.mod *.L
	rm -rf yyz_relax