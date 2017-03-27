# == Class: gcs
#
# This module installs graylog collector-sidecar, manages its service and
#
# === Parameters
#
# [*ensure*]
#   Valid values are running or stopped.
#
# [*enable*]
#   Whether to enable the collector-sidecar service.
#
# [*manage_service*]
#   Whether or not to manage (install, launch/stop) the collector-sidecar service.
#
# [*package_version*]
#   Which package version to install.
#
# [*server_url*]
#   URL to the api of your graylog server. Collector-sidecar will fetch configurations.
#   from this host based on the configured tags.
#
# [*tags*]
#   Tags for this host
#
# [*log_files*]
#   Location of log files to index and report to the Graylog server.
#
# [*update_interval*]
#   The interval in seconds the sidecar will fetch new configurations from the Graylog server.
#   Default is set to 10 in params.
#
# [*tls_skip_verify*]
#   Ignore errors when the REST API was started with a self-signed certificate.
#
# [*send_status*]
#   Send the status of each backend back to Graylog and display it on the status page for the host.
#
# [*service_provider*]
#   Service provider to use. Defaults to systemd on linux.
#
# [*filebeat_enable*]
#    Whether to enable the filebeat service. Default: true
#
# [*nxlog_enable*]
#    Whether to enable the nxlog service. Default: false
#
# === Examples
#
#  include ::gcs
#
# In hiera, you can set configuration variables:
#  gcs::server_url: http://my.graylog.server:9000/api
#  gcs::update_interval: 15
#  gcs::tags:
#    - linux
#    - icinga2
#    - nginx
#
# === Authors
#
# David Raison <david@tentwentyfour.lu>
#
class gcs(
  $ensure           = running,
  $enable           = true,
  $manage_service   = true,
  $server_url       = undef,
  $tags             = [],
  $package_version  = $gcs::params::package_version,
  $log_files        = $gcs::params::log_files,
  $update_interval  = $gcs::params::update_interval,
  $tls_skip_verify  = $gcs::params::tls_skip_verify,
  $send_status      = $gcs::params::send_status,
  $service_provider = $gcs::params::service_provider,
  $filebeat_enable  = $gcs::params::filebeat_enable,
  $nxlog_enable     = $gcs::params::nxlog_enable,
) inherits ::gcs::params {

  validate_re(
    $ensure,
    [ '^running$', '^stopped$' ],
    "${ensure} isn't supported. Valid values are 'running' and 'stopped'."
  )

  validate_re(
    $package_version,
    '^(\d)\.(\d)\.(\d)(-+.*)$',
    'You must specify a package version in the semver format 0.1.0-beta.2'
  )

  validate_bool($tls_skip_verify)
  validate_bool($send_status)
  validate_bool($enable)
  validate_bool($manage_service)
  validate_bool($filebeat_enable)
  validate_bool($nxlog_enable)

  validate_array($tags)
  validate_absolute_path($log_files)
  validate_absolute_path($tmp_location)
  validate_integer($update_interval)

  if $server_url == undef {
    fail('server_url must be set!')
  } elsif !is_string($server_url) {
    fail('server_url must be set!')
  }


  anchor { '::gcs::begin': }
  -> class { '::gcs::install': }
  -> class { '::gcs::config': }
  ~> class { '::gcs::service': }
  anchor { '::gcs::end': }
}
