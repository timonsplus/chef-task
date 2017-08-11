Small Ubuntu guide.
Its simple java Hello-World app, which generates for user client's IP and current time.
Unfortunately there is no any mysql DBs.

# Run Chef
Use the following command to run app server from your chef-workstation:
#knife bootstrap 1.1.1.1 -x USERNAME -P CLEAR_PASSWD -N NEW_NODE_NAME --sudo -r 'role[webserver]' --environment prod

In case of manual chef-client setup, place validation keys from your chef-server, prepare client.rb config file, 
get updates using "sudo chef-client" command (be sure if your node is located in desired env.).


# Run Vagrant
Place vagrantfile in chef-repo directory. Setup the following vars:
--chef.chef_server_url (http server url) and
--chef.validation_key_path > put in appropriate place.
Run Vagrant with "vagrant up", follow instruction regading SSH usage.
In case of chef failure - tune your recipe and use "vagrant provision" command.