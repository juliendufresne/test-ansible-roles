Vagrant.require_version ">= 1.8.4"
ENV["LC_ALL"] = "en_US.UTF-8"

Vagrant.configure(2) do |config|
    config.vm.box = "geerlingguy/ubuntu1604"
    config.vm.box_check_update = false
    config.vm.hostname = "ansible-role-ubuntu-1604"

    config.vm.network "private_network", type: "dhcp"

    config.vm.provider :virtualbox do |vb|
        vb.name   = "ansible_role_ubuntu_1604"
        vb.memory = 512
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--ioapic",              "on"]
    end

    config.vm.define :ansible_role_ubuntu_1604 do |ansible_role_ubuntu_1604|
    end

    config.vm.provision "ansible", type: "ansible_local" do |ansible|
        ansible.galaxy_role_file = "requirements.yml"
        ansible.install          = true
        ansible.install_mode     = :pip
        ansible.inventory_path   = "inventory"
        ansible.playbook         = "playbooks/influxdb.yml"
        ansible.limit            = "all"
    end

    config.vm.synced_folder ".", "/vagrant", :nfs => true, :mount_options => ["rw", "tcp", "nolock", "noacl", "async"]

    if Vagrant.has_plugin?("vagrant-hostmanager")
        config.hostmanager.enabled = false
    end
    if Vagrant.has_plugin?("vagrant-vbguest")
        config.vbguest.auto_update = false
    end
end
