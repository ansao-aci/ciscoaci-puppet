Name:           ciscoaci-puppet
Version:        1.0
Release:        %{?release}%{!?release:1}
Summary:        Puppet manifests for configuring Cisco Aci Openstack plugin
License:        ASL 2.0
Group:          Applications/Utilities
Source0:        ciscoaci-puppet.tar.gz
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       puppet

%define installPath /usr/share/openstack-puppet/modules/

%define debug_package %{nil}

%description
This package contains ciscoaci puppet module

%prep
%setup -q -n ciscoaci-puppet

%install
rm -rf $RPM_BUILD_ROOT/usr/share/openstack-puppet/modules
mkdir -p $RPM_BUILD_ROOT/usr/share/openstack-puppet/modules
cp -r ciscoaci $RPM_BUILD_ROOT/usr/share/openstack-puppet/modules

rm -rf $RPM_BUILD_ROOT/usr/share/openstack-puppet/modules/tripleo/manifests/profile/base
mkdir -p $RPM_BUILD_ROOT/usr/share/openstack-puppet/modules/tripleo/manifests/profile/base
cp ciscoaci.pp $RPM_BUILD_ROOT/usr/share/openstack-puppet/modules/tripleo/manifests/profile/base
cp ciscoaci_compute.pp $RPM_BUILD_ROOT/usr/share/openstack-puppet/modules/tripleo/manifests/profile/base
cp ciscoaci_heat.pp $RPM_BUILD_ROOT/usr/share/openstack-puppet/modules/tripleo/manifests/profile/base
cp ciscoaci_horizon.pp $RPM_BUILD_ROOT/usr/share/openstack-puppet/modules/tripleo/manifests/profile/base

%post
ln -s /usr/share/openstack-puppet/modules/ciscoaci /etc/puppet/modules/ciscoaci
ln -s /usr/share/openstack-puppet/modules/tripleo/manifests/profile/base/ciscoaci.pp /etc/puppet/modules/tripleo/manifests/profile/base/ciscoaci.pp
ln -s /usr/share/openstack-puppet/modules/tripleo/manifests/profile/base/ciscoaci_compute.pp /etc/puppet/modules/tripleo/manifests/profile/base/ciscoaci_compute.pp
ln -s /usr/share/openstack-puppet/modules/tripleo/manifests/profile/base/ciscoaci_horizon.pp /etc/puppet/modules/tripleo/manifests/profile/base/ciscoaci_horizon.pp
ln -s /usr/share/openstack-puppet/modules/tripleo/manifests/profile/base/ciscoaci_heat.pp /etc/puppet/modules/tripleo/manifests/profile/base/ciscoaci_heat.pp

%postun
unlink /etc/puppet/modules/ciscoaci

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/usr/share/openstack-puppet/modules/ciscoaci
/usr/share/openstack-puppet/modules/tripleo/manifests/profile/base/ciscoaci.pp
/usr/share/openstack-puppet/modules/tripleo/manifests/profile/base/ciscoaci_compute.pp
/usr/share/openstack-puppet/modules/tripleo/manifests/profile/base/ciscoaci_horizon.pp
/usr/share/openstack-puppet/modules/tripleo/manifests/profile/base/ciscoaci_heat.pp