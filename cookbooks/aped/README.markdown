# APEd

This cookbook can serve as a good starting point for setting up APE (Ajax Push Engine) support in your application. 
In this recipe your APE workers will be set up to run under monit. 

## Installation

To install this, you will need to add the following to cookbooks/main/recipes/default.rb:

    require_recipe "ape"
    
Make sure this and any customizations to the recipe are committed to your own fork of this 
repository.
