#################
Brian Bright 2018
#################

#########
Structure
#########

bin - compiled binaries
build - library archives
tests - unit testing source code & coverage data
src - source code and header files in src/includes



########
Makefile
########
	- test_coverage
		- takes all files ending in _test.c in the tests dir, compiles them with lcov in gcc,
		  runs them, and generates html with coverage data in a folder for each test in the tests dir

	- check
		- greps source code for potentially dangerous functions like strcpy

	- install
		- takes user-provided destination dir to install the project
	
	 
