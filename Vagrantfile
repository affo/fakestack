# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
DEFAULT_BOX = "ubuntu-14.04-x64"
#NO_COMPUTE = 100
NO_COMPUTE = 1
COMPUTE_ONLY = true
BASE_PRIVATE_NETWORK_IP = "10.0.0."

if NO_COMPUTE > 252
	raise 'Cannot allocate more than 252 IPs! NO_COMPUTE has to be less or equal than 252!'
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	# defining controller
	if !COMPUTE_ONLY
		config.vm.define "controller" do |controller|
			controller.vm.box = DEFAULT_BOX
			controller.vm.hostname = "controller"
			controller.vm.network "private_network", ip: BASE_PRIVATE_NETWORK_IP + "254"
		end
	end

	# defining tons of computes
	NO_COMPUTE.times do |index|
		real_index = index + 2
		config.vm.define "compute#{real_index}" do |compute_node|
			compute_node.vm.box = DEFAULT_BOX
			compute_node.vm.hostname = "compute#{real_index}"
			# create internal network nic
			compute_node.vm.network "private_network", ip: BASE_PRIVATE_NETWORK_IP + "#{real_index}"

			compute_node.vm.provider "virtualbox" do |vb|
				# Ubuntu 14.04 server minimum requirements:
				# 300 MHz x86 processor
				# 192 MiB of system memory (RAM)
				# 1 GB of disk space
				vb.memory = 192
			end

			# running post boot script
			config.vm.provision "shell", path: "post_boot_script.sh"
		end
	end

end
