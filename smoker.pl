#!/usr/bin/env perl6
use v6;

my @list = qx[./neutro l].split("\n").grep({$_});

for @list -> $module {
	print "$module: ";
	my $result = qqx[./neutro i $module --strict --nocolor];
	my @lines = $result.split("\n").grep({$_});
	my $lastline = @lines[@lines.end];
	given $lastline {
		when /:s Tests failed for $module/ {
			say 'tests failed'
		}
		when /:s Tests failed/ {
			say 'tests failed for some dependencies'
		}
		when /:s Succesfully installed $module/ {
			say 'ok'
		}
		when /:s No tests for $module/ {
			say 'no tests available'
		}
		when /:s Building $module failed/ {
			say 'building failed'
		}
		when /:s Building .+ failed/ {
			say 'building dependencies failed'
		}
		when /:s Configure.pl has failed for $module/ {
			say 'Configure.pl failed'
		}
		when /:s Configure.pl has failed/ {
			say 'building dependencies failed'
		}
		when /:s Installing $module failed/ {
			say 'installing failed'
		}
		when /:s Installing .+ failed/ {
			say 'installing dependencies failed'
		}
		default {
			say "Unknown result: '$lastline'"
		}
	}
}

# vim: ft=perl6
