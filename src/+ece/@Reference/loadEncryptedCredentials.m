function credentials = loadEncryptedCredentials(password, filename)
    % Load credentials from encrypted .mat file
    if nargin < 2
        filename = 'api_credentials_encrypted.mat';
    end
    
    if ~exist(filename, 'file')
        error('Encrypted credentials file not found: %s', filename);
    end
    
    load(filename, 'encrypted_account', 'encrypted_security', 'verification');
    
    % Verify password using stored verification
    if char(mod(sum(uint8(password)), 256)) ~= verification
        error('Incorrect password for encrypted credentials file.');
    end
    
    try
        % Decrypt using XOR (same function as encrypt)
        account_key = xor_encrypt_decrypt(encrypted_account, password);
        security_key = xor_encrypt_decrypt(encrypted_security, password);
        
        credentials = struct('account_key', account_key, 'security_key', security_key);
        fprintf('Loaded credentials from encrypted file\n');
    catch
        error('Failed to decrypt credentials. The file may be corrupted.');
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