package CompilerWrapper::GCC;

use 5.006;
use strict;
use warnings FATAL => 'all';
use List::MoreUtils qw(uniq);
use File::Find::Rule;

=head1 NAME

CompilerWrapper::GCC - Wrapper for the g++ command !

=head1 VERSION

Version 1.01

=cut

our $VERSION = '1.03';


=head1 SYNOPSIS

CompilerWrapper-GCC aims to be a simplified wrapper for the g++, with sane defaults and
powerful options.

=head1 EXPORT
all =
    findSourceFiles
    omitFilesByMatching
    getSourceFiles
    setOutputName
    resetExclusions
    getExclusions
    getCommand
    setSkipRevision
    getSkipRevision
    addGlutFlags
    addDebugFlags
    compileUnsafe

=cut
require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = (
    'all' => [ qw(
        findSourceFiles
        omitFilesByMatching
        getSourceFiles
        setOutputName
        resetExclusions
        getExclusions
        getCommand
        setSkipRevision
        getSkipRevision
        addGlutFlags
        addDebugFlags
        compileUnsafe
    ) ],
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

my @sourcefiles; # This array stores all the cpp filenames that will be compiled
my @exclusions; # This array stores all the cpp filenames that have been found but deleted
my $command = "g++ -Wall -Wextra -Werror -Wcast-align -Wcast-qual -Wconversion -pedantic -std=c++11 ";
my $skipfilefilter = 0;
my $outputname = "-o a.out";


=head1 SUBROUTINES/METHODS

=head2 findSourceFiles
Checks if argument is a directory name or a filename
and passes the argument to the relevant private function
Returns success
=cut
sub findSourceFiles{
    my ($filepath) = @_;

    if($filepath =~ /\.cpp$/){
        # Ends with .cpp so assuming file
        return &addDirectFile($filepath);
    }
    # No pattern in string so assuming directory
    return &addDirectory($filepath);
}

=head2 addDirectFile
Checks if a file at the giver path exists
if yes adds it to @sourcefiles
Returns success
=cut
sub addDirectFile{
    my ($filepath) = @_;

    if(-e $filepath){
        push(@sourcefiles, $filepath);
        @sourcefiles = uniq @sourcefiles; # Remove duplicates
        return 1;
    }
    return 0;
}

=head2 addDirectory
Accepts a directory path, uses File::Find to get all the files that end with .cpp
and adds it to @sourcefiles
Returns success
=cut
sub addDirectory{
    my ($directory) = @_;

    my @cppfilesindir = File::Find::Rule->file()->name('*.cpp')->in($directory);
    if(@cppfilesindir){
        push(@sourcefiles, @cppfilesindir);
        @sourcefiles = uniq @sourcefiles; # Remove duplicates
        return 1;
    }
    return 0;
}

=head2 omitFilesByMatching
Accepts a piece of text and removes every occurence in @sourcefiles
where the piece of text matches.
Everything deleted will be saved in @exclusions for safekeeping & reporting
Returns undef
=cut
sub omitFilesByMatching{
    my ($input) = @_;
    push(@exclusions, grep(/$input/i, @sourcefiles)); # Store everything that matches seperately
    @sourcefiles = grep(!/$input/i, @sourcefiles); # Keep everything that doesn't match
    @exclusions= uniq @exclusions; # Remove duplicates
}

=head2 resetExclusions
Pushes @exclusions back on @sourcefiles
Returns undef
=cut
sub resetExclusions{
    push(@sourcefiles, @exclusions);
    @sourcefiles = uniq @sourcefiles; # Remove duplicates
    $#exclusions = -1;
}

=head2 getSourceFiles
Returns the array of all the found and non-deleted filenames sorted
=cut
sub getSourceFiles{
    @sourcefiles = sort(@sourcefiles);
    return @sourcefiles;
}

=head2 getExclusions
Returns the array of all the found and deleted filenames sorted
=cut
sub getExclusions{
    @exclusions = sort(@exclusions);
    return @exclusions;
}

=head2 setOutputName
Changes the variable holding the output name of the file produced by the script
Returns undef
=cut
sub setOutputName{
    my (undef, $filename) = @_;
    $outputname = "-o $filename";
}

=head2 setSkipRevision
Toggles skipping of the manual verification of files found by this script
Returns undef
=cut
sub setSkipRevision{
    $skipfilefilter = $skipfilefilter ? 0 : 1;
}

=head2 getSkipRevision
Returns 1 or 0
=cut
sub getSkipRevision{
    return $skipfilefilter;
}

=head2 addGlutFlags
Add flags for compiling with opengl support
Returns undef
=cut
sub addGlutFlags{
    if($command !~ /-lglut -lm -lGL -lGLU/){
        $command = "$command-lglut -lm -lGL -lGLU ";
    }
}

=head2 addDebugFlags
Add extra debugging flags -> I prefer GDB so using those flags
=cut
sub addDebugFlags{
    if($command !~ /-ggdb -g3/){
        $command = "$command-ggdb -g3 ";
    }
}

=head2 compileUnsafe
Remove -werror flag causing project to build even with errors
=cut
sub compileUnsafe{
    $command =~ s/\-Werror//
}

=head2 getCommand
Returns what we wanted all along, a string we can parse to terminal invoking g++
=cut
sub getCommand{
    my $output = $command;
    foreach my $item (@sourcefiles){
        $output = "$output$item ";
    }
    return "$output$outputname";
}


=head1 AUTHOR

Numkil, C<< <Numkil at hotmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-compilerwrapper-gcc at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CompilerWrapper-GCC>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

perldoc CompilerWrapper::GCC


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CompilerWrapper-GCC>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CompilerWrapper-GCC>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CompilerWrapper-GCC>

=item * Search CPAN

L<http://search.cpan.org/dist/CompilerWrapper-GCC/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Numkil.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of CompilerWrapper::GCC
