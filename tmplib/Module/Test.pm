module Module::Test;

our sub test(Str $dir = '.', Str $binary = 'perl6') {
    if $*VM<config><osname> ne 'MSWin32'
    && "$dir/Makefile".IO ~~ :f {
        my $cwd = cwd;
        chdir $dir;
        run 'make test' and die "'make test' failed";
        chdir $cwd;
    }
    if "$dir/t".IO ~~ :d {
        my $command = "PERL6LIB=$dir/lib prove -e $binary -r $dir/t/";
        run $command and die 'Testing failed';
    }
}

# vim: ft=perl6
