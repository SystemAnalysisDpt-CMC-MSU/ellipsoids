function SInput=patch_004_change_email_settings_part2(~,SInput)
SInput.emailNotification.distributionList=...
    {'ellipsoids-tests-notification@googlegroups.com'};
SInput.emailNotification.smtpServer='xeonus';
SInput.emailNotification.isEnabled=true;
