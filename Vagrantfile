# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
DEFAULT_BOX = "ubuntu-14.04-x64"
NO_COMPUTE = 5

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	# defining controller
	config.vm.define "controller" do |controller|
		controller.vm.box = DEFAULT_BOX
		controller.vm.hostname = "controller"
	end

	# defining tons of computes
	NO_COMPUTE.times do |index|
		config.vm.define "compute#{index}" do |compute_node|
			compute_node.vm.box = DEFAULT_BOX
			compute_node.vm.hostname = "compute#{index}"
		end
	end

end
