self.TEST10_preaction = function()
{
}

self.TEST10_onloadaction = function()
{
}

// called when enable checkbox clicked
self.TEST10_enable = function()
{
  document.getElementById('BUTTON_TEST10_APPLY').disabled = false;
  var feature1 = document.getElementById('TEST10_FEATURE1');
  if (feature1)
  {
    feature1.disabled = false;
  }
}

// called when remove button clicked
self.TEST10_remove = function()
{
  if( !confirm(S['CONFIRM_REMOVE_ADDON']) )
  {
    return;
  }

  var set_url;

  set_url = NasState.otherAddOnHash['TEST10'].DisplayAtom.set_url
              + '?OPERATION=set&command=RemoveAddOn&data=remove';

  applyChangesAsynch(set_url,  TEST10_handle_remove_response);
}

self.TEST10_handle_remove_response = function()
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
         updateAddOn('TEST10');
         if (!NasState.otherAddOnHash['TEST10'])
         {
            remove_element('TEST10');
            if (getNumAddOns() == 0 )
            {
               document.getElementById('no_addons').className = 'visible';
            }
         }
         else
         {
           hide_element('TEST10_LINK');
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

self.TEST10_page_change = function()
{
  var id_array = new Array( 'TEST10_FEATURE1' );
  for (var ix = 0; ix < id_array.length; ix++ )
  {
    NasState.otherAddOnHash['TEST10'].DisplayAtom.fieldHash[id_array[ix]].value = document.getElementById(id_array[ix]).checked ? "checked" : "unchecked";
    NasState.otherAddOnHash['TEST10'].DisplayAtom.fieldHash[id_array[ix]].modified = true;
  }
}


self.TEST10_enable_save_button = function()
{
  document.getElementById('BUTTON_TEST10_APPLY').disabled = false;
}

// called when apply button clicked
self.TEST10_apply = function()
{

   var page_changed = false;
   var set_url = NasState.otherAddOnHash['TEST10'].DisplayAtom.set_url;
   var feature1 = document.getElementById('TEST10_FEATURE1');
   if (feature1)
   {
     var id_array = new Array ('TEST10_FEATURE1');
     for (var ix = 0; ix < id_array.length ; ix ++)
     {
       if (  NasState.otherAddOnHash['TEST10'].DisplayAtom.fieldHash[id_array[ix]].modified )
       {
          page_changed = true;
          break;
       }
     }
   }
   var enabled = document.getElementById('CHECKBOX_TEST10_ENABLED').checked ? 'checked' :  'unchecked';
   var current_status  = NasState.otherAddOnHash['TEST10'].Status;
   if ( page_changed )
   {
      set_url += '?command=ModifyAddOnService&OPERATION=set&' +
                  NasState.otherAddOnHash['TEST10'].DisplayAtom.getApplicablePagePostStringNoQuest('modify') +
                  '&CHECKBOX_TEST10_ENABLED=' +  enabled;
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
      set_url += '?command=ToggleService&OPERATION=set&CHECKBOX_TEST10_ENABLED=' + enabled;
   }
   applyChangesAsynch(set_url, TEST10_handle_apply_response);
}

self.TEST10_handle_apply_response = function()
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
		  success_message_start = success_message_start.replace('%ADDON_NAME%', NasState.otherAddOnHash['TEST10'].FriendlyName);
	      var success_message_stop  = AS['SUCCESS_ADDON_STOP'];
		  success_message_stop = success_message_stop.replace('%ADDON_NAME%', NasState.otherAddOnHash['TEST10'].FriendlyName);

	      if ( NasState.otherAddOnHash['TEST10'].Status == 'off' )
	      {
	        NasState.otherAddOnHash['TEST10'].Status = 'on';
	        NasState.otherAddOnHash['TEST10'].RunStatus = 'OK';
	        refresh_applicable_pages();
	      }
	      else
	      {
	        NasState.otherAddOnHash['TEST10'].Status = 'off';
	        NasState.otherAddOnHash['TEST10'].RunStatus = 'not_present';
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


