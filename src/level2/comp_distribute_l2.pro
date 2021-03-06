; docformat = 'rst'

;+
; Distribute CoMP Level_2 files from processing pipeline into the appropriate
; directories.
;
; :Examples:
;   Try::
;
;     comp_distribute_l2, '20121209', '1074'
;
; :Params:
;   date_dir : in, required, type=string
;     date to process, in YYYYMMDD format
;   wave_type : in, required, type=string
;     wavelength range for the observations, '1074', '1079' or '1083'
;
; :Author:
;   MLSO Software Team
;-
pro comp_distribute_l2, date_dir, wave_type
  compile_opt strictarr
  @comp_config_common
  @comp_constants_common

  mg_log, 'distribute L2 for %s', wave_type, name='comp', /info
  
  l1_process_dir = filepath('', subdir=[date_dir, 'level1'], root=process_basedir)
  l2_process_dir = filepath('', subdir=[date_dir, 'level2'], root=process_basedir)
  if (~file_test(l2_process_dir, /directory)) then begin
    mg_log, 'level2 directory does not exist', name='comp', /warn
    goto, done
  endif

  cd, l2_process_dir
  
  ; for the directory name
  year = strmid(date_dir, 0, 4)
  month = strmid(date_dir, 4, 2)
  day = strmid(date_dir, 6, 4)
  destination = year + '/' + month + '/' + day  

  adir = filepath('', subdir=destination, root=archive_dir)
  if (~file_test(adir, /directory)) then file_mkdir, adir
  frdir = filepath('', subdir=destination, root=fullres_dir)
  if (~file_test(frdir, /directory)) then file_mkdir, frdir

  ; copy files

  averaging_types = ['mean', 'median', 'sigma']
  types = ['synoptic', 'waves']
  for t = 0L, n_elements(types) - 1L do begin
    for a = 0L, n_elements(averaging_types) - 1L do begin
      ; quick invert file
      filename = string(date_dir, wave_type, averaging_types[a], types[t], $
                        format='(%"%s.comp.%s.quick_invert.%s.%s.fts.gz")')
      if (file_test(filename)) then begin
        mg_log, 'copying %s %s quick invert file...', $
                averaging_types[a], types[t], $
                name='comp', /info

        file_copy, filename, adir, /overwrite
      endif

      ; average file
      filename = string(date_dir, wave_type, averaging_types[a], types[t], $
                        format='(%"%s.comp.%s.%s.%s.fts.gz")')
      if (file_test(filename)) then begin
        mg_log, 'copying %s %s file...', averaging_types[a], types[t], $
                name='comp', /info

        file_copy, filename, adir, /overwrite
      endif
    endfor
  endfor

  types = ['dynamics', 'polarization']
  for t = 0L, n_elements(types) - 1L do begin
    files = file_search('*.comp.' + wave_type + '.' + types[t] + '.fts.gz', $
                        count=n_files)
    mg_log, 'copying %d %s FITS files...', n_files, types[t], name='comp', /info
    if (n_files gt 0L) then file_copy, files, adir, /overwrite
  endfor

  daily_types = ['daily_dynamics', 'daily_polarization']
  for t = 0L, n_elements(types) - 1L do begin
    files = file_search(string(wave_type, types[t], $
                               format='(%"*.comp.%s.%s.fts.gz")'), $
                        count=n_files)

    if (n_files gt 0L) then begin
      tar_filename = string(date_dir, wave_type, daily_types[t], $
                            format='(%"%s.comp.%s.%s.tar.gz")')
      tar_cmd = string(tar_filename, strjoin(files, ' '), $
                       format='(%"tar cfz %s %s")')
      spawn, tar_cmd, result, error_result, exit_status=status
      if (status ne 0L) then begin
        mg_log, 'problem tarring file with command: %s', tar_cmd, $
                name='comp', /error
        mg_log, '%s', error_result, name='comp', /error
      endif else begin
        mg_log, 'copying %s file...', types[t], $
                name='comp', /info
        file_copy, tar_filename, adir, /overwrite
      endelse
    endif else begin
      mg_log, 'no %s file to archive', types[t], $
              name='comp', /info
    endelse
  endfor

  file_copy, date_dir + '.comp.' + wave_type + '.daily_summary.txt', adir, /overwrite

  files = file_search('*.comp.' + wave_type + '.quickview*.jpg', count=n_files)
  mg_log, 'copying %d quick view images...', n_files, name='comp', /info
  if (n_files gt 0L) then file_copy, files, frdir, /overwrite  

  movies_dir = filepath('', subdir='movies', root=l2_process_dir)
  if (file_test(movies_dir, /directory)) then begin
    cd, movies_dir

    ; PNGs
    files = file_search('*.comp.' + wave_type + '.daily*.png', count=n_files)
    mg_log, 'copying %d PNGs...', n_files, name='comp', /info
    if (n_files gt 0L) then file_copy, files, frdir, /overwrite

    ; JPGs
    files = file_search('*.comp.' + wave_type + '.daily*.jpg', count=n_files)
    mg_log, 'copying %d JPGs...', n_files, name='comp', /info
    if (n_files gt 0L) then file_copy, files, frdir, /overwrite

    ; movies
    files = file_search('*.comp.' + wave_type + '*.mp4', count=n_files)
    mg_log, 'copying %d movies...', n_files, name='comp', /info
    if (n_files gt 0L) then file_copy, files, frdir, /overwrite

    cd, '..'
  endif

  ; tar and send to HPSS

  if (wave_type ne '1083' && send_to_hpss) then begin
    mg_log, 'tarring and sending L2 for %s to HPSS', wave_type, name='comp', /info
    if (~file_test(hpss_gateway, /directory)) then file_mkdir, hpss_gateway

    time_delay = '0h'
    archive_script = filepath('archive_l2.sh', $
                              subdir=['..', 'scripts'], $
                              root=binary_dir)
    cmd = string(archive_script, date_dir, wave_type, hpss_gateway, time_delay, $
                 format='(%"%s %s %s %s %s &")')
    spawn, cmd, result, error_result, exit_status=status
    if (status ne 0L) then begin
      mg_log, 'problem sending data to HPSS with command: %s', cmd, $
              name='comp', /error
      mg_log, '%s', error_result, name='comp', /error
    endif

    l2_tarname = date_dir + '.comp.' + wave_type + '.l2.tgz'
  endif else begin
    mg_log, 'skipping linking to L2 tarball from HPSS dir...', name='comp', /info
  endelse

  done:
  mg_log, 'done', name='comp', /info
end
