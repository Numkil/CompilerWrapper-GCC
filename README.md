GppWrapper
=======
GppWrapper aims to be a simplified wrapper for the g++, with sane defaults and
powerful options.

* Flags with relations to each other are bundled together and
only require 1 general flag to be provided. 
* Instead of single .cpp files you can now also give directories as arguments, even mix them together or combine them with
single files. 
* There is also a regex matcher included that will let you omit
files that match the given pattern. 

This is not intended to be a replacement for a well made MakeFile. It is
intended for
learning purposes where people might not have had the opportunity to learn
MakeFiles and will probably start a lot of very small projects.

Details
------------
**Required packages:** 

    Perl, Perl-Find::File::Rule, Perl-FindBin, Perl-Getopt::Long,
    Perl-List::MoreUtils
    (for testing)Perl-Test::Simple

**Installation:**

To install this module, run the following commands:

	perl Makefile.PL
	make
	make test
	make install


**Usage:**

    1: gppcompile[paths to directories of the sourcefiles you want][possible flags]
    2: Review the list of files found by the script
    3: Type in the part of the names of the files you want to exclude 
       The regex is quite greedy so be careful
    4: Finish the loop with typing N
    5: Review your omissions and potentially go back to 2 
    5: Done!

**Options:**

    -s||--skip        :  Skip reviewing and omission of files, compile without any 
                         questions 
    -g||--glut        :  Add extra flags needed for compiling projects with opengl
                         implementations.
    -o||--outputname  :  Choose your own name for the generated binary instead
                         of a.out
    -d||--debug       :  Add extra flags to the compiler to include debug
                         symbols in the binary. This way you can use a debugger on the binary.
                         I prefer using gdb so the flags I have chosen favour this debugger.
                         Only use this when actually going to debug as it
                         increases compile time and binary size.
    -u||--unsafe      :  Compiler compiles with warnings 

**Planned changes:**
    
1: Playing around with different compiler flags, trying to find the perfect "general use" combination.
   I want it to be balanced and usable in 99% of use cases for beginners.
