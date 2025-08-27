classdef TestHello < matlab.unittest.TestCase
    
    methods (Test)
        function testDefaultGreeting(test)
            response = hello();
            
            test.verifyEqual(response, "Hello World");
        end
        
        function testWithName(test)
            response = hello("Alice");
            
            test.verifyEqual(response, "Hello Alice");
        end
    end
end