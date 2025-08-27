function saveEncryptedCredentials(account_key, security_key, password, filename)
    % Save credentials to an encrypted .mat file using simple XOR encryption
    if nargin < 4
        filename = 'api_credentials_encrypted.mat';
    end
    
    % Simple XOR encryption with password (inline implementation)
    encrypted_account = xor_encrypt_decrypt(account_key, password);
    encrypted_security = xor_encrypt_decrypt(security_key, password);
    
    % Add a verification hash to detect wrong passwords
    verification = char(mod(sum(uint8(password)), 256));
    
    save(filename, 'encrypted_account', 'encrypted_security', 'verification', '-v7');
    fprintf('Credentials saved to encrypted file: %s\n', filename);
    
    % Set file permissions (Unix/Linux/Mac only)
    if ~ispc
        system(sprintf('chmod 600 %s', filename));
    end
    
    function result = xor_encrypt_decrypt(text, key)
        % Simple XOR encryption/decryption (same operation for both)
        text_bytes = uint8(text);
        key_bytes = uint8(key);
        
        % Repeat key to match text length
        key_repeated = repmat(key_bytes, 1, ceil(length(text_bytes) / length(key_bytes)));
        key_final = key_repeated(1:length(text_bytes));
        
        % XOR operation
        result_bytes = bitxor(text_bytes, key_final);
        result = char(result_bytes);
    end
end