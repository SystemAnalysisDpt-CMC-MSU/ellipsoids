function SInput=patch_005_change_email_settings_part3(~,SInput)
SInput.emailNotification.smtpServer='glados';
if isfield(SInput.emailNotification,'xeonus')
    SInput.emailNotification=rmfield(SInput.emailNotification,'xeonus');
end