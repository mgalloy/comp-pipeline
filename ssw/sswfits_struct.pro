function sswfits_struct, number, version=version, $
                         oldversion=olversion, update=update, $
                         addfits=addfits, refresh=refresh
;+
;   Name: sswfits_struct
;
;   Purpose: return "STANDARD" ssw structure  (FITs->IDL mapping)
;
;   Input Parameters:
;      number (optional) - number structures returned  - default is one  
;  
;   Keyword Parameters:
;      addfits - switch , if set, include FITS required minimal tags
;
;   Calling Sequence:
;      str=sswfits_struct( [number] [/addfits] )
;
;   History:
;      15-jan-1997 - S.L. Freeland (from 'eit_struct.pro')
;      25-feb-1997 - SSW generic
;      10-apr-1998 - add CROTA (CED)
;       8-sep-1998 - add EXPTIME and WAVELNTH (CED)
;      15-oct-1998 - S.L.Freeland add SOLAR_L0, SOLAR_P, CROTA2,
;                    XCEN, YCEN
;                    /ADDFITS keyword and function - made version=2
;       4-Apr-2000 -  Add CROTACN1 and CROTACN2 (floating)
;-

version=2

common	ssw_struct_blk, str, catstr

if keyword_set(oldversion) then version=oldversion

if n_elements(str) eq 0 or keyword_set(refresh) then		$
   case 1 of 

   version le 2 : str={						$

        version:2,						$

;       ----------- standards (soho/yohkoh...) ------------------

        date:'', mjd:0l, day:0, time:0l,			$
        time_obs:'',date_obs:'',				$
	filename:'',				                $
        origin:'', telescop:'', instrume:'', object:'',	        $
        sci_obj:'', obs_prog:'',				$
	exptime:0.,wavelnth:'',				        $

;       -------- pointing -----------------------
	ctype1:'',  ctype2:'', ctype3:'',			$
	crpix1:0.,  crpix2:0., crpix3:0.,  			$
        crval1:0.,  crval2:0., crval3:0., 		        $
        cdelt1:0.,  cdelt2:0., cdelt3:0.,			$
        xcen:0.,    ycen:0.,					$
        crotA:0.,   crota2:0.,         				$
        crotAcn1:0.,crotAcn2:0.,                                $
        solar_r:0., solar_b0:0., 				$
        solar_l0:0., solar_p:0. } 		                

    else: message,/info,"Unexpected version number: " + strtrim(version,2)
endcase

fits_required={simple:1, bitpix:0, 				$
               naxis:0l, naxis1:0l, naxis2:0l, naxis3:0l        } 	

outstr=str
if keyword_set(addfits) then outstr=join_struct(fits_required,str)

if n_elements(number) gt 0 then outstr=replicate(outstr,long(number))

return,outstr
end


