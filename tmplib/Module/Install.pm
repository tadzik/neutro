#use File::Copy;
use File::Find;
use File::Mkdir;

module Module::Install;

our sub install(Str $dir = '.', Str $dest = "%*ENV<HOME>/.perl6/", :$v) {
    if $*VM<config><osname> ne 'MSWin32'
    && "$dir/Makefile".IO ~~ :f {
        my $cwd = cwd;
        chdir $dir;
        run 'make install' and die "'make install' failed";
        chdir $cwd;
    } else {
        my @files = find(dir => "$dir/lib", name => /[\.pm6?$] | [\.pir$]/).list;
        if "$dir/bin".IO ~~ :d {
            for find(dir => "$dir/bin").list {
                @files.push: $_
            }
        }
        for @files -> $file {
            my $target-dir = $file.dir.subst(/\.\//, $dest);
            mkdir $target-dir, :p;
            say "Installing $file" if $v.defined;
#            say "Starting copying $pmfile, sized {
#                $pmfile.Str.IO.stat.size} bytes";
#            my $t = time;
#            cp ~$file, "$target-dir/{$file.name}";
#            say "Done copying, took {time() - $t} seconds";
            run "cp $file $target-dir/{$file.name}";
        }
    }
}

# vim: ft=perl6
