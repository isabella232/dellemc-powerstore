require 'puppet/resource_api'

# rubocop:disable Style/StringLiterals

# Manage volumes, including snapshots and clones of volumes.
Puppet::ResourceApi.register_type(
  name: 'powerstore_volume',
  features: ['remote_resource'],
  # rubocop:disable Lint/UnneededDisable
  # rubocop:disable Layout/TrailingWhitespace
  desc: <<-EOS,
    Manage volumes, including snapshots and clones of volumes.
  EOS
  attributes:   {
    ensure:      {
      type:      "Enum['present', 'absent']",
      desc:      'Whether this resource should be present or absent on the target system.',
      default:   'present',
    },
    appliance_id:          {
      type:      "Optional[String]",
      desc:      "Identifier of the appliance on which the volume is provisioned.",
      behaviour: :init_only,
    },
    creation_timestamp:          {
      type:      "Optional[String]",
      desc:      "Time when the volume was created.",
    },
    description:          {
      type:      "Optional[String[0,128]]",
      desc:      "Description of the volume. This value must contain 128 or fewer printable Unicode characters.",
    },
    expiration_timestamp:          {
      type:      "Optional[String]",
      desc:      "New expiration time of the snapshot. Expired snapshots are deleted by the snapshot aging service that runs periodically in the background. If not specified, the snapshot never expires.Use a maximum timestamp value to set an expiration to never expire.",
    },
    force:          {
      type:      "Optional[Boolean]",
      desc:      "Normally a replication destination volume cannot be modified since it is controlled by replication. However, there can be cases where replication has failed or is no longer active and the replication destination volume needs to be cleaned up.With the force option, the user will be allowed to remove the protection policy from the replication destination volume provided that the replication session has never been synchronized and the last_sync_timestamp property is empty.This parameter defaults to false, if not specified.",
    },
    host_group_id:          {
      type:      "Optional[String]",
      desc:      "Unique identifier of the host group to be attached to the volume. If not specified, an unmapped volume is created. Only one of host_id or host_group_id can be supplied.",
      behaviour: :init_only,
    },
    host_id:          {
      type:      "Optional[String]",
      desc:      "Unique identifier of the host to be attached to the volume. If not specified, an unmapped volume is created. Only one of host_id or host_group_id can be supplied.",
      behaviour: :init_only,
    },
    id:          {
      type:      "Optional[String]",
      desc:      "Unique identifier of the volume to delete.",
      behaviour: :read_only,
    },
    is_replication_destination:          {
      type:      "Optional[Boolean]",
      desc:      "New value for is_replication_destination property. The modification is only supported for primary and clone volume, only when the current value is true and there is no longer a replication session using this volume as a destination, and only to false.",
    },
    location_history:          {
      type:      "Optional[Array[Struct[{Optional[from_appliance_id] => Optional[String], Optional[migrated_on] => Optional[String], Optional[reason] => Optional[Enum['Initial','Manual','Recommended']], Optional[reason_l10n] => Optional[String], Optional[to_appliance_id] => Optional[String], }]]]",
      desc:      "Filtering on the fields of this embedded resource is not supported.",
    },
    logical_unit_number:          {
      type:      "Optional[Integer[0,16383]]",
      desc:      "Optional logical unit number when creating a  attached volume.  If no host_id or host_group_id is specified, this property is ignored.",
      behaviour: :init_only,
    },
    migration_session_id:          {
      type:      "Optional[String]",
      desc:      "Unique identifier of the migration session assigned to the volume if it is part of a migration activity.",
    },
    min_size:          {
      type:      "Optional[Integer[0,9223372036854775807]]",
      desc:      "Optional minimum size for the volume, in bytes.",
      behaviour: :init_only,
    },
    name:          {
      type:      "String[0,128]",
      desc:      "Unique name for the volume to be created. This value must contain 128 or fewer printable Unicode characters.",
      behaviour: :namevar,
    },
    node_affinity:          {
      type:      "Optional[Enum['System_Select_At_Attach','System_Selected_Node_A','System_Selected_Node_B','Preferred_Node_A','Preferred_Node_B']]",
      desc:      "This attribute shows which node will be advertised as the optimized IO path to the volume. It is initially set to System_Select_At_Attach and can be modified to other values. When a volume is first attached to a host, if node_affinity is System_Select_At_Attach then the system will make the assignment to either System_Selected_Node_A or System_Selected_Node_B. The node_affinity may be modified to one of System_Select_At_Attach or Preferred_Node_A or Preferred_Node_B. Both System_Selected_Node_A and System_Selected_Node_B are reserved for system use only and cannot be set as the volume's node_affinity.Possible affinity for a volume. * System_Select_At_Attach - Volume currently has no node affinity, affinity will be assigned when the volume is first attached. * System_Selected_Node_A - System selected Node A as the optimized IO path to volume. * System_Selected_Node_B - System selected Node B as the optimized IO path to volume. * Preferred_Node_A - Node A will always advertise as the optimized IO path to volume. * Preferred_Node_B - Node B will always advertise as the optimized IO path to volume.",
    },
    node_affinity_l10n:          {
      type:      "Optional[String]",
      desc:      "Localized message string corresponding to node_affinity",
    },
    performance_policy_id:          {
      type:      "Optional[String]",
      desc:      "Unique identifier of the performance policy assigned to the volume.",
    },
    protection_data:          {
      type:      "Optional[Struct[{Optional[copy_signature] => Optional[String], Optional[created_by_rule_id] => Optional[String], Optional[created_by_rule_name] => Optional[String], Optional[creator_type] => Optional[Enum['User','System','Scheduler']], Optional[creator_type_l10n] => Optional[String], Optional[expiration_timestamp] => Optional[String], Optional[family_id] => Optional[String], Optional[is_app_consistent] => Optional[Boolean], Optional[parent_id] => Optional[String], Optional[source_id] => Optional[String], Optional[source_timestamp] => Optional[String], }]]",
      desc:      "Protection data associated with a resource. Filtering on the fields of this embedded resource is not supported.",
    },
    protection_policy_id:          {
      type:      "Optional[String]",
      desc:      "Unique identifier of the protection policy assigned to the volume.",
    },
    sector_size:          {
      type:      "Optional[Integer[512,4096]]",
      desc:      "Optional sector size, in bytes. Only 512-byte and 4096-byte sectors are supported.",
      behaviour: :init_only,
    },
    size:          {
      type:      "Optional[Integer[1048576,281474976710656]]",
      desc:      "Size of the volume to be created, in bytes. Minimum volume size is 1MB. Maximum volume size is 256TB. Size must be a multiple of 8192.",
    },
    state:          {
      type:      "Optional[Enum['Ready','Initializing','Offline','Destroying']]",
      desc:      "Volume life cycle states. * Ready - Volume is operating normally. * Initializing - Volume is starting but not yet ready for use. * Offline - Volume is not available. * Destroying - Volume is being deleted. No new operations are allowed.",
    },
    state_l10n:          {
      type:      "Optional[String]",
      desc:      "Localized message string corresponding to state",
    },
    type:          {
      type:      "Optional[Enum['Primary','Clone','Snapshot']]",
      desc:      "Type of volume. * Primary - A base object. * Clone - A read-write object that shares storage with the object from which it is sourced. * Snapshot - A read-only object created from a volume or clone.",
    },
    type_l10n:          {
      type:      "Optional[String]",
      desc:      "Localized message string corresponding to type",
    },
    volume_group_id:          {
      type:      "Optional[String]",
      desc:      "Volume group to add the volume to.  If not specified, the volume is not added to a volume group.",
      behaviour: :init_only,
    },
    wwn:          {
      type:      "Optional[String]",
      desc:      "World wide name of the volume.",
    },
  },
  autorequires: {
    file:    '$source', # will evaluate to the value of the `source` attribute
    package: 'apt',
  },
)
