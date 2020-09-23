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
my $enabled        = $in{"CHECKBOX_SAMBA36_ENABLED"};
my $data           = $in{"data"};

get_default_language_strings("SAMBA36");
 
my $xml_payload = "Content-type: text/xml; charset=utf-8\n\n"."<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
 
if( $operation eq "get" )
{
  $xml_payload .= Show_SAMBA36_xml();
}
elsif( $operation eq "set" )
{
  if( $command eq "RemoveAddOn" )
  {
    # Remove_Service_xml() removes this add-on
    $xml_payload .= Remove_Service_xml("SAMBA36", $data);
  }
  elsif ($command eq "ToggleService")
  {
    # Toggle_Service_xml() toggles the enabled state of the add-on
    $xml_payload .= Toggle_Service_xml("SAMBA36", $enabled);
  }
  elsif ($command eq "ModifyAddOnService")
  {
    # Modify_SAMBA36_xml() processes the input form changes
    $xml_payload .= Modify_SAMBA36_xml();
  }
}

print $xml_payload;
  

sub Show_SAMBA36_xml
{
  my $xml_payload = "<payload><content>" ;

  # check if service is running or not 
  my $enabled = GetServiceStatus("SAMBA36");

  # get SAMBA36_SMB2 parameter from /etc/default_services
  my $smb2 = GetValueFromServiceFile("SAMBA36_SMB2");

  # default (NOT_FOUND) for SMB2 is 1
  my $smb2_state = "1";
  if ( $smb2 eq "0" ) {
      $smb2_state = "0";
  }

  my $enabled_disabled = "disabled";
     $enabled_disabled = "enabled" if( $enabled );

  # return run_time value for HTML
  $xml_payload .= "<SAMBA36_SMB2><value>$smb2_state</value><enable>$enabled_disabled</enable></SAMBA36_SMB2>"; 

  $xml_payload .= "</content><warning>No Warnings</warning><error>No Errors</error></payload>";
  
  return $xml_payload;
}


sub Modify_SAMBA36_xml 
{
  my $smb2_state  = $in{"SAMBA36_SMB2"};
  my $smb2 = 0;
  my $SPOOL;
  my $xml_payload;
  
  if ( $smb2_state eq "checked" ) {
      $smb2 = 1;
  }
  
  $SPOOL .= "
if grep -q SAMBA36_SMB2 /etc/default/services; then
  sed -i 's/SAMBA36_SMB2=.*/SAMBA36_SMB2=${smb2}/' /etc/default/services
else
  echo 'SAMBA36_SMB2=${smb2}' >> /etc/default/services
fi
";
 
  if( $in{SWITCH} eq "YES" ) 
  {
    spool_file("${ORDER_SERVICE}_SAMBA36", $SPOOL);
    $xml_payload = Toggle_Service_xml("SAMBA36", $enabled);
  }
  else
  {
    if ( $enabled eq "checked" ) {
      # start will pickup the feature change
      $SPOOL .= "
/etc/frontview/addons/bin/SAMBA36/start.sh
";
    }
    spool_file("${ORDER_SERVICE}_SAMBA36", $SPOOL);
    empty_spool();
    $xml_payload = _build_xml_set_payload_sync();
  }
  return $xml_payload;
}


1;
