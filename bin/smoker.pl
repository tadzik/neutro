#!/usr/bin/env perl6
use v6;

run 'neutro update';
my @list = qqx[neutro list].split("\n").grep({$_});

for @list -> $module {
    print "$module - ";
    my $result = qqx[neutro $module --strict];
    my @lines = $result.split("\n").grep({$_});
    my $lastline = @lines[@lines.end];
    given $lastline {
        when /:s Tests failed for $module/ {
            say 'tests failed'
        }
        when /:s Tests failed/ {
            say 'unable to install dependencies'
        }
        when /:s Successfully installed $module/ {
            say 'ok'
        }
        when /:s No tests for $module/ {
            say 'no tests available'
        }
        when /:s Building $module failed/ {
            say 'building failed'
        }
        when /:s Building .+ failed/ {
            say 'unable to install dependencies'
        }
        when /:s Configure.pl has failed for $module/ {
            say 'Configure.pl failed'
        }
        when /:s Configure.pl has failed/ {
            say 'unable to install dependencies'
        }
        when /:s Installing $module failed/ {
            say 'installing failed'
        }
        when /:s Installing .+ failed/ {
            say 'unable to install dependencies'
        }
        when /:s Unknown module/ {
            say 'dependencies not in module ecosystem'
        }
        default {
            say "Unknown result: '$lastline'"
        }
    }
}

# vim: ft=perl6
