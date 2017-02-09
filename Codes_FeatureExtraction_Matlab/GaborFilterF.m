function Out = GaborFilterF(I,typeflag,gradtype,scale,orientation,plotflag)
% Input:     - I: A 2D image
%            - typeflag: Struct of logicals to permit extracting features
%              based on desired characteristics:
%                   + typeflag.global: all features
%                   + typeflag.transform: all features
%                   + typeflag.gradient: only features based on gradient
%                   + typeflag.texture: only features based on texture
%                   + typeflag.entropy: only features based on entropy
%              default: all features are being extracted
%              For more information see README.txt
%            - gradtype: Struct of logicals to choose which type of
%              gradient should be applied:
%                   + gradtype.first: first order gradient
%                   + gradtype.second: second order gradient (Laplacian)
%              default: both types of gradients are used
%            - scale: Number of scales
%            - orientation: Number of orientations
%            - plotflag: A logical flag to enable/disable visualization
%
% 
% Output:    - Out: A 1x3600 feature vector for 90 measures and 40 filters.
%
% ************************************************************************
% Implemented for MRI feature extraction by the Department of Diagnostic
% and Interventional Radiology, University Hospital of Tuebingen, Germany
% and the Institute of Signal Processing and System Theory University of
% Stuttgart, Germany. Last modified: February 2017
%
% This implementation is part of ImFEATbox, a toolbox for image feature
% extraction and analysis. Available online at:
% https://github.com/annikaliebgott/ImFEATbox
%
% Contact: annika.liebgott@iss.uni-stuttgart.de
% ************************************************************************

%% Generate Gabor filters
% GaborResult: A cell containing images filtered with Gabor filters 
% generated by Generate_GaborFilter.m 
% Each cell entry represents one filtered image.
GaborResult = Generate_GaborFilter(scale,orientation,I,plotflag);


%% extract features

counter=1;

for i=1:1:size(GaborResult,1)
    for j=1:1:size(GaborResult,2)
        FilteredImage = GaborResult{i,j};
        
        % extract some features directly from filtered image
        if (typeflag.transform || typeflag.global)
            std_fI = std(abs(FilteredImage(:)));
            mean_fI = mean(abs(FilteredImage(:)));
            energy_fI = sum(sum(FilteredImage.^2));
        end
        
        % extract gradient features of filtered image
        if (typeflag.transform || typeflag.global || typeflag.gradient)
            GaborGradFeatures = GradientF(FilteredImage,typeflag,gradtype);
        end
        
        % extract histogram-based features of filtered image
        if (typeflag.transform || typeflag.global || typeflag.texture)
            GaborHistFeatures = HistogramF(FilteredImage,typeflag);
        end
        
        if (~typeflag.transform && ~typeflag.global)
            if ~typeflag.texture
                Out(counter:counter+length(GaborGradFeatures)-1) = GaborGradFeatures;
                counter = counter + length(GaborGradFeatures);
            elseif ~typeflag.gradient
                Out(counter:counter+length(GaborHistFeatures)-1) = GaborHistFeatures;
                counter = counter + length(GaborHistFeatures);
            else
                Out(counter:counter+length(GaborGradFeatures)+length(GaborHistFeatures)-1) =...
                    [GaborGradFeatures GaborHistFeatures];
            end
        else
            Out(counter:(counter+3+length(GaborGradFeatures) + length(GaborHistFeatures)-1)) =...
                [std_fI mean_fI energy_fI GaborGradFeatures GaborHistFeatures]; % 3+11=14
            counter = counter + 3 + length(GaborGradFeatures) + length(GaborHistFeatures);
        end
    end
end

%% return feature vector

Out = real(Out);