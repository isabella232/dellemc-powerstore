# List filesystems whose used_size is greated than threshold
# @param threshold A percentage
plan powerstore::get_fs_used_size_greaterthan_threshold(
  TargetSpec $targets,
  Integer $threshold=90,
){
  $file_systems = run_task('powerstore::file_system_collection_query', $targets)[0].value
  $filtered_file_systems = $file_systems.filter | $k, $v | {
    if $v['size_total'] and $v['size_total'] > 0 {
      $v['size_used']*100.0 / $v['size_total'] > $threshold
    }
  }
  # return $filtered_file_systems.map |$k,$v| { $k }

  $rows = $filtered_file_systems.map |$k,$v| {
    [$k, String($v['size_used']*100.0 / $v['size_total'], '%0.1f')]
  }
  $usage_table = format::table({
    title => "List of file systems using more than ${threshold}%",
    head => ['file system', 'use %'].map |$field| { format::colorize($field, yellow) },
    rows => $rows
    })
  out::message($usage_table)
}
