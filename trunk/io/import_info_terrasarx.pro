;------------------------------------------------------------------------
; RAT - Radar Tools
;------------------------------------------------------------------------
; RAT Module: import_info_terrasarx
; written by    : Tisham Dhar
; last revision : 11/2007
; Import TerraSAR-X Metadata from XML file
;------------------------------------------------------------------------
; The contents of this file are subject to the Mozilla Public License
; Version 1.1 (the "License"); you may not use this file except in
; compliance with the License. You may obtain a copy of the License at
; http://www.mozilla.org/MPL/
;
; Software distributed under the License is distributed on an "AS IS"
; basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
; License for the specific language governing rights and limitations
; under the License.
;
; The Initial Developer of the Original Code is the RAT development team.
; All Rights Reserved.
;------------------------------------------------------------------------
pro import_info_terrasarx,INPUTFILE_FIRST=inputfile0
  common rat
  common channel, channel_names, channel_selec, color_flag, palettes, pnames

  if n_elements(inputfile0) ne 0 then xml_file=inputfile0 $
  else begin

;;; GUI for file selection
     path = config.workdir
     xml_file = cw_rat_dialog_pickfile(TITLE='Open TERRASAR-X system info file', $
                                       DIALOG_PARENT=wid.base, FILTER = '*.xml', /MUST_EXIST, PATH=path, GET_PATH=path)
  endelse

  if file_test(xml_file,/READ) then config.workdir = path else return


  ;Read relevant XML tags
  oDocument = OBJ_NEW('IDLffXMLDOMDocument', FILENAME=xml_file,/EXCLUDE_IGNORABLE_WHITESPACE)

  ;read statevectors
  oNodeList = oDocument->GetElementsByTagName('stateVec')
  veclen = oNodeList->GetLength()

  for i=0,veclen-1 do begin
  	posx = (((oNodeList->Item(i))->GetElementsByTagName('posX'))->Item(0))->GetFirstChild()
  	posy = (((oNodeList->Item(i))->GetElementsByTagName('posY'))->Item(0))->GetFirstChild()
  	posz = (((oNodeList->Item(i))->GetElementsByTagName('posZ'))->Item(0))->GetFirstChild()
  	;Test null nodes
  	if posx ne obj_new() and posy ne obj_new() and posz ne obj_new() then begin
  		x = double(posx->GetNodeValue())
  		y = double(posy->GetNodeValue())
  		z = double(posz->GetNodeValue())
  		print,"Radius:"+string(sqrt(x^2+y^2+z^2))
  	endif else begin
  		print,'Null node'
  	endelse
  endfor

  ;read corner coordinates
  oNodeList = oDocument->GetElementsByTagName('sceneCornerCoord')
  cornlen = oNodeList->GetLength()

  for i=0,cornlen-1 do begin
    lat = (((oNodeList->Item(i))->GetElementsByTagName('lat'))->Item(0))->GetFirstChild()
    lon = (((oNodeList->Item(i))->GetElementsByTagName('lon'))->Item(0))->GetFirstChild()
    ang = (((oNodeList->Item(i))->GetElementsByTagName('incidenceAngle'))->Item(0))->GetFirstChild()
    ;Test null nodes
  	if posx ne obj_new() and posy ne obj_new() and ang ne obj_new() then begin
  		latitude = double(lat->GetNodeValue())
  		longitude = double(lon->GetNodeValue())
  		incidenceAngle = double(ang->GetNodeValue())
  		print,"Latitude:"+string(latitude)
  		print,"Longitude:"+string(longitude)
  		print,"IncidenceAngle:"+string(incidenceAngle)
  	endif else begin
  		print,'Null node'
  	endelse
  endfor

  ;read scene average height over the ellipsoid
  oNodeList = oDocument->GetElementsByTagName('sceneAverageHeight')
  if oNodeList->GetLength() gt 0 then begin
  	averageheight = double(((oNodeList->Item(0))->GetFirstChild())->GetNodeValue())
  	print,"SceneAverageHeight:"+string(averageheight)
  endif

end