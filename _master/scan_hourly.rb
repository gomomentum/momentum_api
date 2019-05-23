require '../_master/apply_to_users'

@live_scan_updates = true
@instance = 'live' # 'live' or 'local'
@emails_from_username = 'Kim_Miller'

@exclude_user_names = %w(system discobot js_admin sl_admin JP_Admin admin_sscott RH_admin KM_Admin Winston_Churchill
                            Joe_Sabolefski)

# testing variables
# @target_username = 'Kim_Miller' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
# @target_groups = %w(Mods)  # GreatX BraveHearts trust_level_1 trust_level_0 hit 100 record limit.
@issue_users = %w() # past in debug issue user_names Brad_Fino
@scan_passes = 0
@scan_passes_end = 2

def scan_hourly

  printf "\n%s\n", 'Scanning All-User Tasks ...'
  run_tasks_for_all_users(do_live_updates=@live_scan_updates)
  @scan_passes += 1
  printf "%s\n", "\nPass #{@scan_passes} complete \n"

  # sleep(5 * 60)
  if @scan_passes < @scan_passes_end
    printf "%s\n", 'Repeating Scan'
    scan_hourly
  else
    printf "%s\n", '... Exiting ...'
  end

end

printf "\n%s\n", 'Starting Scan ...'

scan_hourly

scan_summary

# todo save log to disk
# todo tests