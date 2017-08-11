Vagrant::Config.run do |config|
  config.vm.box = "hashicorp/precise32"
   config.vm.provision :chef_client do |chef|
   	 chef.chef_server_url = "https://api.chef.io/organizations/timonsplus"
   	 chef.validation_key_path = "chef-validator.pem"
     #chef.cookbooks_path = "cookbooks"
     chef.add_role "webserver"
     chef.environment = "prod"
     chef.log_level = :info
  end 
end