function [LUT_sig] = Slice2LUT(LUT_slice)

LUT_sig = 0.5 * asin(sqrt(abs(LUT_slice)));

end

