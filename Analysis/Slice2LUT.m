function [LUT_sig] = Slice2LUT(LUT_slice)

LUT_slice_norm = LUT_slice / max(LUT_slice);
LUT_sig = 0.5 * asin(sqrt(LUT_slice_norm));

end

