Test Ansible Roles
==================

Tests your ansible roles in multiple operating systems.

Installation
------------

Please see the file called [INSTALL.md](INSTALL.md).

Examples
--------

1. Test ansible roles in operating systems defined in [config/default.md](config/default.md)  
   `$ ./test.sh`
2. Test juliendufresne.influxdb role on bento/ubuntu-16.04 vagrant box with debug if something fails 
   `$ ./test.sh --verbose --ansible-role juliendufresne.influxdb --vagrant-box bento/ubuntu-16.04`
3. Test ansible roles defined in a custom config file defined in config/debian.md  
   `$ ./test.sh --config-file debian`
4. Test using the config file config/default.md filtering by ansible role  
   `$ ./test.sh --ansible-role juliendufresne.influxdb`
4. Test using the config file config/default.md filtering by vagrant box  
   `$ ./test.sh --vagrant-box bento/centos7`

> **Tips:** First, run your test with a config file then run failed tests manually with the `--verbose` option.

Options
-------

**TL;DR** RTFM: `./test.sh --help`

<details>
<summary>**`--ansible-role ANSIBLE_ROLE`**</summary>
> **Note:** You need to do few things to be able to test any ansible role (see [Adding a role section](#adding-a-role))

This option allows to specify which ansible role to test.  
You can specify more than one ansible role.

Examples:

    $ ./test.sh --ansible-role juliendufresne.influxdb
    $ ./test.sh --ansible-role juliendufresne.influxdb --ansible-role juliendufresne.grafana

> _**Note:** If you don't specify a vagrant box, the script will search in your configuration file_
</details>

<details>
<summary>**`--config-file CONFIG_FILE`** (Recommended)</summary>
A configuration file ease repetitive tests by providing a set of (ansible role, vagrant box) to test.

The script will run one test for each line in the config file (except the headers).  
Basically, a line contains an ansible role, a vagrant box and some options that you would define manually otherwise.

Examples:

    $ ./test.sh # will load config/default.md
    $ ./test.sh --config-file default # will load config/default.md
    $ ./test.sh --config-file /home/julien/debian.md # will load /home/julien/debian.md

> **Note:** The configuration file may be anywhere accessible in your computer.
 If you specify a relative path, the script will search in:
 * your current directory
 * the repository root directory
 * the repository config directory

> **Note:** You can omit the ".md" extension. This simplify the command line: `./test.sh --config-file default`

> **Note:** If you don't specify a configuration file, the script will try to load the config/default.md file
</details>

<details>
<summary>**`--enable-vbguest`**</summary>
Some vagrant box needs virtual box guest additions to be installed in
order to create a synced folder between your host and the virtual machine.

Since it installs some additional packages and hence, slows the tests, it
is not installed by default.

> **Tips:** If your test doesn't work the first time, try to enable vbguest and see if it solves the problem.
</details>

<details>
<summary>**`--pre-script PRE_SCRIPT`**</summary>
Executes a script in the virtual machine after it is up but before running
ansible playbook.  
For instance, vagrant is not able to install the latest version of ansible
in some operating systems (like centos 6). In this case of situation, you
can install it manually using this option.

Example:

    $ ./test.sh --pre-script provision/install_ansible.sh --ansible-role juliendufresne.influxdb --vagrant-box bento/centos6

> **Note:** You can only execute one script.
</details>

<details>
<summary>**`-v`**, **`--verbose`**</summary>
Activates the debugging for failed task.

Example:

    $ ./test.sh -v
    $ ./test.sh --verbose --ansible-role juliendufresne.influxdb --vagrant-box bento/centos7
</details>

<details>
<summary>**`--vagrant-box VAGRANT_BOX`**</summary>

This option allows to specify a vagrant box to test.  
You can specify more than one vagrant box.

Examples:

    $ ./test.sh --vagrant-box bento/centos6
    $ ./test.sh --vagrant-box bento/centos6 --vagrant-box bento/centos7

> _**Note:** If you don't specify an ansible role, the script will search in your configuration file_
</details>

Adding a role
-------------

When you want to test a new role, you need to:
* [ansible galaxy only] add a line in the [requirements.yml](requirements.yml) file.
* create a playbook in the [playbooks](playbooks) directory.
  The file name must be `<your_role_name>.yml`. For example, for a role
  name juliendufresne.influxdb, you will need a file playbooks/juliendufresne.influxdb.yml 
* [local (non galaxy) role] define your role in the playbooks/roles directory

Reports
-------

Every tests are reported in a file located in the reports directory.  
Reports are grouped by ansible roles.  
If you run a test on the same operating system, it will override the previous report.

You can see an example of report in [reports/juliendufresne.influxdb.md](reports/juliendufresne.influxdb.md)
