self.SAMBA36_preaction = function()
{
}

self.SAMBA36_onloadaction = function()
{
}

// called when enable checkbox clicked
self.SAMBA36_enable = function()
{
  document.getElementById('BUTTON_SAMBA36_APPLY').disabled = false;
  var smb2 = document.getElementById('SAMBA36_SMB2');
  if (smb2)
  {
    smb2.disabled = false;
  }
}

// called when remove button clicked
self.SAMBA36_remove = function()
{
  if( !confirm(S['CONFIRM_REMOVE_ADDON']) )
  {
    return;
  }

  var set_url;

  set_url = NasState.otherAddOnHash['SAMBA36'].DisplayAtom.set_url
              + '?OPERATION=set&command=RemoveAddOn&data=remove';

  applyChangesAsynch(set_url,  SAMBA36_handle_remove_response);
}

self.SAMBA36_handle_remove_response = function()
{
  if ( httpAsyncRequestObject &&
      httpAsyncRequestObject.readyState &&
      httpAsyncRequestObject.readyState == 4 )
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
       showProgressBar('default');
       xmlPayLoad  = httpAsyncRequestObject.responseXML;
       var status = xmlPayLoad.getElementsByTagName('status').item(0);
       if (!status || !status.firstChild)
       {
          return;
       }

       if ( status.firstChild.data == 'success')
       {
         display_messages(xmlPayLoad);
         updateAddOn('SAMBA36');
         if (!NasState.otherAddOnHash['SAMBA36'])
         {
            remove_element('SAMBA36');
            if (getNumAddOns() == 0 )
            {
               document.getElementById('no_addons').className = 'visible';
            }
         }
         else
         {
           hide_element('SAMBA36_LINK');
         }
       }
       else if (status.firstChild.data == 'failure')
       {
         display_error_messages(xmlPayLoad);
       }
    }
    httpAsyncRequestObject = null;
  }
}

self.SAMBA36_page_change = function()
{
  var id_array = new Array( 'SAMBA36_SMB2' );
  for (var ix = 0; ix < id_array.length; ix++ )
  {
    NasState.otherAddOnHash['SAMBA36'].DisplayAtom.fieldHash[id_array[ix]].value = document.getElementById(id_array[ix]).checked ? "checked" : "unchecked";
    NasState.otherAddOnHash['SAMBA36'].DisplayAtom.fieldHash[id_array[ix]].modified = true;
  }
}


self.SAMBA36_enable_save_button = function()
{
  document.getElementById('BUTTON_SAMBA36_APPLY').disabled = false;
}

// called when apply button clicked
self.SAMBA36_apply = function()
{

   var page_changed = false;
   var set_url = NasState.otherAddOnHash['SAMBA36'].DisplayAtom.set_url;
   var id_array = new Array ('SAMBA36_SMB2');
   for (var ix = 0; ix < id_array.length ; ix ++)
   {
     if (  NasState.otherAddOnHash['SAMBA36'].DisplayAtom.fieldHash[id_array[ix]].modified )
     {
        page_changed = true;
        break;
     }
   }
   var enabled = document.getElementById('CHECKBOX_SAMBA36_ENABLED').checked ? 'checked' :  'unchecked';
   var current_status  = NasState.otherAddOnHash['SAMBA36'].Status;
   if ( page_changed )
   {
      set_url += '?command=ModifyAddOnService&OPERATION=set&' + 
                  NasState.otherAddOnHash['SAMBA36'].DisplayAtom.getApplicablePagePostStringNoQuest('modify') +
                  '&CHECKBOX_SAMBA36_ENABLED=' +  enabled;
      if ( enabled == 'checked' && current_status == 'on' ) 
      {
        set_url += "&SWITCH=NO";
      }
      else
      {
         set_url += "&SWITCH=YES";
      }
   }
   else
   {
      set_url += '?command=ToggleService&OPERATION=set&CHECKBOX_SAMBA36_ENABLED=' + enabled;
   }
   applyChangesAsynch(set_url, SAMBA36_handle_apply_response);
}

self.SAMBA36_handle_apply_response = function()
{
  if ( httpAsyncRequestObject &&
       httpAsyncRequestObject.readyState &&
       httpAsyncRequestObject.readyState == 4 )
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
      showProgressBar('default');
      xmlPayLoad = httpAsyncRequestObject.responseXML;
      var status = xmlPayLoad.getElementsByTagName('status').item(0);
      if ( !status || !status.firstChild )
      {
        return;
      }

      if ( status.firstChild.data == 'success' )
      {
        var log_alert_payload = xmlPayLoad.getElementsByTagName('normal_alerts').item(0);
        if ( log_alert_payload )
	{
	  var messages = grabMessagePayLoad(log_alert_payload);
	  if ( messages && messages.length > 0 )
	  {
	      if ( messages != 'NO_ALERTS' )
	      {
	        alert (messages);
	      }
	      var success_message_start = AS['SUCCESS_ADDON_START'];
		  success_message_start = success_message_start.replace('%ADDON_NAME%', NasState.otherAddOnHash['SAMBA36'].FriendlyName);
	      var success_message_stop  = AS['SUCCESS_ADDON_STOP'];
		  success_message_stop = success_message_stop.replace('%ADDON_NAME%', NasState.otherAddOnHash['SAMBA36'].FriendlyName);

	      if ( NasState.otherAddOnHash['SAMBA36'].Status == 'off' )
	      {
	        NasState.otherAddOnHash['SAMBA36'].Status = 'on';
	        NasState.otherAddOnHash['SAMBA36'].RunStatus = 'OK';
	        refresh_applicable_pages();
	      }
	      else
	      {
	        NasState.otherAddOnHash['SAMBA36'].Status = 'off';
	        NasState.otherAddOnHash['SAMBA36'].RunStatus = 'not_present';
	        refresh_applicable_pages();
	      }
	    }
        }
      }
      else if (status.firstChild.data == 'failure')
      {
        display_error_messages(xmlPayLoad);
      }
    }
    httpAsyncRequestObject = null;
  }
}
