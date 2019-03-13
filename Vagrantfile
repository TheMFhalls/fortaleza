# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.hostname = 'fortaleza'

  # Every Vagrant development enconfig.vm.definevironment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Check for vagrant-vbguest plugin
  if Vagrant.has_plugin?("vagrant-vbguest")
    # set auto_update to false, if do NOT want to check the correct additions version when booting this machine
    config.vbguest.auto_update = false
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  config.vm.network "forwarded_port", guest: 80,   host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 3306, host: 3306, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./", "/vagrant", disabled: true
  config.vm.synced_folder "./", "/opt/fortaleza", create: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:

  host = RbConfig::CONFIG['host_os']

  # Give VM 1/4 system memory
  if host =~ /darwin/
    # sysctl returns Bytes and we need to convert to MB
    quarter_of_memory = `sysctl -n hw.memsize`.to_i / 1024
  elsif host =~ /linux/
    # meminfo shows KB and we need to convert to MB
    quarter_of_memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i
  elsif host =~ /mswin|mingw|cygwin/
    # Windows code via https://github.com/rdsubhas/vagrant-faster
    quarter_of_memory = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i / 1024
  end

  quarter_of_memory = quarter_of_memory / 1024 / 4
  quarter_of_memory = quarter_of_memory.to_i

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true

    # Customize the amount of memory on the VM:
    vb.memory = quarter_of_memory
    vb.cpus = 1
  end

  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    # NGINX
    sudo apt-get update
    sudo apt-get install -y nginx


    # UTIL PACKAGES
    sudo apt-get install -y memcached zip unzip libxrender1 libfontconfig


    # PHP 7.2
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt-get update
    sudo apt-get install -y php7.2 php7.2-common php7.2-cli php7.2-fpm php7.2-mysql php7.2-curl php7.2-gd php7.2-gmp php7.2-mbstring
    sudo apt-get install -y php7.2-xml php7.2-intl php7.2-apcu php7.2-memcached php7.2-zip

    # run only on the development machine.
    sudo apt-get install -y  php7.2-xdebug

    # run only on the development machine.
    # xDebug configuration.
    sudo mkdir -p /opt/.php-xdebug
    if [ ! -f /opt/.php-xdebug/file-configured ]
    then
      sudo echo 'xdebug.max_nesting_level = 250' >> /etc/php/7.2/mods-available/xdebug.ini
      sudo echo 'xdebug.remote_connect_back = On' >> /etc/php/7.2/mods-available/xdebug.ini
      sudo echo 'xdebug.remote_enable = On' >> /etc/php/7.2/mods-available/xdebug.ini
      sudo echo 'xdebug.remote_host = 10.0.2.2 ; ip interno vm' >> /etc/php/7.2/mods-available/xdebug.ini

      sudo touch /opt/.php-xdebug/file-configured

      sudo service php7.2-fpm restart
    fi


    # MYSQL
    export DEBIAN_FRONTEND="noninteractive"
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
    sudo apt-get -y install mysql-server

    sudo mkdir -p /opt/.dbcache

    if [ ! -f /opt/.dbcache/user-root ]
    then
      mysql -uroot -proot -e "CREATE USER 'root'@'%' IDENTIFIED BY 'root'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"
      sudo touch /opt/.dbcache/user-root
    fi

    sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
    echo '#' >> /etc/mysql/mysql.conf.d/mysqld.cnf
    echo '# Disable ONLY_FULL_GROUP_BY' >> /etc/mysql/mysql.conf.d/mysqld.cnf
    echo 'sql_mode="STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"' >> /etc/mysql/mysql.conf.d/mysqld.cnf

    sudo service mysql restart


    # COMPOSER
    if [ ! -f /usr/local/bin/composer ]
    then
      cd /opt
      EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
      ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

      if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
      then
          >&2 echo 'ERROR: Invalid composer installer signature'
          rm composer-setup.php
      fi

      sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
      sudo rm composer-setup.php
    else
      composer self-update
    fi


    # CONFIG
    if [ ! -f /etc/nginx/nginx.conf.orig ]
    then
      sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
      sudo cp /opt/fortaleza/conf/nginx.conf /etc/nginx/nginx.conf
      sudo service nginx reload
    fi

    if [ ! -f /etc/nginx/sites-available/fortaleza.localhost ]
    then
      sudo cp /opt/fortaleza/conf/fortaleza.localhost.conf /etc/nginx/sites-available/fortaleza.localhost
      sudo ln -s /etc/nginx/sites-available/fortaleza.localhost /etc/nginx/sites-enabled/fortaleza.localhost
      sudo service nginx reload
    fi

    if [ ! -f /etc/php/7.2/fpm/php-fpm.conf.orig ]
    then
      sudo cp /etc/php/7.2/fpm/php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf.orig
      sudo cp /opt/fortaleza/conf/php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
      sudo service php7.2-fpm restart
    fi

    if [ ! -f /etc/php/7.2/fpm/pool.d/www.conf.orig ]
    then
      sudo cp /etc/php/7.2/fpm/pool.d/www.conf /etc/php/7.2/fpm/pool.d/www.conf.orig
      sudo cp /opt/fortaleza/conf/www.conf /etc/php/7.2/fpm/pool.d/www.conf
      sudo service php7.2-fpm restart
    fi

    if [ ! -f /etc/php/7.2/mods-available/custom.ini ]
    then
      sudo cp /opt/fortaleza/conf/php.custom.ini /etc/php/7.2/mods-available/custom.ini
      sudo ln -s /etc/php/7.2/mods-available/custom.ini /etc/php/7.2/fpm/conf.d/99-custom.ini
      sudo service php7.2-fpm restart
    fi


    # NODE/YARN
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs

    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update && sudo apt-get install yarn


    # fortaleza
    if [ ! -f /opt/.dbcache/database-fortaleza ]
    then
      mysql -uroot -proot -e "CREATE DATABASE fortaleza COLLATE utf8mb4_unicode_ci"
      sudo touch /opt/.dbcache/database-fortaleza
    fi

    # CREATE LOG DIRECTORY
    if [ ! -f /var/cache/fortaleza ]
    then
        mkdir -p /var/cache/fortaleza
        mkdir -p /var/log/fortaleza

        chown -R www-data:www-data /var/cache/fortaleza/
        chown -R www-data:www-data /var/log/fortaleza/
    fi

    if [ ! -f /opt/.dbcache/user-fortaleza ]
    then
      mysql -uroot -proot -e "CREATE USER 'fortaleza'@'127.0.0.1' IDENTIFIED BY 'fortaleza'; GRANT ALL PRIVILEGES ON *.* TO 'fortaleza'@'127.0.0.1' WITH GRANT OPTION; FLUSH PRIVILEGES;"
      sudo touch /opt/.dbcache/user-fortaleza
    fi

    cp /opt/fortaleza/conf/fortaleza.localhost.env /opt/fortaleza/app/.env
    cd /opt/fortaleza/app
    chmod +x bin/console
    chmod +x ../scripts/*.sh
    composer install -vvv -o
    yarn install --no-bin-links
    ./node_modules/@symfony/webpack-encore/bin/encore.js dev

    echo "Done. Be happy!"
  SHELL

  config.vm.provision "shell", run: "always" do |s|
      s.inline = "/bin/sh /opt/fortaleza/scripts/permissions.sh"
    end
end
