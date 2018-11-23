Facter.add(:centreon_install_dir) do
    setcode do
        if File.directory?('/usr/share/centreon/www/install')
            'true'
        else
            'false'
        end
    end
end