function [f, df] = ZSL_ObjFunc(W, c, dx, dz, X, Z, Y, ZZ_t, XX_t, XYZ_t,  D_xzi, lambda1, lambda2, lambda3)

%assert(length(W) == (c*dx + c*dz)); 

W_x_vec = W(1:c*dx); 
W_z_vec = W(c*dx+1:end); 
W_x = reshape(W_x_vec, [c, dx]); 
W_z = reshape(W_z_vec, [c, dz]); 

dp = dx/7; 
W_x_t = W_x'; %% W_x_transform

%W_x_p = zeros(dp, c, 7); 
%for i = 1:7
%    W_x_p(:,:,i) = W_x_t((dp*(i-1)+1) : dp*(i),:); 
%end

% % precompute multplication

Wxt_Wz = W_x' * W_z; 
Wxt_Wz_Z = Wxt_Wz * Z; %Wxt_Wz_Z = W_x'*W_z*Z; 

trace_sum = 0; 
%D_xzi = zeros(dz,dz,7);
for i = 1:7
    W_xz = W_x_t((dp*(i-1)+1) : dp*(i),:) * W_z; 
    D_xzi(:,:,i) = diag([1 ./ (2*sqrt(sum((W_xz').^2,2) + 0.0001))]); %diag([1 ./ (2*normL2_by_row(W_xz'))]);
    trace_sum = trace_sum + trace( W_x_t((dp*(i-1)+1) : dp*(i),:) * W_z * D_xzi(:,:,i) * W_z' * W_x_t((dp*(i-1)+1) : dp*(i),:)'); 
end

D_z = diag([1 ./ (2*sqrt(sum((W_z').^2,2) + 0.0001))]); %diag([1 ./ (2*normL2_by_row(W_z'))]);  %% dz X dz
% % loss function 
f =  norm( (X'* Wxt_Wz_Z - Y) ,'fro')^2 + lambda1 * norm( Wxt_Wz_Z ,'fro')^2 +...
    lambda2 * trace(W_z * D_z * W_z') + lambda3 * trace_sum; 

% % calculate the derivative of W_x
term1 = W_z * ZZ_t * Wxt_Wz' * XX_t - 2 * W_z * XYZ_t'; 
term2 = lambda1 * W_z * ZZ_t * Wxt_Wz'; 
term4 = zeros(dx, c); 
for i = 1:7
    term4((dp*(i-1)+1) : dp*(i), :) =   W_x_t((dp*(i-1)+1) : dp*(i),:)* W_z * D_xzi(:,:,i) * W_z'; 
end
term4 = lambda3 * term4; 

dW_x = 2 * (term1 + term2 + term4');
dW_x_vec = reshape(dW_x, [c*dx,1]); 


% % calculate the derivative of W_z
term1 = W_x * XX_t * Wxt_Wz * ZZ_t - W_x * XYZ_t; 
term2 = lambda1 * W_x * Wxt_Wz * ZZ_t ; 
term3 = lambda2 * W_z * D_z; 
term4 = zeros(c, dz); 
for i = 1:7
    term4 = term4 + W_x_t((dp*(i-1)+1) : dp*(i),:)'*  W_x_t((dp*(i-1)+1) : dp*(i),:) * W_z * D_xzi(:,:,i); 
end
term4 = term4 * lambda3; 
dW_z = 2 * (term1 + term2 + term3 + term4);
dW_z_vec = reshape(dW_z, [c*dz,1]); 

df = [dW_x_vec; dW_z_vec]; 

fprintf(['f = ', num2str(f), '\n']);
end


% % function value = normL2_by_row(M)
% %     ep = 0.0001;
% %     value = sqrt(sum(M.^2,2) + ep);
% % end

