

run "echo 'before_migrate, create symlink: /data/#{app_name}/shared/config/database.yml >> /data/#{app_name}/shared/config/#{prefix}database.yml'"
sudo "ln -nfs /data/#{app_name}/shared/config/#{prefix}database.yml /data/#{app_name}/shared/config/database.yml"
