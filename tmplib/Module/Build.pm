use File::Find;

module Module::Build;

sub path-to-module-name($path) {
    $path.subst(/^'lib/'/, '').subst(/\.pm6?$/, '').subst('/', '::', :g)
}

sub module-name-to-path($module-name) {
    my $pm = 'lib/' ~ $module-name.subst('::', '/', :g) ~ '.pm';
    $pm.IO ~~ :e ?? $pm !! $pm ~ '6';
}

our sub build(Str $dir = '.', Str $binary = 'perl6', :$v) {
    if "$dir/Configure.pl".IO ~~ :f {
        my $cwd = cwd;
        chdir $dir;
        run 'perl6 Configure.pl' and die "Configure.pl failed";
        chdir $cwd;
    }
    if $*VM<config><osname> ne 'MSWin32'
    && "$dir/Makefile".IO ~~ :f {
        my $cwd = cwd;
        chdir $dir;
        run 'make' and die "'make' failed";
        chdir $cwd;
        return;
    }

    my @module-files = find(dir => "$dir/lib", name => /\.pm6?$/).list;

    # To know the best order of compilation, we build a dependency
    # graph of all the modules in lib/. %usages_of ends up containing
    # a graph, with the keys (containing names modules) being nodes,
    # and the values (containing arrays of names) denoting directed
    # edges.

    my @modules = map {
            path-to-module-name($_.Str.subst(/\.\/lib\//, ''))
        }, @module-files;
    my %usages_of;
    for @module-files -> $module-file {
        my $fh = open($module-file, :r);
        my $module = $module-file.name;
        %usages_of{$module} = [];
        for $fh.lines() {
            if /^\s* 'use' \s+ (\w+ ['::' \w+]*)/ && $0 -> $used {
                next if $used eq 'v6';
                next if $used eq 'MONKEY_TYPING';

                %usages_of{$module}.push(~$used);
            }
        }
    }

    my @order;

    # According to "Introduction to Algorithms" by Cormen et al.,
    # topological sort is just a depth-first search of a graph where
    # you pay attention to the order in which you get done with the
    # dfs-visit() for each node.

    my %color_of = @modules X=> 'not yet visited';
    for @modules -> $module {
        if %color_of{$module} eq 'not yet visited' {
            dfs-visit($module);
        }
    }

    sub dfs-visit($module) {
        %color_of{$module} = 'visited';
        for %usages_of{$module}.list -> $used {
            if %color_of{$used} eq 'not yet visited' {
                dfs-visit($used);
            }
        }
        push @order, $module;
    }

    for @order».&module-name-to-path -> $module {
        my $pir = $module.subst(/\.pm6?/, ".pir");
        next if ($pir.IO ~~ :f &&
                $pir.IO.stat.modifytime > $module.IO.stat.modifytime);
        my $command = "$binary --target=PIR --output=$pir $module";
        say $command if $v.defined;
        run $command and die "Failed building $module"
    }
}

# vim: ft=perl6
