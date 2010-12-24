module Module::Install;

#use File::Copy;
use File::Find;
#use File::Mkdir; TODO: For some reason this does not work.
sub mkdirp($name as Str) {
    for [\~] $name.split('/').map({"$_/"}) {
        mkdir($_) unless .IO.d
    }
}

our sub install(Str $dir = '.', Str $dest = "%*ENV<HOME>/.perl6/", :$v) {
    if $*VM<config><osname> ne 'MSWin32'
    && "$dir/Makefile".IO ~~ :f {
        my $cwd = cwd;
        chdir $dir;
        run 'make install' and die "'make install' failed";
        chdir $cwd;
    } else {
        my @files;
        if "$dir/lib".IO ~~ :d {
            for find(dir => "$dir/lib",
                    name => /[\.pm6?$] | [\.pir$]/).list {
                @files.push: $_
            }
        }
        if "$dir/bin".IO ~~ :d {
            for find(dir => "$dir/bin").list {
                @files.push: $_
            }
        }
        for @files -> $file {
            my $target-dir = $file.dir.subst(/^$dir\//, $dest);
            mkdirp $target-dir;
            say "Installing $file" if $v;
            if $*VM<config><osname> eq 'MSWin32' {
                run "copy $file $target-dir/{$file.name}";
            } else {
                run "cp $file $target-dir/{$file.name}";
            }
        }
    }
}

# vim: ft=perl6
