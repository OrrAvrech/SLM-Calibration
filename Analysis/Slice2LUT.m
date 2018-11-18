function [LUT_sig] = Slice2LUT(LUT_slice)
% Performs intensity to phase conversion.
% Args:
%       LUT_slice: intensity pattern of a given segment
% Returns:
%       LUT_sig: phase conversion of the intensity according to the 
%                theoretical equation

LUT_slice_norm = (LUT_slice - min(LUT_slice)) / max(LUT_slice - min(LUT_slice));
LUT_sig = 2 * asin(sqrt(LUT_slice_norm));

end

