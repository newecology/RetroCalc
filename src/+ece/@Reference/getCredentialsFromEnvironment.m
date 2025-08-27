% Set environment variables in your system (outside MATLAB):
% Windows: setx DEGREEDAYS_ACCOUNT_KEY "your-account-key"
% Windows: setx DEGREEDAYS_SECURITY_KEY "your-security-key"
% Linux/Mac: export DEGREEDAYS_ACCOUNT_KEY="uy6s-a27q-2k75"
% Linux/Mac: export DEGREEDAYS_SECURITY_KEY="bfwd-bbyk-q6xy-pg5k-a6aq-5m27-sfb6-nds8-2wr5-hwvm-52xz-7kyk-sjx7"

function credentials = getCredentialsFromEnvironment()
    % Get credentials from environment variables
    account_key = getenv('DEGREEDAYS_ACCOUNT_KEY');
    security_key = getenv('DEGREEDAYS_SECURITY_KEY');
    
    if isempty(account_key) || isempty(security_key)
        error('API credentials not found in environment variables. Please set DEGREEDAYS_ACCOUNT_KEY and DEGREEDAYS_SECURITY_KEY');
    end
    
    credentials = struct('account_key', account_key, 'security_key', security_key);
    fprintf('Loaded credentials from environment variables\n');
end