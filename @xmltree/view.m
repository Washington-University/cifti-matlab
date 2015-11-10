function view(tree)
% XMLTREE/VIEW View Method (deprecated)
% FORMAT view(tree)
% 
% tree   - XMLTree object
%__________________________________________________________________________
%
% Display an XML tree in a graphical interface.
%
% This function is DEPRECATED: use EDITOR instead.
%__________________________________________________________________________
% Copyright (C) 2002-2015  http://www.artefact.tk/

% Guillaume Flandin
% $Id: view.m 10858 2015-11-10 12:40:42Z roboos $


%error(nargchk(1,1,nargin));

editor(tree);
