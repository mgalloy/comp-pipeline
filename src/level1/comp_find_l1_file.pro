; docformat = 'rst'

;+
; Find the full path to a L1 file given a date/time.
;
; :Returns:
;   string/strarr or `!null` if no files found
;
; :Params:
;   date : in, required, type=string
;     date to process, in YYYYMMDD format
;   wave_type : in, required, type=string
;     wavelength type such as "1074", "1079", or "1083"
;
; :Keywords:
;   datetime : in, optional, type=string
;     date/time in the form "20150701.220501", must set or use `ALL`
;   all : in, optional, type=boolean
;     set to return all files of the given type
;   count : out, optional, type=integer
;     set to a named variable to retrieve the number of files returned via `/ALL`
;   background : in, optional, type=boolean
;     set to retrieve a background image instead of a foreground image
;
; :Author:
;   MLSO Software Team
;-
function comp_find_l1_file, date, wave_type, $
                            datetime=datetime, $
                            all=all, $
                            count=count, $
                            background=background
  compile_opt strictarr
  @comp_config_common

  _datetime = n_elements(datetime) gt 0L ? datetime : '*'
  filename_pattern = _datetime + '.comp.' + wave_type + '*.*.fts{,.gz}'
  full_pattern = filepath(filename_pattern, $
                          subdir=[date, 'level1'], $
                          root=process_basedir)
  filenames = file_search(full_pattern, count=n_files)

  _datetime = n_elements(datetime) gt 0L ? datetime : '[[:digit:]]{8}\.[[:digit:]]{6}'
  base_re = _datetime + '\.comp\.' + wave_type + '\.[iquv]+\.[[:digit:]]{1,2}'
  l1_re = base_re + (keyword_set(background) ? '\.bkg\.fts' : '\.fts')
  l1_mask = stregex(file_basename(filenames), l1_re, /boolean)
  l1_ind = where(l1_mask, count, /null)

  count = keyword_set(all) ? count : 1L
  ind = keyword_set(all) ? l1_ind : l1_ind[0]
  return, filenames[ind]
end
