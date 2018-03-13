function [F,G] = FittingRules(B,C,D,E)

% Inbound
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Segment angle (simple model fit)
% B = zAngleFit {FEBiD_CAD_vXpX.m} variable name

% Segment angle (experimental data)
% C = zAngle {FEBiD_CAD_vXpX.m} variable name

% Maximum allowable deviation between experimental angle and model angle in
% uints of [degrees]
% D = dSeg {FEBiD_CAD_vXpX.m} variable name

% Derivative of experimental segment angle curve (weights the fitting)
% E = dZeta_dt{FEBiD_CAD_vXpX.m} variable name



% Function
% ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Quality of fitting parameter
F = sum( E.*abs( C - B ) ) + abs( sum( E.*(C - B) )  ); %[]
% Rule #1 for determining the fitting quality
G = sum( abs(C - B) > D );



% Outbound
% ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Quality of fitting
% F = Fit

% Fitting rule
% G = Rule_1


end