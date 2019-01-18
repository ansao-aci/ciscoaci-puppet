class ciscoaci::aim_config(
  $step  = hiera('step'),
  $aci_apic_systemid,
  $neutron_sql_connection,
  $aci_apic_hosts,
  $aci_apic_username,
  $aci_apic_password,
  $aci_encap_mode,
  $aci_apic_aep,
  $aci_vpc_pairs = undef,
  $aci_opflex_vlan_range = '',
  $use_lldp_discovery = true,
  $aci_host_links = {},
  $physical_device_mappings = '',
  $aci_scope_names = 'False',
  $aci_scope_infra = 'False',
  $neutron_network_vlan_ranges = undef,
  $aci_aim_debug = 'False',
  $aci_provision_infra = 'False',
  $aci_provision_hostlinks = 'False',
) inherits ::ciscoaci::params
{

  include ::ciscoaci::deps

  $default_transport_url  = os_transport_url({
        'transport' => hiera('messaging_rpc_service_name', 'rabbit'),
        'hosts'     => any2array(hiera('rabbitmq_node_names', undef)),
        'port'      => hiera('neutron::rabbit_port', '5672'),
        'username'  => hiera('neutron::rabbit_user', 'guest'),
        'password'  => hiera('neutron::rabbit_password'),
        'ssl'       => hiera('neutron::rabbit_use_ssl', '0'),
  })

  aim_conf {
     'DEFAULT/debug':                             value => $aci_aim_debug;
     'DEFAULT/logging_default_format_string':     value => '"%(asctime)s.%(msecs)03d %(process)d %(thread)d %(levelname)s %(name)s [-] %(instance)s%(message)s"';
     'DEFAULT/transport_url':                     value => $default_transport_url;
     'database/connection':                       value => $neutron_sql_connection;
     'apic/apic_hosts':                           value => $aci_apic_hosts;
     'apic/apic_username':                        value => $aci_apic_username;
     'apic/apic_password':                        value => $aci_apic_password;
     'apic/apic_use_ssl':                         value => 'True';
     'apic/verify_ssl_certificate':               value => 'False';
     'apic/scope_names':                          value => $aci_scope_names;
     'aim/aim_system_id':                         value => $aci_apic_systemid;
  }  

  aimctl_config {
     'DEFAULT/apic_system_id':                    value => $aci_apic_systemid;
     "apic_vmdom:$aci_apic_systemid/encap_mode":  value => $aci_encap_mode;
     'apic/apic_entity_profile':                  value => $aci_apic_aep;
     'apic/scope_infra':                          value => $aci_scope_infra;
     'apic/apic_provision_infra':                 value => $aci_provision_infra;
     'apic/apic_provision_hostlinks':             value => $aci_provision_hostlinks;
  }
 
  if $aci_encap_mode == 'vlan' {
    aimctl_config {
      "apic_vmdom:$aci_apic_systemid/vlan_ranges":  value => join(any2array($aci_opflex_vlan_range), ',')
    }
  }

  if $aci_vpc_pairs {
     aimctl_config {
        'apic/apic_vpc_pairs':                       value => $aci_vpc_pairs;
     }
  }
  
  if !$use_lldp_discovery {
     if !empty($aci_host_links) {
        ciscoaci::hostlinks {'xyz':
          hl_a => $aci_host_links
        }
     }
  }

  $nvr = join(any2array($neutron_network_vlan_ranges), ',')
  if $nvr != "[]" {
     class {'ciscoaci::aim_physdoms':
       neutron_network_vlan_ranges => $neutron_network_vlan_ranges,
       aci_host_links => $aci_host_links
     }
  }

  if !empty($physical_device_mappings) {
     $hosts = hiera('neutron_plugin_compute_ciscoaci_short_node_names', '')
     $pmcommands = physnet_map($hosts, $physical_device_mappings, $domain)
  }

  file {'/etc/aim/physnet_mapping.sh':
    mode => '0755',
    content => template('ciscoaci/physnet_mapping.sh.erb'),
  }

  file {'/etc/aim/aim_supervisord.conf':
    mode => '0644',
    content => template('ciscoaci/aim_supervisord.conf.erb'),
  }

  file {'/etc/aim/aim_healthcheck':
    mode => '0755',
    content => template('ciscoaci/aim_healthcheck.erb'),
  }

}
