#!/usr/bin/perl
#-------------------------------------------------------------------------
#  Copyright 2007, NETGEAR
#  All rights reserved.
#-------------------------------------------------------------------------

do "/frontview/lib/cgi-lib.pl";
do "/frontview/lib/addon.pl";

# initialize the %in hash
%in = ();
ReadParse();

my $operation      = $in{OPERATION};
my $command        = $in{command};
my $enabled        = $in{"CHECKBOX_TEST10_ENABLED"};
my $data           = $in{"data"};

get_default_language_strings("TEST10");
 
my $xml_payload = "Content-type: text/xml; charset=utf-8\n\n"."<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
 
if( $operation eq "get" )
{
  $xml_payload .= Show_TEST10_xml();
}
elsif( $operation eq "set" )
{
  if( $command eq "RemoveAddOn" )
  {
    # Remove_Service_xml() removes this add-on
    $xml_payload .= Remove_Service_xml("TEST10", $data);
  }
  elsif ($command eq "ToggleService")
  {
    # Toggle_Service_xml() toggles the enabled state of the add-on
    $xml_payload .= Toggle_Service_xml("TEST10", $enabled);
  }
  elsif ($command eq "ModifyAddOnService")
  {
    # Modify_TEST10_xml() processes the input form changes
    $xml_payload .= Modify_TEST10_xml();
  }
}

print $xml_payload;
  

sub Show_TEST10_xml
{
  my $xml_payload = "<payload><content>" ;

  # check if service is running or not 
  my $enabled = GetServiceStatus("TEST10");

  my $feature1 = GetValueFromServiceFile("TEST10_FEATURE1");

  # default (NOT_FOUND) for feature1 is 1
  my $feature1_state = "1";
  if ( $feature1 eq "0" ) {
      $feature1_state = "0";
  }

  my $enabled_disabled = "disabled";
     $enabled_disabled = "enabled" if( $enabled );

  # return run_time value for HTML
  $xml_payload .= "<TEST10_FEATURE1><value>$feature1_state</value><enable>$enabled_disabled</enable></TEST10_FEATURE1>"; 

  $xml_payload .= "</content><warning>No Warnings</warning><error>No Errors</error></payload>";
  
  return $xml_payload;
}


sub Modify_TEST10_xml 
{
  my $feature1_state  = $in{"TEST10_FEATURE1"};
  my $feature1 = 0;
  my $SPOOL;
  my $xml_payload;
  
  if ( $feature1_state eq "checked" ) {
      $feature1 = 1;
  }

  $SPOOL .= "
if grep -q TEST10_FEATURE1= /etc/default/services; then
  sed -i 's/TEST10_FEATURE1=.*/TEST10_FEATURE1=${feature1}/' /etc/default/services
else
  echo 'TEST10_FEATURE1=${feature1}' >> /etc/default/services
fi
";

  if( $in{SWITCH} eq "YES" ) 
  {
    spool_file("${ORDER_SERVICE}_TEST10", $SPOOL);
    $xml_payload = Toggle_Service_xml("TEST10", $enabled);
  }
  else
  {
    if ( $enabled eq "checked" ) {
      # start will pickup the feature change
      $SPOOL .= "
/etc/frontview/addons/bin/TEST10/start.sh
";
    }
    spool_file("${ORDER_SERVICE}_TEST10", $SPOOL);
    empty_spool();
    $xml_payload = _build_xml_set_payload_sync();
  }
  return $xml_payload;
}


1;
