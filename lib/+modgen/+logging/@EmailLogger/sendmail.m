function sendmail(self,to,subject,message,attachments)
%SENDMAIL Send e-mail.
%   SENDMAIL(TO,SUBJECT,MESSAGE,ATTACHMENTS) sends an e-mail.  TO is either a
%   string specifying a single address, or a cell array of addresses.  SUBJECT
%   is a string.  MESSAGE is either a string or a cell array.  If it is a
%   string, the text will automatically wrap at 75 characters.  If it is a cell
%   array, it won't wrap, but each cell starts a new line.  In either case, use
%   char(10) to explicitly specify a new line.  ATTACHMENTS is a string or a
%   cell array of strings listing files to send along with the message.  Only TO
%   and SUBJECT are required.
%
%   SENDMAIL relies on two preferences, "Internet:SMTP_Server", your mail
%   server, and "Internet:E_mail", your e-mail address.  Use SETPREF to set
%   these before using SENDMAIL.  The easiest ways to identify your outgoing
%   mail server is to look at the preferences of another e-mail application or
%   consult your administrator.  If you cannot find out your server's name,
%   setting it to just 'mail' might work.  If you do not set these preferences
%   SENDMAIL will try to determine them automatically by reading environment 
%   variables and the Windows registry.
%
%   Example:
%     setpref('Internet','SMTP_Server','mail.example.com');
%     setpref('Internet','E_mail','matt@example.com');
%     sendmail('user@example.com','Calculation complete.')
%     sendmail({'matt@example.com','peter@example.com'},'You''re cool!', ...
%       'See the attached files for more info.',{'attach1.m','d:\attach2.doc'});
%     sendmail('user@example.com','Adding additional breaks',['one' 10 'two']);
%     sendmail('user@example.com','Specifying exact lines',{'one','two'});
%
%   See also WEB, FTP.

% Peter Webb, Aug. 2000
% Matthew J. Simoneau, Nov. 2001, Aug 2003, Jan 2006
% Copyright 1984-2007 The MathWorks, Inc.
% $Revision: 1.4.4.13 $  $Date: 2007/12/06 13:30:05 $

% This function requires Java.
if ~usejava('jvm')
   error('MATLAB:sendmail:NoJvm','SENDMAIL requires Java.');
end

import javax.mail.*
import javax.mail.internet.*
import javax.activation.*

% Argument parsing.
error(nargchk(3,5,nargin,'struct'));
if ischar(to)
    to = {to};
end
if (nargin < 3)
    message = '';
end
if (nargin < 4) 
    attachments = [];
elseif ischar(attachments)
    attachments = {attachments};
end

% Determine server and from.
[server,from] = getServerAndFrom(self);
if isempty(server)
    error([upper(mfilename),':SMTPServerIndeterminate'],...
    'Could not determine SMTP server');
end
if isempty(from)
    error([upper(mfilename),':FromAddressIndeterminate'],...
        'Could not determine FROM address');
end

% Use the system properties, but clone them so we don't alter them.
props = java.lang.System.getProperties.clone;
props.put('mail.smtp.host',server);

% Create session.
username = self.smtpUserName;
password = self.smtpPassword;
if isempty(username)
    pa = [];
else
    pa = com.mathworks.util.PasswordAuthenticator(username,password);
end
session = Session.getInstance(props,pa);

% Create the message.
msg = MimeMessage(session);

% Set sender.
msg.setFrom(getInternetAddress(from));

% Set recipients.
for i = 1:numel(to)
    msg.addRecipient(getRecipientTypeTo(msg), ...
        getInternetAddress(to{i}));
end

% Try to do the right thing on Japanese machines.
isJapanese = ispc && strncmpi(get(0,'Language'),'ja',2);

% Set subject.
if any(subject == char(10)) || any(subject == char(13))
    error([upper(mfilename),':InvalidSubject'],  ...
    'Subjects cannot contain newline characters');
end
if isJapanese
    msg.setSubject(subject,'SJIS')
else
    msg.setSubject(subject)
end

% Set other headers.
msg.setHeader('X-Mailer', ['MATLAB ' version])
msg.setSentDate(java.util.Date);

% Construct the body of the message and attachments.
body = formatText(message);
if numel(attachments) == 0
    if isJapanese
        msg.setText(body,'SJIS');
    else
        msg.setText(body);
    end
else
    % Add body text.
    messageBodyPart = MimeBodyPart;
    if isJapanese
        messageBodyPart.setText(body,'SJIS');
    else
        messageBodyPart.setText(body);
    end
    multipart = MimeMultipart;
    multipart.addBodyPart(messageBodyPart);

    % Add attachments.
    for iAttachments = 1:numel(attachments)
        file = attachments{iAttachments};
        messageBodyPart = MimeBodyPart;
        fullName = locateFile(file);
        if isempty(fullName)
            error('MATLAB:sendmail:CannotOpenFile', ...
                'Cannot open file "%s".',file);
        end
        source = FileDataSource(fullName);
        messageBodyPart.setDataHandler(DataHandler(source));
        
        % Remove the directory, if any, from the attachement name.
        [~,fileName,fileExt] = fileparts(fullName);
        messageBodyPart.setFileName([fileName fileExt]);
        multipart.addBodyPart(messageBodyPart);
    end
    
    % Put parts in message
    msg.setContent(multipart);

end

% Send the message.
try
    Transport.send(msg);
catch exception   
    % Try to make the Java error friendlier.
    niceError = stripJavaError(exception.message);
    if isempty(niceError)
        throw(exception);
    else
        error([upper(mfilename),':SmtpError'],'%s',niceError)
    end
end

%===============================================================================
function [server,from] = getServerAndFrom(self)
%getServerAndFrom Look in several places for default values.

% Check preferences.
server = self.smtpServer;
from = self.emailAddress;

% Check Java properties.
if isempty(server)
    props = java.lang.System.getProperties;
    server = char(props.getProperty('mail.smtp.host'));
end

% Determine defaultMailAccountRegistry.
if (ispc && (isempty(server) || isempty(from)))
    try
        defaultMailAccount = winqueryreg('HKEY_CURRENT_USER', ...
            'Software\Microsoft\Internet Account Manager', ...
            'Default Mail Account');
        defaultMailAccountRegistry = ...
            ['Software\Microsoft\Internet Account Manager\Accounts\' ...
            defaultMailAccount];
    catch exception %#ok
        defaultMailAccountRegistry = '';
    end
end

% Determine SERVER
if ispc && isempty(server) && ~isempty(defaultMailAccountRegistry)
    try
        server = winqueryreg('HKEY_CURRENT_USER',defaultMailAccountRegistry, ...
            'SMTP Server');
    catch exception %#ok
    end
end
if isempty(server)
    server = getenv('MAILHOST');
end

% Determine FROM
if ispc && isempty(from)
    try
        from = winqueryreg('HKEY_CURRENT_USER',defaultMailAccountRegistry, ...
            'SMTP Email Address');
    catch exception %#ok
    end
end
if isempty(from)
    from = getenv('LOGNAME');
end

%===============================================================================
function internetAddress = getInternetAddress(from)
%getInternetAddress Instantiate an InternetAddress object.

try
    internetAddress = javax.mail.internet.InternetAddress(from);
catch exception 
    error([upper(mfilename),':AddressError'],'%s',...
        stripJavaError(exception.message));
end


%===============================================================================
function recipientTypeTo = getRecipientTypeTo(msg)
%getRecipientTypeTo Return the static RecipientType.TO.

% Get the class loader for the Message class.
cl = msg.getClass.getClassLoader;
% Returns a Class object pointing to RecipientType using that ClassLoader.
rt = java.lang.Class.forName('javax.mail.Message$RecipientType', false, cl);
% Returns a Field object pointint to TO.
field = rt.getField('TO');
% Gets the static instance of TO.
recipientTypeTo = field.get([]);

%===============================================================================
function fullPathToFile = locateFile(file)
%LOCATEFILE Resolve a filename to an absolute location.
%   LOCATEFILE(FILE) returns the absolute path to FILE.  If FILE cannot be
%   found, it returns an empty string.

% Matthew J. Simoneau, November 2003

% Checking that the length is exactly one in the first two checks automatically
% excludes directories, since directory listings always include '.' and '..'.

if (length(dir(fullfile(pwd,file))) == 1)
    % Relative path.
    fullPathToFile = fullfile(pwd,file);
elseif (length(dir(file)) == 1)
    % Absolute path.
    fullPathToFile = file;
elseif ~isempty(which(file))
    % A file on the path.
    fullPathToFile = which(file);
elseif ~isempty(which([file '.']))
    % A file on the path without extension.
    fullPathToFile = which([file '.']);
else
    fullPathToFile = '';
end

%===============================================================================
function toSend = formatText(msgText)
%formatText Format a block of text, adding line breaks every chars.

cr = char(10);

% For a cell array, send each cell as one line.
if iscell(msgText)
    toSend = join(msgText,cr);
    return
end

% For a char array, break each line at a char(10) or try to wrap to 75 
% characters.
lines = {};
maxLineLength = 75;
msgText = [cr msgText cr];
crList = find(msgText == cr);

for i = 1:length(crList)-1
    nextLine = msgText(crList(i)+1 : crList(i+1)-1);
    lineLength = length(nextLine);

    nextStart = 1;
    moreOnLine = true;
    while moreOnLine
        start = nextStart;
        if (lineLength-start+1 <= maxLineLength)
            % The rest fits on one line.
            stop = lineLength;
            moreOnLine = false;
        else
            % Whole line doesn't fit.  Needs to be broken up.
            spaces = find(nextLine == ' ');
            spaces = spaces(spaces >= start);
            nonSpaces = find(nextLine ~= ' ');
            nonSpaces = nonSpaces(nonSpaces >= start);            
            if isempty(spaces)
%                 % No spaces anywhere.  Chop!
%                 stop = start+maxLineLength-1;
                % No spaces anywhere.  Preserve.
                stop = lineLength;
            elseif isempty(nonSpaces)
                % Nothing but spaces.  Send an empty line.
                stop = start-1;
            elseif (min(spaces) > (start+maxLineLength))
%                 % The first space doesn't show up soon enough to help.  Chop!
%                 stop = start+maxLineLength-1;
                % No spaces anywhere.  Preserve.
                stop = lineLength;
            elseif isempty(spaces( ...
                    spaces > min(nonSpaces) & spaces < start+maxLineLength ...
                    ))
%                 % There are only leading spaces, which we respect.  Chop!
%                 stop = start+maxLineLength-1;
                % No spaces anywhere.  Preserve.
                stop = lineLength;
            else
                % Break on the last space that will make the line fit.
                stop = max(spaces(spaces <= (start+maxLineLength)))-1;
            end
            % After a break, start the next line on the next non-space.
            nonSpaces = find(nextLine ~= ' ');
            nextStart = min(nonSpaces(nonSpaces > stop));
            if isempty(nextStart)
                moreOnLine = false;
            end
        end
        lines{end+1,1} = nextLine(start:stop);
    end
end

toSend = join(lines,cr);

%===============================================================================
function niceError = stripJavaError(err)
%stripJavaError Attempt to convert a stack trace into something prettier.

% Two nice error messages.  Pull them out and stick them together.
pat = 'Java exception occurred:\s*\S+: (.*?)\n\s*nested exception is:\s*\S+: (.*?)\n';
m = regexp(err,pat,'tokens','once');
if ~isempty(m)
    niceError = sprintf('%s\n%s',m{:});
    return
end

% One nice error message.  Strip it off.
pat = 'Java exception occurred:\s*\S+: (.*?)\n';
m = regexp(err,pat,'tokens','once');
if ~isempty(m)
    niceError = m{1};
    return
end

% Only exceptions.  Special-case popular ones.
pat = 'Java exception occurred:\s*(\S+)\s*\n';
m = regexp(err,pat,'tokens','once');
if ~isempty(m)
    switch m{1}
        case 'javax.mail.AuthenticationFailedException'
            niceError = 'Authentication failed.';
            return
    end
end

% Can't find a nice message.
niceError = '';

%===============================================================================
function s = join(c,d)
%JOIN combines a cell array of strings into a single string.
%   JOIN(CELLSTR,DELIMITER) returns a string of the elements of the cell array
%   joined together with DELIMITER between each.
%
%     >> join({'foo','bar','baz'},'MJS')
%     
%     ans =
%     
%     fooMJSbarMJSbaz

% Matthew J. Simoneau
% April 2003

c = c(:)';
ds = cell(size(c));
ds(:) = {d};
c = [c;ds];
c = c(1:end-1);
s = [c{:}];