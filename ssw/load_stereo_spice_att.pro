;+
; Project     :	STEREO - SSC
;
; Name        :	LOAD_STEREO_SPICE_ATT
;
; Purpose     :	Load the STEREO SPICE attitude kernels
;
; Category    :	STEREO, Orbit
;
; Explanation : Called from GET_STEREO_CMAT to provide "on demand" loading of
;               the STEREO attitude history files in SPICE format.  The files
;               to load are stored into a common block by LOAD_STEREO_SPICE.
;               This routine takes a spacecraft name and a series of dates, and
;               determines which attitude files should be loaded.
;
; Syntax      :	LOAD_STEREO_SPICE_ATT, SPACECRAFT, DATE
;
; Inputs      :	SPACECRAFT = Either "-234" for Ahead or "-235" for Behind.
;               DATE       = One or more date/time values.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	VERBOSE = If set, then print a message for each file loaded or
;                         unloaded.
;
; Calls       :	PARSE_STEREO_NAME, ANYTIM2UTC
;
; Common      :	STEREO_SPICE contains the names of the files from
;               LOAD_STEREO_SPICE.
;
; Env. Vars.  : None.
;
; Restrictions:	This procedure works in conjunction with the Icy/CSPICE
;               package, which is implemented as an IDL Dynamically Loadable
;               Module (DLM).  The Icy source code can be downloaded from
;
;                       ftp://naif.jpl.nasa.gov/pub/naif/toolkit/IDL
;
;               Because this uses dynamic frames, it requires Icy/CSPICE
;               version N0058 or higher.
;
; Side effects:	This routine is designed to be called from GET_STEREO_CMAT, and
;               may not be as error-tolerant as other higher-level routines.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 24-Jul-2007, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro load_stereo_spice_att, spacecraft, date, verbose=verbose
;
common stereo_spice, def_ephem, ephem, attitude, att_sc, att_mjd, att_loaded
;
;  Keep track of which attitude history files are referenced by this routine.
;
referenced = bytarr(n_elements(attitude))
;
;  Parse the spacecraft name.
;
sc = parse_stereo_name(spacecraft, ['-234','-235'])
;
;  Find all requested Modified Julian Dates.
;
utc = anytim2utc(date)
mjd = all_vals(utc.mjd)
nmjd = n_elements(mjd)
;
;  For each date, try to find the corresponding attitude history file.
;
for imjd = 0,nmjd-1 do begin
    w = where((att_sc eq sc) and (att_mjd eq mjd[imjd]), count)
    if count gt 0 then begin
        ii = w[0]
        referenced[ii] = 1
        if att_loaded[ii] eq 0 then begin
            cspice_furnsh, attitude[ii]
            if keyword_set(verbose) then print, 'Loaded ' + attitude[ii]
            att_loaded[ii] = 1
        endif
    endif
endfor
;
;  If the total number of attitude history files is greater than 20, unload any
;  files not referenced here.
;
if total(att_loaded) gt 20 then begin
    w = where((att_loaded eq 1) and (referenced eq 0), count)
    if count gt 0 then for i=0,count-1 do begin
        ii = w[i]
        cspice_unload, attitude[ii]
        if keyword_set(verbose) then print, 'Unloaded ' + attitude[ii]
        att_loaded[ii] = 0
    endfor
endif
;
;  Make sure that at least one attitude history file is loaded.
;
w = where(att_sc eq sc)
if total(att_loaded[w]) eq 0 then begin
    ii = w[0]
    cspice_furnsh, attitude[ii]
    if keyword_set(verbose) then print, 'Loaded ' + attitude[ii]
    att_loaded[ii] = 1
    referenced[ii] = 1
endif
;
return
end
