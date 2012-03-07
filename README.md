Origins
===
This is a fork of [flexiondotorg/oab-java6](https://github.com/flexiondotorg/oab-java6) that creates an `apt` repository for both Sun Java 6 and Oracle Java 7.

`oab-java.sh` v0.2.1 - Create a local `apt` repository for Ubuntu Java packages.

Copyright (c) 2012 Tamer Saadeh <tamersaadeh@gmail.com>. MIT License

Original Copyright (c) 2012 Flexion.Org, http://flexion.org. MIT License

By running this script to download Java you acknowledge that you have read and accepted the terms of the Oracle end user license agreement.

[Java Terms and License](http://www.oracle.com/technetwork/java/javase/terms/license/)

If you want to see what this is script is doing while it is running then execute the following from another shell:

```tail -f build.log```

Usage
===

```sudo ./oab-java.sh```

Optional parameters
---
  * `-c | --clean` : Remove pre-existing packages from `/var/local/oab/deb`
  * `-h | --help` : This help message

How do I download and run this thing?
===
Like this.

```cd ~/```
```git clone https://github.com/tamersaadeh/oab-java.git```
```cd oab-java/```
```sudo ./oab-java.sh```

How it works?
===
This script is merely a wrapper for the most excllent Debian packaging
scripts prepared by Janusz Dziemidowicz.

  1. [rraptorr/sun-java6](https://github.com/rraptorr/sun-java6)
  2. [rraptorr/oracle-java7](https://github.com/rraptorr/oracle-java7)

This script is Based on the scirpt prepared by Martin Wimpress.

  1. [flexiondotorg/oab-java6](https://github.com/flexiondotorg/oab-java6)

The basic execution steps are:
===

  * Remove, my now disabled, Java PPA 'ppa:flexiondotorg/java'.
  * Install the tools required to build the Java packages.
  * Create download cache in `/var/local/oab/pkg`.
  * Download the i586 and x64 Java install binaries from Oracle. Yes, **both are required**. (total 4 files)
  * Clone the build scripts from [rraptorr/sun-java6](https://github.com/rraptorr/sun-java6) and [rraptorr/oracle-java7](https://github.com/rraptorr/oracle-java7).
  * Build the Java packages applicable to your system.
  * Create local `apt` repository in `/var/local/oab/deb` for the newly built Java Packages.
  * Create a GnuPG signing key in `/var/local/oab/gpg`, if none exists.
  * Sign the local `apt` repository using the local GnuPG signing key.

What gets installed?
===
**Nothing!**

This script will no longer try and directly install or upgrade any Java packages, instead a local 'apt' repository is created that hosts locally built Java packages applicable to your system. It is up to you to install or upgrade the Java packages you require using `apt-get`, `aptitude` , or `synaptic`, etc. For example, once this script has been run you can simply install the JRE by executing the following from a shell.

```sudo apt-get install sun-java6-jre```
or
```sudo apt-get install oracle-java7-jre```

Or if you already have the "official" Ubuntu packages installed then you can upgrade by executing the folowing from a shell.

```sudo apt-get upgrade```

The local `apt` repository is just that, **local**. It is not accessible remotely and `oab-java.sh` will never enable that capability to ensure compliance with Oracle's asinine license requirements.

Known Issues
===

  * The Oracle download servers can be horribly slow. My script caches the downloads so you only need download each file once.

What is 'oab'?
===
*Because, O.A.B! ;-)*

History
=======

0.2.1
-----
 
  * Updated script to work with Ubuntu Precise
    (see https://github.com/rraptorr/sun-java6/issues/5#issuecomment-4312028)
  * Refactored documentation and added support for GitHub Markdown
  * Fixed an issue that caused the Release file to be malformed
    (thanks to Jeff Cooper <repoocaj@gmail.com>, commit: 30711df3b7efc16bd8927988d071c83bbdb174cd )

0.2.0
-----
 
  * Builds Java 7 packages as well
  * Huge code refactor to make it much easier to maintain

0.1.8
-----
 
  * Added dynamic determination of Java package URLs and sizes
  * Added an option (-c) to optionally clean .deb package
     - Closes : https://github.com/flexiondotorg/oab-java6/issues/10

0.1.7
-----

  * Fixed GPG key creation on VMware ESX Server
     - Closes : https://github.com/flexiondotorg/oab-java6/issues/11
  * Fixed clone of the 'sun-java6' repository for users behind restrictive 
    firewalls, thanks to Thorsten Möllers

0.1.6
-----
 
  * Fixed downloading of common.sh when ca-certificates is not installed
     - Closes : https://github.com/flexiondotorg/oab-java6/issues/3
  * Updated to support Java6u31
     - Closes : https://github.com/flexiondotorg/oab-java6/issues/7
     - Closes : https://github.com/flexiondotorg/oab-java6/issues/8
     - NOTE! Requires that the upstream script tags Java6u31 as stable, see the 
       following ticket https://github.com/rraptorr/sun-java6/issues/3
  * Prevent script from running under Ubuntu Precise as it is currently 
    known to be unsupported.
     - Closes : https://github.com/flexiondotorg/oab-java6/issues/4
  * Prevent automated key generation when running in an OpenVZ 
    container because I'm too stupid to work out a proper solution

0.1.5
-----

  * Fixed missing code that actually does the build

0.1.4
-----

  * Added GnuPG signing of the local 'apt' repository
  * Updated package building to preserve the upstream package urgency
  * Refactored to remove hard coded versions, now uses 'debian/changelog'
  * Fixed the 'override' file generation to ensure it doesn't contain duplicates
  * Updated documentation

0.1.3
-----

  * Added checking out of tagged releases of the upstream scripts
     - Closes : https://github.com/flexiondotorg/oab-java6/issues/1
  * Added loose distribution checking so it should now work with Linux Mint and
    other Ubuntu derivatives
     - Closes : https://github.com/flexiondotorg/oab-java6/issues/2
  * Added the creation of a local 'apt' repository
  * Removed installation of Java packages, you can now use 'apt-get' yourself
  * Updated documentation

0.1.2
-----

  * Fixed build requirements
  * Fixed install of 'ia32-sun-java6-bin' on 64-bit systems
  * Fixed install of Java browser plugin on systems without a supported browser
  * Added runtime requirements
  * Added TODO
  * Updated documentation

0.1.1
-----

  * Updated to use dynamic version detection throughout
  * Fixed package installation when upgrading
  * Minor documentation updates

0.1.0
-----

  * Initial release

Todo
====

* Remove automatic signing key generation and add support for selecting a
  pre-existing signing key.
* Add support to build for a given Ubuntu distribution.
* Add support to optionally build using 'pbuilder'.
* Fully exit after an error occurs.

License
=======

Copyright (c) 2012 Tamer Saadeh <tamersaadeh@gmail.com>

Original Copyright (c) 2012 Martin Wimpress, http://flexion.org/

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
