Facter.add(:centreon_install_dir) do
    setcode do
        if File.directory?('/usr/share/centreon/install')
            'true'
        else
            'false'
        end
    end
end