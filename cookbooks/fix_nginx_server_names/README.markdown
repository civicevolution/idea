# fix_nginx_server_names

remove the commas from the server_name line in nginx server conf files
EY insists on listing domains with commas


## Installation

To install this, you will need to add the following to cookbooks/main/recipes/default.rb:

    require_recipe "fix_nginx_server_names"
    
Make sure this and any customizations to the recipe are committed to your own fork of this 
repository.

