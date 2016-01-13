function installexternals(isSkippedIfExists)
if nargin<1
	isSkippedIfExists=false;
end
%
curDir=fileparts(which(mfilename));
extFolder=[curDir,filesep,'..',filesep,'externals'];
if exist(extFolder,'dir')
	if isSkippedIfExists
		return;
	end
	while true
		promptStr=sprintf(...
			['Directory %s already exists.\n\t\t\tIf you proceed this ',...
			'folders''s content will be completely overwritten.\n\t\t\t',...
			'Do you want to proceed? [y]/n: '],...
			strrep(extFolder,filesep,[filesep,filesep]));
		str = input(promptStr,'s');
		if isempty(str)
			str = 'y';
		end
		switch lower(str)
			case 'y'
				fprintf('Deleting directory\n\t\t\t%s...',extFolder);
				rmdir(extFolder,'s');
				fprintf('done\n');
				break;
			case 'n';
				break;
			otherwise
				sprintf('Unrecognized input');
				continue;
		end
	end
end
EXTERNALS_URL=['https://github.com/SystemAnalysisDpt-CMC-MSU/',...
	'ellipsoids/releases/download/',...
	'2.2dev/cvx2.1_b1110_mpt3_1_2_win32_win64_glnx64.zip'];
tmpFile=[curDir,filesep,'externals.zip'];
fprintf('Downloading externals from\n\t\t\t%s\n\t\t\tinto\n\t\t\t%s...',...
	EXTERNALS_URL,tmpFile);
urlwrite(EXTERNALS_URL,tmpFile);
fprintf('done\n');
msgStr=sprintf('Unpacking externals into\n\t\t\t%s...',...
	strrep(extFolder,filesep,[filesep,filesep]));
fprintf(msgStr);
unzip(tmpFile,[curDir,filesep,'..',filesep,'externals']);
fprintf('done\n');
fprintf('Deleting temporary file\n\t\t\t %s...',tmpFile);
delete(tmpFile);
fprintf('done\n');