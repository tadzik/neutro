#!/bin/sh
git clone --depth 1 git://github.com/tadzik/perl6-Module-Tools.git mt
git clone --depth 1 git://github.com/tadzik/perl6-File-Tools.git ft
git clone --depth 1 git://github.com/moritz/json.git jt

PERL6LIB=mt/lib:ft/lib:jt/lib bin/neutro .
