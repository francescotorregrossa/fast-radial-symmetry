function frs = fastradialsymmetry(img, range)
[h, w] = size(img);
img = single(img);
frs = zeros([h w length(range)]);

% calcolo modulo e angolo degi bordi tramite sobel
dx = conv2(img, [1 2 1]', 'same');
dx = conv2(dx, [-1 0 1], 'same');
dy = conv2(img, [-1 0 1]', 'same');
dy = conv2(dy, [1 2 1], 'same');
magnitude = sqrt(dx.^2 + dy.^2);
orientation = atan2(dy, dx);

step = 1;
for r = range

    % scelta della costante di normalizzazione
    k = 9.9;
    if r == 1
        k = single(8);
    end

    % inizializzazione delle matrici di accumulazione di raggio r
    O = zeros(h, w);
    M = zeros(h, w);

    for j = 1+r:h-r
        for i = 1+r:w-r

            % calcola l'offset (y,x) relativo al pixel (j,i)
            % dove si accumuleranno i valori con raggio r            
            theta = orientation(j, i);
            rho = r;

            y = round(rho * sin(theta));
            x = round(rho * cos(theta));

            O(j + y, i + x) = O(j + y, i + x) + 1;
            O(j - y, i - x) = O(j - y, i - x) - 1;
            M(j + y, i + x) = M(j + y, i + x) + magnitude(j, i);
            M(j - y, i - x) = M(j - y, i - x) - magnitude(j, i);
            
        end
    end
    
    % calcolo di O tilde
    for j = 1:h
        for i = 1:w
            if O(j, i) >= k
                O(j, i) = k;
            end
        end
    end

    % applicazione della normalizzazione
    O = O / k;
    M = M / k;

    % applicazione filtro di gauss
    F = M .* abs(O);
    F = conv2(F, [0.2740 0.4519 0.2740]', 'same');
    F = conv2(F, [0.2740 0.4519 0.2740], 'same');

    frs(:, :, step) = F;
    step = step + 1;

end

% somma delle matrici di accumulazione
frs = sum(frs, 3);

