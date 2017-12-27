# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import os 
import sys
import warnings
import shutil

baseReplacements = {
'$Author:':'\\author',
'$Authors:':'\\authors',
'$Copyright:':'\\copyright',
'$Date:':'\\date'}
additionalReplacements = {
'> $':'> ',
'>$':'>',
'0 $':'0 ',
'0$':'0',
'1 $':'1 ',
'1$':'1',
'2 $':'2 ',
'2$':'2',
'3 $':'3 ',
'3$':'3',
'4 $':'4 ',
'4$':'4',
'5 $':'5 ',
'5$':'5',
'6 $':'6 ',
'6$':'6',
'7 $':'7 ',
'7$':'7',
'8 $':'8 ',
'8$':'8',
'9 $':'9 ',
'9$':'9',
'System Analysis Department$':'System Analysis Department',
'\n':'<br>\n'}

if len(sys.argv) >= 3 and len(sys.argv) <= 4:
    rootDir = sys.argv[1]
    outDir = sys.argv[2]
    if len(sys.argv) == 4:
        isGarbage = True
        garbageDir = sys.argv[3]
    else:
        isGarbage = False
        garbageDir = ''
else:
    print('\nUsage: python prep4doxymat.py <inpDir> <outDir>    or')
    print('\n       python prep4doxymat.py <inpDir> <outDir> <garbageDir>\n')
    raise Exception('Improper number of input arguments')
if not type(rootDir) is str:
    raise Exception('root directory is expected to be string')
if not type(outDir) is str:
    raise Exception('output directory is expected to be string')
if not type(garbageDir) is str:
    raise Exception('garbage directory is expected to be string')

rootDir = rootDir.strip()
if rootDir.endswith(os.path.sep):
    rootDir = rootDir[:len(rootDir)-len(os.path.sep)]
if not os.path.isdir(rootDir):
    raise Exception('root directory ' + rootDir + ' does not exist')
outDir = outDir.strip()
if outDir.endswith(os.path.sep):
    outDir = outDir[:len(outDir)-len(os.path.sep)]
if os.path.isdir(outDir):
    shutil.rmtree(outDir)
if isGarbage:
    garbageDir = garbageDir.strip()
    if garbageDir.endswith(os.path.sep):
        garbageDir = garbageDir[:len(garbageDir)-len(os.path.sep)]
    if os.path.isdir(garbageDir):
        shutil.rmtree(garbageDir)

def writeComment( curOutFile, commentList, baseReplacementsMap, additionalReplacementsMap ):
    COMMENT_HEADER_STATE = 0
    COMMENT_VERBATIM_STATE = 1
    COMMENT_FOOTER_STATE = 2
    headerList = []
    verbatimList = []
    footerList = []
    commentLineIndent = ''
    curCommentState = COMMENT_HEADER_STATE
    replacementsMap = baseReplacementsMap.copy()
    replacementsMap.update(additionalReplacementsMap)
    for commentLine in commentList:
        commentLineStripped = commentLine.lstrip()
        commentLineIndent = commentLine[:len(commentLine)-len(commentLineStripped)]
        commentLineStripped = commentLineStripped[1:].replace('...','. . .')
        if curCommentState == COMMENT_FOOTER_STATE:
            if len(commentLineStripped) > 1:
                for src, target in replacementsMap.items():
                    commentLineStripped = commentLineStripped.replace(src, target)
            footerList.append(commentLineStripped.rstrip())
        else:
            if len(commentLineStripped) > 1:
                isFooter = False
                for src, target in baseReplacementsMap.items():
                    if src in commentLineStripped:
                        isFooter = True
                        commentLineStripped = commentLineStripped.replace(src, target)
                if isFooter:
                    curCommentState = COMMENT_FOOTER_STATE
                    for src, target in additionalReplacementsMap.items():
                        commentLineStripped = commentLineStripped.replace(src, target)
            commentLineStripped = commentLineStripped.rstrip()
            if curCommentState == COMMENT_HEADER_STATE:
                if len(commentLineStripped) == 0:
                    curCommentState = COMMENT_VERBATIM_STATE
                else:
                    headerList.append(commentLineStripped)
            elif curCommentState == COMMENT_VERBATIM_STATE:
                verbatimList.append(commentLineStripped)
            else:
                footerList.append(commentLineStripped)
    if len(headerList) > 0:
        curOutFile.write(commentLineIndent+'%>\\brief '+headerList[0]+'\n')
        for commentLine in headerList[1:]:
            curOutFile.write(commentLineIndent+'%>'+commentLine+'\n')
        curOutFile.write(commentLineIndent+'%>\n')
    if len(verbatimList) > 0:
        verbatimInd = next((ind for ind, commentLine in enumerate(verbatimList) if commentLine), -1)
        if verbatimInd == -1:
            verbatimList = []
        else:
            verbatimList = verbatimList[verbatimInd:]
            verbatimInd = next(ind for ind, commentLine in enumerate(reversed(verbatimList)) if commentLine)
            verbatimInd = len(verbatimList) - verbatimInd
            verbatimList = verbatimList[:verbatimInd]
            curOutFile.write(commentLineIndent+'%>\\verbatim\n')
            for commentLine in verbatimList:
                curOutFile.write(commentLineIndent+'%>'+commentLine+'\n')
            curOutFile.write(commentLineIndent+'%>\\endverbatim\n')
    if len(footerList) > 0:
        for commentLine in footerList:
            curOutFile.write(commentLineIndent+'%>'+commentLine+'\n')
    return;
    
OTHER_CODE_STATE = 0
HEADER_COLLECT_STATE = 1
COMMENT_COLLECT_STATE = 2
COMMENT_EXPECTED_STATE = 3
OTHER_CODE_EXPECTED_STATE = 4
for dirpath, dirs, files in os.walk(rootDir):
    curOutDir = outDir + dirpath[len(rootDir):]
    curGarbageDir = garbageDir + dirpath[len(rootDir):]
    for file in files:
        if file.endswith('.m'):
            if not os.path.isdir(curOutDir):
                os.makedirs(curOutDir)
            fullFileName = os.path.join(dirpath,file)
            outFullFileName = os.path.join(curOutDir,file)
            curWarningList = []
            try:
                with open(fullFileName) as infile, \
                    open(outFullFileName, 'w') as outfile:
                    curState = OTHER_CODE_STATE
                    curHeader = ''
                    curCommentList = []
                    isCommentBeforeFunc = False
                    for line in infile:
                        commentInd = line.find('%')
                        if commentInd == -1:
                            lineComment = ''
                            lineWoComment = line
                        else:
                            lineComment = line[commentInd:]
                            lineWoComment = line[:commentInd]
                        lineStripped = lineWoComment.lstrip()
                        lineIndent = lineWoComment[:len(lineWoComment)-len(lineStripped)]
                        lineStripped = lineStripped.rstrip()
                        lineComment = lineComment.rstrip()
                        if len(lineComment) > 0:
                            if all(c == "%" for c in lineComment):
                                lineComment = '%'
                        if curState == OTHER_CODE_STATE:
                            if lineStripped.startswith('function') or lineStripped.startswith('classdef'):
                                isCommentBeforeFunc = False
                                if lineStripped.endswith('...'):
                                    curState = HEADER_COLLECT_STATE
                                    curHeader = lineIndent + lineStripped[:len(lineStripped)-3]
                                else:
                                    curState = COMMENT_EXPECTED_STATE
                                    curHeader = lineIndent + lineStripped
                            elif len(lineStripped) == 0 and len(lineComment) > 1:
                                isCommentBeforeFunc = True
                                curState = COMMENT_COLLECT_STATE
                                curCommentList = [ line ]
                            else:
                                outfile.write(line)
                        elif curState == HEADER_COLLECT_STATE:
                            if lineStripped.endswith('...'):
                                curHeader = curHeader + lineStripped[:len(lineStripped)-3]
                            else:
                                curHeader = curHeader + lineStripped
                                if isCommentBeforeFunc:
                                    curState = OTHER_CODE_EXPECTED_STATE
                                else:
                                    curState = COMMENT_EXPECTED_STATE
                        elif curState == COMMENT_COLLECT_STATE:
                            if len(lineStripped) == 0 and len(lineComment) > 0:
                                curCommentList.append(line)
                            else:
                                if lineStripped.startswith('function') or lineStripped.startswith('classdef'):
                                    isCommentBeforeFunc = True
                                    if lineStripped.endswith('...'):
                                        curState = HEADER_COLLECT_STATE
                                        curHeader = lineIndent + lineStripped[:len(lineStripped)-3]
                                    else:
                                        curHeader = lineIndent + lineStripped
                                        curState = OTHER_CODE_EXPECTED_STATE
                                else:
                                    if isCommentBeforeFunc:
                                        for curLine in curCommentList:
                                            outfile.write(curLine)
                                        isCommentBeforeFunc = False
                                    else:
                                        writeComment( outfile, curCommentList, baseReplacements, additionalReplacements )
                                        outfile.write(curHeader+'\n')
                                    outfile.write(line)
                                    curState = OTHER_CODE_STATE
                        elif curState == COMMENT_EXPECTED_STATE:
                            if len(lineStripped) == 0 and len(lineComment) > 0:
                                curState = COMMENT_COLLECT_STATE
                                curCommentList = [ line ]
                            else:
                                outfile.write(curHeader+'\n')
                                outfile.write(line)
                                curState = OTHER_CODE_STATE
                        elif curState == OTHER_CODE_EXPECTED_STATE:
                            if len(lineStripped) == 0 and len(lineComment) > 0:
                                if len(lineComment) > 1:
                                    curWarning =  'For ' + curHeader + ' in ' + fullFileName + ' there are comments before and after the header'
                                    curWarningList.append(curWarning)
                                    warnings.warn(curWarning, UserWarning)
                                    isCommentBeforeFunc = False
                                    curCommentList.append(line)
                                    curState = COMMENT_COLLECT_STATE
                            else:
                                writeComment( outfile, curCommentList, baseReplacements, additionalReplacements )
                                outfile.write(curHeader+'\n')
                                if len(lineStripped) > 0:
                                    if lineStripped.startswith('function') or lineStripped.startswith('classdef'):
                                        isCommentBeforeFunc = False
                                        if lineStripped.endswith('...'):
                                            curState = HEADER_COLLECT_STATE
                                            curHeader = lineIndent + lineStripped[:len(lineStripped)-3]
                                        else:
                                            curState = COMMENT_EXPECTED_STATE
                                            curHeader = lineIndent + lineStripped
                                    else:
                                        curState = OTHER_CODE_STATE
                                        outfile.write(line)
                                else:
                                    curState = OTHER_CODE_STATE
                                    outfile.write(line)
                        else:
                            raise Exception('We should not be here while processing ' + fullFileName)
                    if curState == HEADER_COLLECT_STATE:
                        raise Exception('We should not be here while processing ' + curHeader + ' in ' + fullFileName)
                    elif curState == COMMENT_COLLECT_STATE:
                        for curLine in curCommentList:
                            outfile.write(curLine)
                    elif curState == COMMENT_EXPECTED_STATE:
                        outfile.write(curHeader+'\n')
            except:
                print('Unexpected error while ' + fullFileName + ' is processed: ', sys.exc_info()[0])
                raise
            if isGarbage and len(curWarningList) > 0:
                if not os.path.isdir(curGarbageDir):
                    os.makedirs(curGarbageDir)
                shutil.copyfile(fullFileName, os.path.join(curGarbageDir,file))
                shutil.copyfile(outFullFileName, os.path.join(curGarbageDir,file+'_'))
                with open(os.path.join(curGarbageDir,file+'.log'), 'w') as outfile:
                    for line in curWarningList:
                        outfile.write(line+'\n')