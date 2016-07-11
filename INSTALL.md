Installation
============

This repository relies on **Vagrant** and the **VirtualBox** provider.

* Vagrant version 1.8.4+ (needed to install latest ansible version) - [Website](https://www.vagrantup.com/) - [Download page](https://www.vagrantup.com/downloads.html)
* Virtualbox - [Website](https://www.virtualbox.org/) - [Download page](https://www.virtualbox.org/wiki/Downloads)

As you can see you don't even need ansible on your host.

Once this packages are installed, you just need to clone this repository
and run your first test:

    $ git clone https://github.com/juliendufresne/test-ansible-roles.git
    $ cd test-ansible-roles
    $ ./test.sh

> _**Note:** You can install specific ansible version in the guest using the **--pre-script** option_
