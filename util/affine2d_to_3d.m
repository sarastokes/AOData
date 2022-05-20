function tform = affine2d_to_3d(T)

    if isa(T, 'affine2d')
        T = T.T;
    end

    T2 = eye(4);
    T2(2,1) = T(2,1);
    T2(1,2) = T(1,2);
    T2(4,1) = T(3,1);
    T2(4,2) = T(3,2);
    
    tform = affine3d(T2);