# ABSTRACT: Command line to config file two way interface
# VERSION

package Config::Cmd;
use Mo;
use YAML qw'Dump DumpFile LoadFile';
use Modern::Perl;
use Carp;

use constant EXT => '_conf.yaml';

has section => ();
has filename => ();

sub set {
    my $self = shift;
    my $args = shift;

    say STDERR "# writing into ". $self->_set_file;
    say STDERR "# options: ". "@$args";

    $self->set_silent($args);
}

sub set_silent {
    my $self = shift;
    my $args = shift;

    # process arguments
    my $section = $self->section;
    croak "Set section before writing into a file" unless $section;
    my $config->{$section} = [];

    my $key = '';
    while (my $e = shift @$args) {
	if ($e eq '=') {
	    next;
	}
	elsif ($e =~ /(-.+)=(.+)/) {
	    if ($key) {
		my $tuple->{key} = $key ;
		push @{$config->{$section}}, $tuple;
		$key = '';
	    }
	    my $tuple->{key} = $1 ;
	    $tuple->{value} = $2 ;
	    push @{$config->{$section}}, $tuple;
	}
	elsif ($e =~ /^-/) {
	    if ($key) {
		my $tuple->{key} = $key ;
		push @{$config->{$section}}, $tuple;
	    }
	    $key = $e;
	} else {
	    if ($key) {
		my $tuple->{key} = $key ;
		$tuple->{value} = $e ;
		push @{$config->{$section}}, $tuple;
	    }
	    $key = '';
	}

    }
    if ($key) {
	my $tuple->{key} = $key;
	push @{$config->{$section}}, $tuple;
    }

    #print Dump $config;
    DumpFile $self->_set_file, $config;

}

sub get {
    my $self = shift;
    my $section = $self->section;

    my $config = LoadFile($self->_get_file);

    my @list;
    for my $tuple (@{$config->{$section}}) {
	if (defined $tuple->{value}) {
	    push @list, $tuple->{key}, $tuple->{value};
	} else {
	    push @list, $tuple->{key};
	}
    }
    return join ' ', @list;
}

# internal methods

sub _default_filename {
    return shift->section. EXT;
}

sub _set_file {
    my $self = shift;

    return $self->filename if defined $self->filename;
    return $self->_default_filename if $self->section;
    return; # if no matching files were found
}


sub _get_file {
    my $self = shift;

    return $self->filename if defined $self->filename;
    if (-e $self->_default_filename) {
	return $self->_default_filename;
    } elsif (-e $ENV{HOME}. '.'. $self->_default_filename) {  #check home directory
	return $ENV{HOME}. '.'. $self->_default_filename;
    }
    return; # if no matching files were found
}

1;


=pod

=head1 SYNOPSIS

   # user writes options in a file;
   configcmd parallel -j 8 --verbose
   # stored in ./parallel_conf.yaml

   # same using the module directly
   use Config::Cmd;
   my $conf = Config::Cmd(section => 'parallel');
   $conf->set('-j 8 --verbose');

   # main application uses the options
   use Config::Cmd;
   my $conf = Config::Cmd(section => 'parallel');
   my $parallel_opts = $conf->get;  # read from ./parallel_conf.yaml
   # call external programme
   `$exe $parallel_opts @args`;

=head1 DESCRIPTION

This module makes it easy to take a set of command line options and
store them into a config file and read them later in for passing to an
external programme. Part of this distribution is a command line
programme L<configcmd> for writing these commands into a file. The main
application can then use this module to automate reading of these
options and passing them on.

=head2 Finding the configuration files

The command line programme writes into the working directory. The
default name is the section name appended with string
'_conf.yaml'. This file can be moved and renamed.

The method filename() can be used to set the path where the file is
found. This overrides all other potential places. If the filename has
not been set, the module uses the section name to find the
configuration file from the working directory (./[section]_conf.yaml).
If that file is not found, it looks into user's home directory for a
file ~/.[section]_conf.yaml.

=method section

The obligatory section name for the stored configuration. This string,
typically a programme name, defines the name of the config file.

=method filename

Override method that allows user to determine the filename where a
config is to be written or read.

=method set

Store the command line into a file as YAML. Returns true value on
success.

=method set_silent

Same as set() but does not report to STDERR.

=method get

Get the command line options stored in the file as a string.

=head1 SEE ALSO

L<configcmd>, L<Config::Auto>

=cut

