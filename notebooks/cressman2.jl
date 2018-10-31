"""
    fi = cressman2(R,X,Y,Fe,x,y; method = :cressman)

Interpolate the data `Fe` at the locations `x`, `y`, onto the regular grid
defined by `X` and `Y` using the Cressman method (in 2 dimensions).
"""



function cressman2(R,X,Y,Fe,x,y; method = :cressman)

    meanF = mean(Fe);
    Fa = Fe .- meanF;
    fi = zeros(size(x));

    R2 = R^2;


    for j=1:size(x,2)
        for i=1:size(y,1)

            d2 = (x[i,j] .- X).^2 .+ (y[i,j] .- Y).^2;


            if method == :cressman
                w = (R2 .- d2) ./ (R2 .+ d2);
                w[w.<0] .= 0;
            else
                w = exp.(-d2 ./ (2*R2));
            end

            sw = sum(w);

            if sw == 0
                fi[i,j] = NaN;
            else
                fi[i,j] = sum(w.*Fa)/sw;
            end
        end
    end

    fi = fi .+ meanF;

    return fi
end

# Copyright (C) 2018 Alexander Barth <barth.alexander@gmail.com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <http://www.gnu.org/licenses/>.

# LocalWords:  fi DIVAnd pmn len diag CovarParam vel ceil moddim fracdim
