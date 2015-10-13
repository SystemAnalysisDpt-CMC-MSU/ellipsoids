function SInput=patch_003_change_email_settings(~,SInput)
SInput.emailNotification.distributionList=...
    {'ellipsoids-tests-notification@googlegroups.com'};
SInput.emailNotification.xeonus='xeonus';
SInput.emailNotification.isEnabled=true;
