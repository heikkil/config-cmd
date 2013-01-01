config-cmd
==========

Command line to config file two way interface in perl.

Philosophy
----------

Command line programs that wrap an external program are often run in
different environments with different batch management systems. This
module makes it easy for users to store the environment specific
options in a file that is read by the main program when it is given
one simple option that identifies the environment.

Installation
------------

The working version should be installed from [CPAN][metacpan]:

    $ cpanm configcmd

or

    $ cpanm Config::Cmd


Getting started
---------------

Read about runtime user options from [the configcmd online
documentation][configcmd]:

    $ configcmd --help

The application development options are described in
[the main module Config::Cmd][metacpan].

Development
-----------

Pipeline::Simple source repository is managed with [Dist::Zilla][dzil]
and [hosted on GitHub][development].



[metacpan]: http://metacpan.org/release/Config-Cmd
[configcmd]: http://metacpan.org/module/configcmd
[dzil]: http://dzil.org/
[development]: http://github.com/heikkil/config-cmd
