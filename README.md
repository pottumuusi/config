# useful-files
For configuration and other uses

## clone
git clone https://github.com/pottumuusi/useful-files.git

## Scripts
Before using any scripts please install them to your machine.

### Install
Following sequence will install scripts with default configuration.

First `cd` to the containing directory of useful-files.
`./configure`
`make`
`make install`

If installation was completed successfully the provided scripts are now
functional and can be invoked from any directory given that usr/local/bin
has been added to $PATH.

### Uninstall
Uninstalling scripts is achieved by running `make uninstall`.
Remove build products by running `make clean`.

Cleaning can be useful in case of build failure. In such case cleaning and
then building again can result in a successful build. This is mostly relevant
if you want to develop useful-files further.

### Help
Run `./configure --help` for more information on configure. Also installed
scripts support help option.

### concon
At this moment the only script to install is concon.

TODO <tell about concon here>
TODO remove tracing whitespace
