function computemove( Rx,Ry, Bx,By,  Gx,Gy, s)

%Vector a = interceptor direction, vector b = missile direction wrt a.
a = [Bx - Gx , By - Gy];
b = [Rx - Gx , Ry - Gy];
moda = sqrt(sum(a.^2));
modb = sqrt(sum(b.^2));

%Reference vector for calculating angle between vectors
ref = [800, 0];
anglea = acos( dot(a,ref)/(800*moda)  )*(180/3.14); %For real elements of x in the interval [-1,1], acos(x) returns real values in the interval [0,pi].
angleb = acos( dot(b,ref)/(800*modb)  )*(180/3.14);

alpha  = anglea - angleb;


    anglebetweenvectors  = acos( dot(a,b)/(moda*modb)  )*(180/3.14);

    if (   anglebetweenvectors < 90 ||(   (anglea<90)&&(angleb<90)  )     ) %Default anglebetweenvectors<90
        if (alpha > 10)
             fwrite(s,'3');       %Move right
             return;
        elseif(alpha < -10)
                fwrite(s,'2');    %Move left
                return;
        elseif(-10 < alpha < 10)
                fwrite(s,'1');    %Move straight
                return;
        end
    elseif(   (anglebetweenvectors>90) ||  ( (anglebetweenvectors<180)&&(anglea>90)&&(angleb>90) )   )%default is just else
          if (alpha > 10)
            fwrite(s,'2');        %Move left
            return;
        elseif(alpha < -10)
            fwrite(s,'3');        %Move right
            return;
        elseif(-10 < alpha < 10)
            fwrite(s,'1');        %Move straight
            return;
          end 
    end
end