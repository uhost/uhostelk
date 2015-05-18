name             'uhostelk'
maintainer       'Mark C Allen'
maintainer_email 'mark@markcallen.com'
license          'Apache 2.0'
description      'Installs/Configures uhostelk'
long_description 'Installs/Configures uhostelk'
version          '0.2.0'

%w{ ubuntu centos }.each do |os|
	  supports os
end

%w{ apt elkstack java }.each do |cb|
	  depends cb
end
