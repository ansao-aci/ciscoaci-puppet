class ciscoaci::heat(
   $package_ensure    = 'present',
) inherits ::ciscoaci::params
{

   package {'aci-heat-package':
     ensure  => $package_ensure,
     name    => $::ciscoaci::params::aci_heat_package,
     tag     => ['heat-package', 'openstack'],
     require => Package['heat-common']
   }
}
