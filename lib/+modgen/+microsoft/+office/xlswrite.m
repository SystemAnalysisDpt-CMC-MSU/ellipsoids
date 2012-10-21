function [success,theMessage, file]=xlswrite(file,data,sheet,range)
% XLSWRITE is an improved version of built-in xlswrite function. It uses a
% custom csvwrite function instead of dlmwrite to write data in csv format
% when Excel is not available. Additionally it returns a resulting file
% name argument as the third output parameter
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-10-05 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
N_MAX_ROWS=65536;
N_MAX_COLS=256;
%
Sheet1 = 1;

if nargin < 3
    sheet = Sheet1;
    range = '';
elseif nargin < 4
    range = '';
end

if nargout > 0
    success = true;
    theMessage = struct('message',{''},'identifier',{''},'exeptionObject',[]);
end

% Handle input.
try
    % handle requested Excel workbook filename.
    if ~isempty(file)
        if ~ischar(file)
            error('MATLAB:xlswrite:InputClass','Filename must be a string.');
        end
        % check for wildcards in filename
        if any(findstr('*', file))
            error('MATLAB:xlswrite:FileName', 'Filename must not contain *.');
        end
        [Directory,file,ext]=fileparts(file);
        if isempty(ext) % add default Excel extension;
            ext = '.xls';
        end
        file = abspath(fullfile(Directory,[file ext]));
        [a1 a2] = fileattrib(file);
        if a1 && ~(a2.UserWrite == 1)
            error('MATLAB:xlswrite:FileReadOnly', 'File cannot be read-only.');
        end
    else % get workbook filename.
        error('MATLAB:xlswrite:EmptyFileName','Filename is empty.');
    end

    % Check for N-D array input data
    if ndims(data)>2
        error('MATLAB:xlswrite:InputDimension',...
            'Dimension of input array cannot be higher than two.');
    end
    
    % Check class of input data
    if ~(iscell(data) || isnumeric(data) || ischar(data)) && ~islogical(data)
        error('MATLAB:xlswrite:InputClass',...
            'Input data must be a numeric, cell, or logical array.');
    end
    
    
    % convert input to cell array of data.
    if iscell(data)
        A=data;
    else
        A=num2cell(data);
    end
    
    if nargin > 2
        % Verify class of sheet parameter.
        if ~(ischar(sheet) || (isnumeric(sheet) && sheet > 0))
            error('MATLAB:xlswrite:InputClass',...
                'Sheet argument must be a string or a whole number greater than 0.');
        end
        if isempty(sheet)
            sheet = Sheet1;
        end
        % parse REGION into sheet and range.
        % Parse sheet and range strings.
        if ischar(sheet) && ~isempty(strfind(sheet,':'))
            range = sheet; % only range was specified.
            sheet = Sheet1;% Use default sheet.
        elseif ~ischar(range)
            error('MATLAB:xlswrite:InputClass',...
                'Range argument must be a string in Excel A1 notation.');
        end
    end
    
catch exception
    if ~isempty(nargchk(2,4,nargin))
        error('MATLAB:xlswrite:InputArguments',nargchk(2,4,nargin));
    else
        success = false;
        theMessage = exceptionHandler(nargout, exception);
    end
    return;
end
%------------------------------------------------------------------------------
% Attempt to start Excel as ActiveX server.
isDataEmpty=isempty(data);
isTooManyRows=size(data,1)>N_MAX_ROWS;
isTooManyCols=size(data,2)>N_MAX_COLS;
if isDataEmpty||isTooManyRows||isTooManyCols
    isWriteCSV=true;
    if isDataEmpty
        errStr='data is empty';
    elseif isTooManyRows
        errStr='too many rows';
    else
        errStr='too many columns';
    end
    modgen.common.throwwarn('resultFileTypeChange',...
        sprintf(['result will be written to ',...
        'csv file, reason: %s'],errStr));
else
    try
        Excel = actxserver('Excel.Application');
        isWriteCSV=false;
        
    catch exception %#ok<NASGU>
        warning('MATLAB:xlswrite:NoCOMServer',...
            ['Could not start Excel server for export.\n' ...
            'XLSWRITE will attempt to write file in CSV format.']);
        % write data as CSV file, that is, comma delimited.
        isWriteCSV=true;
    end
end
if isWriteCSV
    file = regexprep(file,'(\.xls[^.]*+)$','.csv');
    try
        modgen.cell.csvwrite(file,data);
    catch exception
        exceptionNew = MException('MATLAB:xlswrite:csvwrite',...
            'An error occurred on data export in CSV format.');
        exceptionNew = exceptionNew.addCause(exception);
        if nargout == 0
            % Throw error.
            throw(exceptionNew);
        else
            success = false;
            theMessage.message = exceptionNew.getReport;
            theMessage.identifier = exceptionNew.identifier;
            theMessage.exceptionObject=exceptionNew;
        end
    end
    return;
else
    %------------------------------------------------------------------------------
    try
        % Construct range string
        if isempty(strfind(range,':'))
            % Range was partly specified or not at all. Calculate range.
            [m,n] = size(A);
            range = calcrange(range,m,n);
        end
    catch exception
        success = false;
        theMessage = exceptionHandler(nargout, exception);
        return;
    end
    
    %------------------------------------------------------------------------------
    try
        bCreated = ~exist(file,'file');
        ExecuteWrite;
    catch exception
        if (bCreated && exist(file, 'file') == 2)
            delete(file);
        end
        success = false;
        theMessage = exceptionHandler(nargout, exception);
    end
end
    function ExecuteWrite
        cleanUp = onCleanup(@()cleaner(Excel, file));
        if bCreated
            % Create new workbook.
            %This is in place because in the presence of a Google Desktop
            %Search installation, calling Add, and then SaveAs after adding data,
            %to create a new Excel file, will leave an Excel process hanging.
            %This workaround prevents it from happening, by creating a blank file,
            %and saving it.  It can then be opened with Open.
            ExcelWorkbook = Excel.workbooks.Add;
            switch ext
                case '.xls' %xlExcel8 or xlWorkbookNormal
                    xlFormat = -4143;
                case '.xlsb' %xlExcel12
                    xlFormat = 50;
                case '.xlsx' %xlOpenXMLWorkbook
                    xlFormat = 51;
                case '.xlsm' %xlOpenXMLWorkbookMacroEnabled
                    xlFormat = 52;
                otherwise
                    xlFormat = -4143;
            end
            ExcelWorkbook.SaveAs(file, xlFormat);
            ExcelWorkbook.Close(false);
        end
        
        %Open file
        ExcelWorkbook = Excel.workbooks.Open(file);
        if ExcelWorkbook.ReadOnly ~= 0
            %This means the file is probably open in another process.
            error('MATLAB:xlswrite:LockedFile', 'The file %s is not writable.  It may be locked by another process.', file);
        end
        try % select region.
            % Activate indicated worksheet.
            theMessage = activate_sheet(Excel,sheet);
            
            % Select range in worksheet.
            Select(Range(Excel,sprintf('%s',range)));
            
        catch exceptionInner % Throw data range error.
            throw(MException('MATLAB:xlswrite:SelectDataRange', sprintf('Excel returned: %s.', exceptionInner.message)));
        end
        
        % Export data to selected region.
        set(Excel.selection,'Value',A);
        ExcelWorkbook.Save
    end
end
function cleaner(Excel, filePath)
try
    %Turn off dialog boxes as we close the file and quit Excel.
    Excel.DisplayAlerts = 0;
    %Explicitly close the file just in case.  The Excel API expects
    %just the filename and not the path.  This is safe because Excel
    %also does not allow opening two files with the same name in
    %different folders at the same time.
    [~, n, e] = fileparts(filePath);
    fileName = [n e];
    Excel.Workbooks.Item(fileName).Close(false);
catch exception %#ok<NASGU>
    %If something fails in closing, there is nothing to do but attempt
    %to quit.
end
Excel.Quit;
end
%--------------------------------------------------------------------------
function theMessage = activate_sheet(Excel,Sheet)
% Activate specified worksheet in workbook.

% Initialise worksheet object
WorkSheets = Excel.sheets;
theMessage = struct('message',{''},'identifier',{''});

% Get name of specified worksheet from workbook
try
    TargetSheet = get(WorkSheets,'item',Sheet);
catch exception  %#ok<NASGU>
    % Worksheet does not exist. Add worksheet.
    TargetSheet = addsheet(WorkSheets,Sheet);
    warning('MATLAB:xlswrite:AddSheet','Added specified worksheet.');
    if nargout > 0
        [theMessage.message,theMessage.identifier] = lastwarn;
        theMessage.exceptionObject=exception;
    end
end

% activate worksheet
Activate(TargetSheet);
end
%------------------------------------------------------------------------------
function newsheet = addsheet(WorkSheets,Sheet)
% Add new worksheet, Sheet into worsheet collection, WorkSheets.

if isnumeric(Sheet)
    % iteratively add worksheet by index until number of sheets == Sheet.
    while WorkSheets.Count < Sheet
        % find last sheet in worksheet collection
        lastsheet = WorkSheets.Item(WorkSheets.Count);
        newsheet = WorkSheets.Add([],lastsheet);
    end
else
    % add worksheet by name.
    % find last sheet in worksheet collection
    lastsheet = WorkSheets.Item(WorkSheets.Count);
    newsheet = WorkSheets.Add([],lastsheet);
end
% If Sheet is a string, rename new sheet to this string.
if ischar(Sheet)
    set(newsheet,'Name',Sheet);
end
end
%------------------------------------------------------------------------------
function [absolutepath]=abspath(partialpath)

% parse partial path into path parts
[pathname filename ext] = fileparts(partialpath);
% no path qualification is present in partial path; assume parent is pwd, except
% when path string starts with '~' or is identical to '~'.
if isempty(pathname) && isempty(strmatch('~',partialpath))
    Directory = pwd;
elseif isempty(regexp(partialpath,'(.:|\\\\)','once')) && ...
        isempty(strmatch('/',partialpath)) && ...
        isempty(strmatch('~',partialpath));
    % path did not start with any of drive name, UNC path or '~'.
    Directory = [pwd,filesep,pathname];
else
    % path content present in partial path; assume relative to current directory,
    % or absolute.
    Directory = pathname;
end

% construct absulute filename
absolutepath = fullfile(Directory,[filename,ext]);
end
%------------------------------------------------------------------------------
function range = calcrange(range,m,n)
% Calculate full target range, in Excel A1 notation, to include array of size
% m x n

range = upper(range);
cols = isletter(range);
rows = ~cols;
% Construct first row.
if ~any(rows)
    firstrow = 1; % Default row.
else
    firstrow = str2double(range(rows)); % from range input.
end
% Construct first column.
if ~any(cols)
    firstcol = 'A'; % Default column.
else
    firstcol = range(cols); % from range input.
end
try
    lastrow = num2str(firstrow+m-1);   % Construct last row as a string.
    firstrow = num2str(firstrow);      % Convert first row to string image.
    lastcol = dec2base27(base27dec(firstcol)+n-1); % Construct last column.
    
    range = [firstcol firstrow ':' lastcol lastrow]; % Final range string.
catch exception
    error('MATLAB:xlswrite:CalculateRange', 'Invalid data range: %s.', range);
end
end
%----------------------------------------------------------------------
function string = index_to_string(index, first_in_range, digits)

letters = 'A':'Z';
working_index = index - first_in_range;
outputs = cell(1,digits);
[outputs{1:digits}] = ind2sub(repmat(26,1,digits), working_index);
string = fliplr(letters([outputs{:}]));
end
%----------------------------------------------------------------------
function [digits first_in_range] = calculate_range(num_to_convert)

digits = 1;
first_in_range = 0;
current_sum = 26;
while num_to_convert > current_sum
    digits = digits + 1;
    first_in_range = current_sum;
    current_sum = first_in_range + 26.^digits;
end
end
%------------------------------------------------------------------------------
function s = dec2base27(d)

%   DEC2BASE27(D) returns the representation of D as a string in base 27,
%   expressed as 'A'..'Z', 'AA','AB'...'AZ', and so on. Note, there is no zero
%   digit, so strictly we have hybrid base26, base27 number system.  D must be a
%   negative integer bigger than 0 and smaller than 2^52.
%
%   Examples
%       dec2base(1) returns 'A'
%       dec2base(26) returns 'Z'
%       dec2base(27) returns 'AA'
%-----------------------------------------------------------------------------

d = d(:);
if d ~= floor(d) || any(d(:) < 0) || any(d(:) > 1/eps)
    error('MATLAB:xlswrite:Dec2BaseInput',...
        'D must be an integer, 0 <= D <= 2^52.');
end
[num_digits begin] = calculate_range(d);
s = index_to_string(d, begin, num_digits);
end
%------------------------------------------------------------------------------
function d = base27dec(s)
%   BASE27DEC(S) returns the decimal of string S which represents a number in
%   base 27, expressed as 'A'..'Z', 'AA','AB'...'AZ', and so on. Note, there is
%   no zero so strictly we have hybrid base26, base27 number system.
%
%   Examples
%       base27dec('A') returns 1
%       base27dec('Z') returns 26
%       base27dec('IV') returns 256
%-----------------------------------------------------------------------------

if length(s) == 1
    d = s(1) -'A' + 1;
else
    cumulative = 0;
    for i = 1:numel(s)-1
        cumulative = cumulative + 26.^i;
    end
    indexes_fliped = 1 + s - 'A';
    indexes = fliplr(indexes_fliped);
    indexes_in_cells = mat2cell(indexes, 1, ones(1,numel(indexes)));
    d = cumulative + sub2ind(repmat(26, 1,numel(s)), indexes_in_cells{:});
end
end
%-------------------------------------------------------------------------------

function messageStruct = exceptionHandler(nArgs, exception)
if nArgs == 0
    throwAsCaller(exception);
else
    messageStruct.message = exception.message;
    messageStruct.identifier = exception.identifier;
    messageStruct.exceptionObject=exception;
end
end